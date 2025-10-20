//
//  HybridCreditManager_Legacy.swift
//  noname_banana
//
//  Created by AI Assistant on 14.10.2025.
//

// MARK: - Legacy Backup
// This is a frozen snapshot of the original HybridCreditManager system
// before the daily quota refactor (Date: 2025-01-27)
// Purpose: to preserve the pure credit-based logic for future reference.

import Foundation
import Supabase
import Combine
import Adapty

/// Manages credits for both anonymous and authenticated users
/// LEGACY VERSION - Preserved before daily quota refactor
@MainActor
class HybridCreditManagerLegacy: ObservableObject {
    static let shared = HybridCreditManagerLegacy()
    
    @Published var credits: Int = 0
    @Published var userState: UserState = .anonymous(deviceId: UUID().uuidString)
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Credit costs
    private let FREE_CREDITS = 10
    private let CREDIT_COST_PER_PROCESS = 1
    
    // Storage keys
    private let creditsKey = "hybrid_credits_v1"
    private let deviceUUIDKey = "device_uuid_v1"
    private let userStateKey = "user_state_v1"
    
    private let supabase: SupabaseService
    
    private init() {
        self.supabase = SupabaseService.shared
        loadUserState()
        loadCredits()
    }
    
    // MARK: - User State Management
    
    private func loadUserState() {
        if let data = UserDefaults.standard.data(forKey: userStateKey),
           let state = try? JSONDecoder().decode(UserState.self, from: data) {
            userState = state
        } else {
            // First time user - create anonymous state
            let deviceId = getOrCreateDeviceUUID()
            userState = .anonymous(deviceId: deviceId)
            saveUserState()
        }
    }
    
    private func saveUserState() {
        if let data = try? JSONEncoder().encode(userState) {
            UserDefaults.standard.set(data, forKey: userStateKey)
        }
    }
    
    func setUserState(_ newState: UserState) {
        userState = newState
        saveUserState()
        loadCredits()
    }
    
    // MARK: - Credit Management
    
    func loadCredits() {
        switch userState {
        case .anonymous(let deviceId):
            loadAnonymousCredits(deviceId: deviceId)
        case .authenticated(let user):
            Task {
                await loadAuthenticatedCredits(userId: user.id)
            }
        }
    }
    
    func hasCredits() -> Bool {
        return credits > 0
    }
    
    func spendCredit() async throws -> Bool {
        guard credits > 0 else {
            throw HybridCreditError.insufficientCredits
        }
        
        credits -= CREDIT_COST_PER_PROCESS
        
        switch userState {
        case .anonymous(let deviceId):
            saveAnonymousCredits(deviceId: deviceId)
        case .authenticated(let user):
            try await saveAuthenticatedCredits(userId: user.id)
        }
        
        return true
    }
    
    func addCredits(_ amount: Int, source: CreditSource) async throws {
        credits += amount
        
        switch userState {
        case .anonymous(let deviceId):
            saveAnonymousCredits(deviceId: deviceId)
        case .authenticated(let user):
            try await saveAuthenticatedCredits(userId: user.id)
        }
        
        Config.debugLog("Added \(amount) credits from \(source.rawValue). Total: \(credits)")
    }
    
    
    // MARK: - Anonymous User Credits
    
    private func loadAnonymousCredits(deviceId: String) {
        // Try to load from backend first
        Task {
            do {
                let result: [AnonymousCredits] = try await supabase.client
                    .from("anonymous_credits")
                    .select()
                    .eq("device_id", value: deviceId)
                    .execute()
                    .value
                
                if let anonymousCredits = result.first {
                    credits = anonymousCredits.credits
                    Config.debugLog("Loaded \(credits) anonymous credits from backend")
                } else {
                    // No backend record - check local storage
                    let localCredits = getLocalCredits(deviceId: deviceId)
                    if localCredits > 0 {
                        // Migrate local credits to backend
                        try await createAnonymousCreditsRecord(deviceId: deviceId, initialCredits: localCredits)
                        credits = localCredits
                    } else {
                        // New user - give free credits
                        credits = FREE_CREDITS
                        try await createAnonymousCreditsRecord(deviceId: deviceId, initialCredits: FREE_CREDITS)
                        Config.debugLog("Awarded \(FREE_CREDITS) free credits to new anonymous user")
                    }
                }
            } catch {
                Config.debugLog("Failed to load anonymous credits from backend: \(error)")
                // Fallback to local storage
                credits = getLocalCredits(deviceId: deviceId)
                if credits == 0 {
                    credits = FREE_CREDITS
                    saveLocalCredits(deviceId: deviceId)
                }
            }
        }
    }
    
