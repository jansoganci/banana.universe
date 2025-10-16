//
//  PaywallView.swift
//  noname_banana
//
//  Created by AI Assistant on 13.10.2025.
//

import SwiftUI
import Adapty

struct PaywallView: View {
    @StateObject private var adaptyService = AdaptyService.shared
    @StateObject private var creditManager = HybridCreditManager.shared
    @StateObject private var authService = AuthService.shared
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var selectedProduct: AdaptyPaywallProduct?
    @State private var showQuickAuth = false
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var purchaseFlow: PurchaseFlow = .notStarted
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [DesignTokens.Gradients.paywallStart(themeManager.resolvedColorScheme), DesignTokens.Gradients.paywallEnd(themeManager.resolvedColorScheme)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Header
                        headerSection
                        
                        // Current credits display
                        creditsDisplaySection
                        
                        // Product cards
                        if adaptyService.isLoading {
                            ProgressView()
                                .scaleEffect(1.5)
                                .padding()
                        } else {
                            productsSection
                        }
                        
                        // Purchase flow section (Quick Sign-In vs Skip)
                        if purchaseFlow == .productSelected {
                            purchaseFlowSection
                        }
                        
                        // Restore button
                        Button(action: handleRestore) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("Restore Purchases")
                            }
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        }
                        .padding(.bottom, 20)
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .task {
                await loadPaywall()
            }
            .sheet(isPresented: $showQuickAuth) {
                QuickAuthView {
                    // On successful auth, proceed with purchase
                    proceedWithPurchase(isAuthenticated: true)
                }
            }
            .alert(alertTitle, isPresented: $showAlert) {
                Button("OK", role: .cancel) {
                    if alertTitle == "Success!" {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    // MARK: - View Sections
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "bolt.fill")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [DesignTokens.Brand.accent, DesignTokens.Semantic.error],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("Get More Credits")
                .font(.largeTitle)
                .bold()
            
            Text("Power up your AI image processing")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top, 20)
    }
    
    private var creditsDisplaySection: some View {
        HStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.title)
                .foregroundColor(DesignTokens.Brand.accent)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Current Credits")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("\(creditManager.credits)")
                    .font(.title)
                    .bold()
            }
            
            Spacer()
            
            if authService.isAuthenticated {
                Label("Synced", systemImage: "checkmark.icloud.fill")
                    .font(.caption)
                    .foregroundColor(DesignTokens.Brand.secondary)
            } else {
                Label("Local", systemImage: "iphone")
                    .font(.caption)
                    .foregroundColor(DesignTokens.Brand.accent)
            }
        }
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 10)
    }
    
    private var productsSection: some View {
        VStack(spacing: 16) {
            ForEach(adaptyService.products, id: \.vendorProductId) { product in
                ProductCard(
                    product: product,
                    isSelected: selectedProduct?.vendorProductId == product.vendorProductId
                ) {
                    handleProductSelection(product)
                }
            }
            
            if adaptyService.products.isEmpty {
                Text("No products available")
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
    }
    
    private var purchaseFlowSection: some View {
        VStack(spacing: 20) {
            // Divider
            Divider()
                .padding(.vertical, 8)
            
            Text("Choose how to continue")
                .font(.headline)
            
            // Option 1: Quick Sign-In (Recommended)
            Button(action: { showQuickAuth = true }) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Quick Sign-In")
                                .font(.headline)
                            
                            Text("RECOMMENDED")
                                .font(.caption2)
                                .bold()
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(DesignTokens.Brand.secondary)
                                .foregroundColor(.white)
                                .cornerRadius(4)
                        }
                        
                        Text("Sync credits across all devices + Get 20% bonus credits")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "icloud.and.arrow.up")
                        .font(.title2)
                }
                .padding()
                .background(DesignTokens.Brand.primary.opacity(0.1))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(DesignTokens.Brand.primary, lineWidth: 2)
                )
            }
            .buttonStyle(.plain)
            
            // Option 2: Skip and Purchase Anonymously
            Button(action: { proceedWithPurchase(isAuthenticated: false) }) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Skip for Now")
                            .font(.headline)
                        
                        Text("Purchase without signing in (device-only)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "arrow.right")
                        .font(.title3)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            
            // Info text
            Text("You can always sign in later to sync your credits")
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }
    
    // MARK: - Actions
    
    private func loadPaywall() async {
        do {
            try await adaptyService.loadPaywall(placementId: "main_paywall")
        } catch {
            alertTitle = "Error"
            alertMessage = "Failed to load products: \(error.localizedDescription)"
            showAlert = true
        }
    }
    
    private func handleProductSelection(_ product: AdaptyPaywallProduct) {
        selectedProduct = product
        withAnimation {
            purchaseFlow = .productSelected
        }
    }
    
    private func proceedWithPurchase(isAuthenticated: Bool) {
        guard let product = selectedProduct else { return }
        
        Task {
            do {
                purchaseFlow = .processing
                
                            // Make purchase through HybridCreditManager
                            try await creditManager.purchaseCredits(product: product)
                
                // Add bonus credits if authenticated
                if isAuthenticated {
                    let bonusCredits = getCreditAmount(from: product) / 5 // 20% bonus
                    try await creditManager.addCredits(bonusCredits, source: .bonus)
                }
                
                alertTitle = "Success!"
                alertMessage = isAuthenticated
                    ? "Credits purchased and synced! You got \(getCreditAmount(from: product)) + \(getCreditAmount(from: product) / 5) bonus credits."
                    : "Credits purchased! You got \(getCreditAmount(from: product)) credits."
                showAlert = true
                
                purchaseFlow = .completed
                
            } catch {
                alertTitle = "Purchase Failed"
                alertMessage = error.localizedDescription
                showAlert = true
                purchaseFlow = .failed
            }
        }
    }
    
    private func handleRestore() {
        Task {
            do {
                try await creditManager.restorePurchases()
                
                alertTitle = "Restored!"
                alertMessage = "Your purchases have been restored. You now have \(creditManager.credits) credits."
                showAlert = true
                
            } catch {
                alertTitle = "Restore Failed"
                alertMessage = error.localizedDescription
                showAlert = true
            }
        }
    }
    
    private func getCreditAmount(from product: AdaptyPaywallProduct) -> Int {
        let vendorId = product.vendorProductId
        if vendorId.contains("10") { return 10 }
        else if vendorId.contains("50") { return 50 }
        else if vendorId.contains("100") { return 100 }
        else if vendorId.contains("500") { return 500 }
        return 10
    }
}

