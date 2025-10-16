//
//  AuthService.swift
//  noname_banana
//
//  Created by AI Assistant on 13.10.2025.
//

import Foundation
import Supabase
import Combine

@MainActor
class AuthService: ObservableObject {
    static let shared = AuthService()
    
    @Published var currentUser: User?
    @Published var isAuthenticated = false
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
    
    private func setupAuthStateListener() {
        authStateTask = Task {
            await supabase.client.auth.onAuthStateChange { [weak self] event, session in
                Task { @MainActor in
                    self?.currentUser = session?.user
                    self?.isAuthenticated = session != nil
                }
            }
        }
    }
    
    private func checkCurrentUser() {
        currentUser = supabase.getCurrentUser()
        isAuthenticated = currentUser != nil
    }
    
    // MARK: - Authentication Methods
    func signIn(email: String, password: String) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            try await supabase.signIn(email: email, password: password)
            // Auth state will be updated via listener
        } catch {
            errorMessage = error.localizedDescription
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
            throw error
        }
        
        isLoading = false
    }
    
    func signOut() async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            try await supabase.signOut()
            // Auth state will be updated via listener
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
        
        isLoading = false
    }
    
    func resetPassword(email: String) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            try await supabase.client.auth.resetPasswordForEmail(email)
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
        
        isLoading = false
    }
    
    // MARK: - User Info
    var userEmail: String? {
        return currentUser?.email
    }
    
    var userId: UUID? {
        return currentUser?.id
    }
    
    func clearError() {
        errorMessage = nil
    }
}