    private func saveAnonymousCredits(deviceId: String) {
        // Save locally first
        saveLocalCredits(deviceId: deviceId)
        
        // Then sync to backend
        Task {
            do {
                try await updateAnonymousCreditsBackend(deviceId: deviceId)
            } catch {
                Config.debugLog("Failed to sync anonymous credits to backend: \(error)")
            }
        }
    }
    
    private func createAnonymousCreditsRecord(deviceId: String, initialCredits: Int) async throws {
        let anonymousCredits = AnonymousCredits(
            deviceId: deviceId,
            credits: initialCredits,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        try await supabase.client
            .from("anonymous_credits")
            .insert(anonymousCredits)
            .execute()
        
        Config.debugLog("Created anonymous credits record with \(initialCredits) credits")
    }
    
    private func updateAnonymousCreditsBackend(deviceId: String) async throws {
        try await supabase.client
            .from("anonymous_credits")
            .update(["credits": String(credits), "updated_at": Date().ISO8601Format()])
            .eq("device_id", value: deviceId)
            .execute()
        
        Config.debugLog("Updated anonymous credits in backend: \(credits)")
    }
    
    // MARK: - Authenticated User Credits
    
    private func loadAuthenticatedCredits(userId: UUID) async {
        do {
            let result: [UserCredits] = try await supabase.client
                .from("user_credits")
                .select()
                .eq("user_id", value: userId.uuidString)
                .execute()
                .value
            
            if let userCredits = result.first {
                credits = userCredits.credits
                Config.debugLog("Loaded \(credits) authenticated credits from backend")
            } else {
                // New authenticated user - create record
                try await createAuthenticatedCreditsRecord(userId: userId)
            }
        } catch {
            Config.debugLog("Failed to load authenticated credits from backend: \(error)")
            // Fallback to local storage
            credits = getLocalCredits(deviceId: userState.identifier)
        }
    }
    
    private func saveAuthenticatedCredits(userId: UUID) async throws {
        try await supabase.client
            .from("user_credits")
            .upsert([
                "user_id": userId.uuidString,
                "credits": String(credits),
                "updated_at": Date().ISO8601Format()
            ])
            .execute()
        
        Config.debugLog("Saved authenticated credits to backend: \(credits)")
    }
    
    private func createAuthenticatedCreditsRecord(userId: UUID) async throws {
        // Check if user has local credits to migrate
        let localCredits = getLocalCredits(deviceId: userState.identifier)
        let initialCredits = max(localCredits, FREE_CREDITS)
        
        try await supabase.client
            .from("user_credits")
            .insert([
                "user_id": userId.uuidString,
                "credits": String(initialCredits),
                "created_at": Date().ISO8601Format(),
                "updated_at": Date().ISO8601Format()
            ])
            .execute()
        
        credits = initialCredits
        Config.debugLog("Created authenticated credits record with \(initialCredits) credits")
    }
    
    // MARK: - Migration (Anonymous → Authenticated)
    
    func migrateToAuthenticated(user: User) async throws {
        guard case .anonymous(let deviceId) = userState else {
            throw HybridCreditError.alreadyAuthenticated
        }
        
        let localCredits = getLocalCredits(deviceId: deviceId)
        
        Config.debugLog("Migrating \(localCredits) anonymous credits to authenticated account")
        
        // Update user state
        userState = .authenticated(user: user)
        saveUserState()
        
        // Load authenticated credits (will create new record)
        await loadAuthenticatedCredits(userId: user.id)
        
        // Add migrated credits
        if localCredits > 0 {
            try await addCredits(localCredits, source: .migration)
        }
        
        // Clear local anonymous credits
        clearLocalCredits(deviceId: deviceId)
        
        Config.debugLog("Migration complete")
    }
    
    // MARK: - Local Storage Helpers
    
    func getDeviceUUID() -> String {
        return getOrCreateDeviceUUID()
    }
    
    private func getOrCreateDeviceUUID() -> String {
        if let existingUUID = UserDefaults.standard.string(forKey: deviceUUIDKey) {
            return existingUUID
        }
        
        let newUUID = UUID().uuidString
        UserDefaults.standard.set(newUUID, forKey: deviceUUIDKey)
        return newUUID
    }
    
    private func getLocalCredits(deviceId: String) -> Int {
        return UserDefaults.standard.integer(forKey: "\(creditsKey)_\(deviceId)")
    }
    
    private func saveLocalCredits(deviceId: String) {
        UserDefaults.standard.set(credits, forKey: "\(creditsKey)_\(deviceId)")
        Config.debugLog("Saved \(credits) credits locally for device: \(deviceId.prefix(8))...")
    }
    
    private func clearLocalCredits(deviceId: String) {
        UserDefaults.standard.removeObject(forKey: "\(creditsKey)_\(deviceId)")
    }
    
    // MARK: - Purchase Integration
    
    func purchaseCredits(product: AdaptyPaywallProduct) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let profile = try await AdaptyService.shared.makePurchase(product: product)
            let creditAmount = getCreditAmount(from: product)
            
            try await addCredits(creditAmount, source: .purchase)
            
            // Track purchase
            trackPurchase(product: product)
            
            isLoading = false
        } catch {
            let appError = AppError.from(error)
            errorMessage = appError.errorDescription ?? "Credit operation failed"
            isLoading = false
            throw error
        }
    }
    
    func restorePurchases() async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let profile = try await AdaptyService.shared.restorePurchases()
            let restoredCredits = try await calculateCreditsFromProfile(profile)
            
            credits = restoredCredits
            
            switch userState {
            case .anonymous(let deviceId):
                saveAnonymousCredits(deviceId: deviceId)
            case .authenticated(let user):
                try await saveAuthenticatedCredits(userId: user.id)
            }
            
            Config.debugLog("Restored \(restoredCredits) credits")
            isLoading = false
        } catch {
            let appError = AppError.from(error)
            errorMessage = appError.errorDescription ?? "Failed to restore purchases"
            isLoading = false
            throw error
        }
    }
    
    // MARK: - Helper Methods
    
    private func getCreditAmount(from product: AdaptyPaywallProduct) -> Int {
        let vendorId = product.vendorProductId
        
        if vendorId.contains("10") {
            return 10
        } else if vendorId.contains("50") {
            return 50
        } else if vendorId.contains("100") {
            return 100
        } else if vendorId.contains("500") {
            return 500
        }
        
        return 10
    }
    
    private func calculateCreditsFromProfile(_ profile: AdaptyProfile) async throws -> Int {
        if profile.accessLevels["pro"]?.isActive == true {
            return 9999
        }
        
        return credits
    }
    
    private func trackPurchase(product: AdaptyPaywallProduct) {
        UserDefaults.standard.set(true, forKey: "has_purchased")
        Config.debugLog("Purchase tracked: \(product.vendorProductId)")
    }
}

// MARK: - Models

struct AnonymousCredits: Codable {
    let deviceId: String
    let credits: Int
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case deviceId = "device_id"
        case credits
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct UserCredits: Codable {
    let userId: String
    let credits: Int
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case credits
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

enum CreditSource: String {
    case purchase = "purchase"
    case migration = "migration"
    case bonus = "bonus"
    case refund = "refund"
}

enum HybridCreditError: LocalizedError {
    case insufficientCredits
    case alreadyAuthenticated
    case migrationFailed
    case notAuthenticated
    
    var errorDescription: String? {
        switch self {
        case .insufficientCredits:
            return "You don't have enough credits. Purchase more to continue!"
        case .alreadyAuthenticated:
            return "User is already authenticated"
        case .migrationFailed:
            return "Failed to migrate your credits. Please contact support."
        case .notAuthenticated:
            return "Please sign in to sync your credits"
        }
    }
}
