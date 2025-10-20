//
//  MockPaywallViewModel.swift
//  BananaUniverse
//
//  Created by AI Assistant on 14.10.2025.
//  ViewModel for paywall with mock purchase logic
//

import Foundation
import SwiftUI

@MainActor
class MockPaywallViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var products: [MockProduct] = []
    @Published var benefits: [MockBenefit] = []
    @Published var selectedProduct: MockProduct?
    @Published var isLoading = false
    @Published var isPurchasing = false
    @Published var showAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    @Published var variant: PaywallVariant = .equalLayout
    
    // MARK: - Private Properties
    
    private let mockData = MockPaywallData.shared
    
    // MARK: - Initialization
    
    init() {
        loadData()
    }
    
    // MARK: - Data Loading
    
    func loadData() {
        isLoading = true
        
        // Simulate network delay
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            
            await MainActor.run {
                self.products = self.mockData.allProducts
                self.benefits = self.mockData.benefits
                self.variant = self.mockData.getVariant()
                self.isLoading = false
            }
        }
    }
    
    // MARK: - Product Selection
    
    func selectProduct(_ product: MockProduct) {
        selectedProduct = product
    }
    
    func isProductSelected(_ product: MockProduct) -> Bool {
        selectedProduct?.id == product.id
    }
    
    // MARK: - Purchase Flow
    
    func purchaseSelectedProduct() async {
        guard let product = selectedProduct else {
            showError("paywall_error_product_not_found".localized)
            return
        }
        
        isPurchasing = true
        
        do {
            let result = try await mockData.simulatePurchase(product: product)
            
            await MainActor.run {
                self.isPurchasing = false
                self.showSuccess(result.message)
            }
            
        } catch {
            await MainActor.run {
                self.isPurchasing = false
                self.showError(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Restore Purchases
    
    func restorePurchases() async {
        isPurchasing = true
        
        do {
            let result = try await mockData.simulateRestore()
            
            await MainActor.run {
                self.isPurchasing = false
                self.showSuccess(result.message)
            }
            
        } catch {
            await MainActor.run {
                self.isPurchasing = false
                self.showError(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Alert Management
    
    private func showSuccess(_ message: String) {
        alertTitle = "paywall_success_title".localized
        alertMessage = message
        showAlert = true
    }
    
    private func showError(_ message: String) {
        alertTitle = "paywall_error_title".localized
        alertMessage = message
        showAlert = true
    }
    
    func dismissAlert() {
        showAlert = false
        alertTitle = ""
        alertMessage = ""
    }
    
    // MARK: - A/B Testing Helpers
    
    func shouldShowTrialBadge() -> Bool {
        mockData.shouldShowTrialBadge()
    }
    
    func shouldHighlightAnnual() -> Bool {
        mockData.shouldHighlightAnnual()
    }
    
    // MARK: - Computed Properties
    
    var canPurchase: Bool {
        selectedProduct != nil && !isPurchasing
    }
    
    var ctaButtonText: String {
        isPurchasing ? "paywall_cta_loading".localized : "paywall_cta_button".localized
    }
    
    var selectedProductPrice: String? {
        selectedProduct?.localizedPrice
    }
    
    // MARK: - Analytics (Mock)
    
    func trackPaywallView() {
        // In a real implementation, this would send analytics events
    }
    
    func trackProductSelected(_ product: MockProduct) {
    }
    
    func trackPurchaseAttempt(_ product: MockProduct) {
    }
    
    func trackPurchaseSuccess(_ product: MockProduct) {
    }
    
    func trackPurchaseFailure(_ product: MockProduct, error: Error) {
    }
    
    func trackRestoreAttempt() {
    }
    
    func trackRestoreSuccess() {
    }
    
    func trackRestoreFailure(_ error: Error) {
    }
}

// MARK: - Additional Localization Keys

extension MockPaywallViewModel {
    private var successTitle: String {
        "Success!"
    }
    
    private var errorTitle: String {
        "Error"
    }
}

