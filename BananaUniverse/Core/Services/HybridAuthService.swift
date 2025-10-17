//
//  HybridAuthService.swift
//  noname_banana
//
//  Created by AI Assistant on 14.10.2025.
//

import Foundation
import Supabase
import Combine
import AuthenticationServices

/// Manages authentication for both anonymous and authenticated users
@MainActor
class HybridAuthService: ObservableObject {
    static let shared = HybridAuthService()
    
    @Published var userState: UserState = .anonymous(deviceId: UUID().uuidString)
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let supabase: SupabaseService
    private var authStateTask: Task<Void, Never>?
    
    init(supabase: SupabaseService) {
        self.supabase = supabase
        setupAuthStateListener()
        checkCurrentUser()
    }
    
    convenience init() {
        self.init(supabase: SupabaseService.shared)
    }
    
    deinit {
        authStateTask?.cancel()
    }
    
    // MARK: - Initialization
    
    private func setupAuthStateListener() {
        authStateTask = Task {
            await supabase.client.auth.onAuthStateChange { [weak self] event, session in
                Task { @MainActor in
                    if let session = session {
                        self?.userState = .authenticated(user: session.user)
                        // Migrate credits if coming from anonymous state
                        await self?.handleAuthenticationStateChange()
                    } else {
                        // User signed out - switch to anonymous
                        self?.userState = .anonymous(deviceId: UUID().uuidString)
                    }
                }
            }
        }
    }
    
    private func checkCurrentUser() {
        if let user = supabase.getCurrentUser() {
            userState = .authenticated(user: user)
        } else {
            let deviceId = getOrCreateDeviceUUID()
            userState = .anonymous(deviceId: deviceId)
        }
    }
    
    private func handleAuthenticationStateChange() async {
        // If we have a previous anonymous state, migrate credits
        if case .anonymous = userState {
            // This will be handled by the credit manager
            HybridCreditManager.shared.setUserState(userState)
        }
    }
    
    // MARK: - Anonymous Authentication
    
    func signInAnonymously() {
        let deviceId = getOrCreateDeviceUUID()
        userState = .anonymous(deviceId: deviceId)
        HybridCreditManager.shared.setUserState(userState)
        print("🔓 [HybridAuthService] User signed in anonymously with device ID: \(deviceId)")
    }
    
    // MARK: - Authenticated Authentication
    
    func signIn(email: String, password: String) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            try await supabase.signIn(email: email, password: password)
            // Auth state will be updated via listener
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            throw error
        }
        
        isLoading = false
    }
    
    func signUp(email: String, password: String) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            try await supabase.signUp(email: email, password: password)
            // Auth state will be updated via listener
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            throw error
        }
        
        isLoading = false
    }
    
    func signInWithApple() async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            
            let result = try await withCheckedThrowingContinuation { continuation in
                authorizationController.delegate = ASAuthorizationControllerDelegateWrapper(continuation: continuation)
                authorizationController.performRequests()
            }
            
            guard let appleIDCredential = result.credential as? ASAuthorizationAppleIDCredential,
                  let identityToken = appleIDCredential.identityToken,
                  let identityTokenString = String(data: identityToken, encoding: .utf8) else {
                throw HybridAuthError.invalidAppleCredential
            }
            
            let credentials = OpenIDConnectCredentials(
                provider: .apple,
                idToken: identityTokenString
            )
            
            let session = try await supabase.client.auth.signInWithIdToken(credentials: credentials)
            
            // Migrate anonymous credits if any
            if case .anonymous = userState {
                try await HybridCreditManager.shared.migrateToAuthenticated(user: session.user)
            }
            
            userState = .authenticated(user: session.user)
            HybridCreditManager.shared.setUserState(userState)
            
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            throw error
        }
    }
    
    func signOut() async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            try await supabase.signOut()
            
            // Switch to anonymous state
            let deviceId = getOrCreateDeviceUUID()
            userState = .anonymous(deviceId: deviceId)
            HybridCreditManager.shared.setUserState(userState)
            
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            throw error
        }
    }
    
    // MARK: - Helper Methods
    
    private func getOrCreateDeviceUUID() -> String {
        if let existingUUID = UserDefaults.standard.string(forKey: "device_uuid_v1") {
            return existingUUID
        }
        
        let newUUID = UUID().uuidString
        UserDefaults.standard.set(newUUID, forKey: "device_uuid_v1")
        return newUUID
    }
    
    // MARK: - Computed Properties
    
    var isAuthenticated: Bool {
        return userState.isAuthenticated
    }
    
    var currentUser: User? {
        return userState.user
    }
    
    var deviceId: String? {
        return userState.deviceId
    }
    
    var identifier: String {
        return userState.identifier
    }
}

// MARK: - Apple Sign-In Delegate Wrapper

private class ASAuthorizationControllerDelegateWrapper: NSObject, ASAuthorizationControllerDelegate {
    private let continuation: CheckedContinuation<ASAuthorization, Error>
    
    init(continuation: CheckedContinuation<ASAuthorization, Error>) {
        self.continuation = continuation
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        continuation.resume(returning: authorization)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        continuation.resume(throwing: error)
    }
}

// MARK: - Error Management

extension HybridAuthService {
    func clearError() {
        errorMessage = nil
    }
}

// MARK: - Error Types

enum HybridAuthError: LocalizedError {
    case invalidAppleCredential
    case migrationFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidAppleCredential:
            return "Invalid Apple ID credential"
        case .migrationFailed:
            return "Failed to migrate anonymous data to authenticated account"
        }
    }
}
