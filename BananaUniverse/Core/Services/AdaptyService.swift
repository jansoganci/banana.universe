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
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Initialize Adapty with your public SDK key
            try await Adapty.activate("YOUR_ADAPTY_PUBLIC_KEY") // Replace with actual key
            
            // Get initial profile
            profile = try await Adapty.getProfile()
            
            isInitialized = true
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            throw error
        }
    }
    
    // MARK: - Paywall Management
    func loadPaywall(placementId: String = "main_paywall") async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            paywall = try await Adapty.getPaywall(placementId: placementId)
            products = try await Adapty.getPaywallProducts(paywall: paywall!)
            
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            throw error
        }
    }
    
    // MARK: - Purchases
    func makePurchase(product: AdaptyPaywallProduct) async throws -> AdaptyProfile {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await Adapty.makePurchase(product: product)
            profile = result.profile
            isLoading = false
            return profile!
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            throw error
        }
    }
    
    func restorePurchases() async throws -> AdaptyProfile {
        isLoading = true
        errorMessage = nil
        
        do {
            profile = try await Adapty.restorePurchases()
            isLoading = false
            return profile!
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            throw error
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
        Adapty.logShowPaywall(paywall!)
    }
    
    func trackPurchase(product: AdaptyPaywallProduct) {
        Adapty.logShowPaywall(paywall!)
    }
    
    // MARK: - User Identification (for migration from anonymous to authenticated)
    func identify(userId: String) async throws {
        do {
            try await Adapty.identify(userId)
            profile = try await Adapty.getProfile()
            print("✅ [AdaptyService] User identified: \(userId)")
        } catch {
            print("⚠️ [AdaptyService] Failed to identify user: \(error)")
            throw error
        }
    }
    
    func logout() async throws {
        do {
            try await Adapty.logout()
            profile = nil
            print("✅ [AdaptyService] User logged out from Adapty")
        } catch {
            print("⚠️ [AdaptyService] Failed to logout: \(error)")
            throw error
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
