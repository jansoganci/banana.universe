//
//  AdaptyService.swift
//  noname_banana
//
//  Created by AI Assistant on 13.10.2025.
//

import Foundation
import Adapty

@MainActor
class AdaptyService: ObservableObject {
    static let shared = AdaptyService()
    
    @Published var paywall: AdaptyPaywall?
    @Published var products: [AdaptyPaywallProduct] = []
    @Published var profile: AdaptyProfile?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var isInitialized = false
    
    private init() {}
    
    // MARK: - Initialization
    func initialize() async throws {
        guard !isInitialized else { return }
        
        guard await Adapty.isActivated else {
            Config.debugLog("Waiting for Adapty activation...")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Adapty is already activated in App init, just get the profile
            profile = try await Adapty.getProfile()
            
            isInitialized = true
            isLoading = false
        } catch {
            let appError = AppError.from(error)
            errorMessage = appError.errorDescription ?? "Failed to initialize Adapty"
            isLoading = false
            throw appError
        }
    }
    
    // MARK: - Paywall Management
    func loadPaywall(placementId: String = "main_paywall") async throws {
        guard await Adapty.isActivated else {
            Config.debugLog("Waiting for Adapty activation...")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            paywall = try await Adapty.getPaywall(placementId: placementId)
            guard let paywall = paywall else {
                Config.debugLog("Paywall is nil after fetching")
                throw NSError(domain: "AdaptyService", code: 1002, userInfo: [NSLocalizedDescriptionKey: "Failed to load paywall"])
            }
            products = try await Adapty.getPaywallProducts(paywall: paywall)
            
            isLoading = false
        } catch {
            let appError = AppError.from(error)
            errorMessage = appError.errorDescription ?? "Failed to load paywall"
            isLoading = false
            throw appError
        }
    }
    
    // MARK: - Purchases
    func makePurchase(product: AdaptyPaywallProduct) async throws -> AdaptyProfile {
        guard await Adapty.isActivated else {
            Config.debugLog("Waiting for Adapty activation...")
            throw NSError(domain: "AdaptyService", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Adapty not activated"])
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await Adapty.makePurchase(product: product)
            profile = result.profile
            isLoading = false
            guard let profile = profile else {
                Config.debugLog("Profile is nil after purchase")
                throw NSError(domain: "AdaptyService", code: 1003, userInfo: [NSLocalizedDescriptionKey: "Purchase completed but profile is unavailable"])
            }
            return profile
        } catch {
            let appError = AppError.from(error)
            errorMessage = appError.errorDescription ?? "An error occurred"
            isLoading = false
            throw appError
        }
    }
    
    func restorePurchases() async throws -> AdaptyProfile {
        guard await Adapty.isActivated else {
            Config.debugLog("Waiting for Adapty activation...")
            throw NSError(domain: "AdaptyService", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Adapty not activated"])
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            profile = try await Adapty.restorePurchases()
            isLoading = false
            guard let profile = profile else {
                Config.debugLog("Profile is nil after restore")
                throw NSError(domain: "AdaptyService", code: 1004, userInfo: [NSLocalizedDescriptionKey: "Restore completed but profile is unavailable"])
            }
            return profile
        } catch {
            let appError = AppError.from(error)
            errorMessage = appError.errorDescription ?? "An error occurred"
            isLoading = false
            throw appError
        }
    }
    
    // MARK: - Subscription Status
    var isProUser: Bool {
        return profile?.accessLevels["pro"]?.isActive == true
    }
    
    var subscriptionTier: String {
        if isProUser {
            return "pro"
        }
        return "free"
    }
    
    var activeSubscription: AdaptyProfile.AccessLevel? {
        return profile?.accessLevels["pro"]
    }
    
    var subscriptionExpirationDate: Date? {
        return activeSubscription?.expiresAt
    }
    
    var isSubscriptionActive: Bool {
        guard let expiration = subscriptionExpirationDate else {
            return isProUser
        }
        return expiration > Date()
    }
    
    // MARK: - Product Info
    func getProductPrice(productId: String) -> String? {
        return products.first { $0.vendorProductId == productId }?.localizedPrice
    }
    
    func getProduct(productId: String) -> AdaptyPaywallProduct? {
        return products.first { $0.vendorProductId == productId }
    }
    
    // MARK: - Analytics
    func trackEvent(_ eventName: String, parameters: [String: Any]? = nil) {
        guard let paywall = paywall else {
            Config.debugLog("Cannot track event: paywall is nil")
            return
        }
        Adapty.logShowPaywall(paywall)
    }
    
    func trackPurchase(product: AdaptyPaywallProduct) {
        guard let paywall = paywall else {
            Config.debugLog("Cannot track purchase: paywall is nil")
            return
        }
        Adapty.logShowPaywall(paywall)
    }
    
    // MARK: - User Identification (for migration from anonymous to authenticated)
    func identify(userId: String) async throws {
        guard await Adapty.isActivated else {
            Config.debugLog("Waiting for Adapty activation...")
            throw NSError(domain: "AdaptyService", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Adapty not activated"])
        }
        
        do {
            try await Adapty.identify(userId)
            profile = try await Adapty.getProfile()
            Config.debugLog("User identified: \(userId)")
        } catch {
            Config.debugLog("Failed to identify user: \(error)")
            let appError = AppError.from(error)
            throw appError
        }
    }
    
    func logout() async throws {
        guard await Adapty.isActivated else {
            Config.debugLog("Waiting for Adapty activation...")
            throw NSError(domain: "AdaptyService", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Adapty not activated"])
        }
        
        do {
            try await Adapty.logout()
            profile = nil
            Config.debugLog("User logged out from Adapty")
        } catch {
            Config.debugLog("Failed to logout: \(error)")
            let appError = AppError.from(error)
            throw appError
        }
    }
    
    // MARK: - Error Handling
    func clearError() {
        errorMessage = nil
    }
}

// MARK: - Product Identifiers
extension AdaptyService {
    enum ProductId: String, CaseIterable {
        case weekly = "weekly_pro"
        case monthly = "monthly_pro"
        case annual = "annual_pro"
        
        var displayName: String {
            switch self {
            case .weekly:
                return "Weekly Pro"
            case .monthly:
                return "Monthly Pro"
            case .annual:
                return "Annual Pro"
            }
        }
    }
}