// MARK: - Product Card Component

struct ProductCard: View {
    let product: AdaptyPaywallProduct
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(getProductTitle(product))
                        .font(.headline)
                    
                    Text(getProductSubtitle(product))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(product.localizedPrice ?? "$4.99")
                        .font(.title3)
                        .bold()
                    
                    if let savings = getSavingsText(product) {
                        Text(savings)
                            .font(.caption2)
                            .foregroundColor(DesignTokens.Brand.secondary)
                    }
                }
            }
            .padding()
            .background(isSelected ? DesignTokens.Brand.primary.opacity(0.15) : Color.white.opacity(0.8))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? DesignTokens.Brand.primary : Color.clear, lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.1), radius: 8)
        }
        .buttonStyle(.plain)
    }
    
    private func getProductTitle(_ product: AdaptyPaywallProduct) -> String {
        let id = product.vendorProductId
        if id.contains("10") { return "10 Credits" }
        else if id.contains("50") { return "50 Credits" }
        else if id.contains("100") { return "100 Credits" }
        else if id.contains("500") { return "500 Credits" }
        return "Credits Pack"
    }
    
    private func getProductSubtitle(_ product: AdaptyPaywallProduct) -> String {
        let id = product.vendorProductId
        if id.contains("10") { return "Perfect for trying out" }
        else if id.contains("50") { return "Most popular" }
        else if id.contains("100") { return "Best value" }
        else if id.contains("500") { return "Power user pack" }
        return "AI image processing credits"
    }
    
    private func getSavingsText(_ product: AdaptyPaywallProduct) -> String? {
        let id = product.vendorProductId
        if id.contains("100") { return "Save 30%" }
        else if id.contains("500") { return "Save 50%" }
        return nil
    }
}

// MARK: - Purchase Flow State

enum PurchaseFlow {
    case notStarted
    case productSelected
    case processing
    case completed
    case failed
}

// MARK: - Preview

#Preview {
    PaywallView()
}

