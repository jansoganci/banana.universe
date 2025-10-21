//
//  PreviewPaywallView.swift
//  BananaUniverse
//
//  Created by AI Assistant on 14.10.2025.
//  Preview paywall for App Store submission - replaces Adapty paywall temporarily
//

import SwiftUI

struct PreviewPaywallView: View {
    @StateObject private var viewModel = MockPaywallViewModel()
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                backgroundGradient
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Header section
                        headerSection
                        
                        // Benefits section
                        benefitsSection
                        
                        // Products section
                        if viewModel.isLoading {
                            loadingSection
                        } else {
                            productsSection
                        }
                        
                        // CTA button
                        ctaButton
                        
                        // Footer links
                        footerSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(DesignTokens.Text.primary(themeManager.resolvedColorScheme))
                }
            }
            .alert(viewModel.alertTitle, isPresented: $viewModel.showAlert) {
                Button("OK", role: .cancel) {
                    viewModel.dismissAlert()
                }
            } message: {
                Text(viewModel.alertMessage)
            }
            .onAppear {
                viewModel.trackPaywallView()
            }
        }
    }
    
    // MARK: - Background
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                DesignTokens.Background.primary(themeManager.resolvedColorScheme),
                DesignTokens.Background.secondary(themeManager.resolvedColorScheme)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            // Title
            Text("Unlock Full Power")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(DesignTokens.Text.primary(themeManager.resolvedColorScheme))
                .multilineTextAlignment(.center)
            
            // Subtitle
            Text("Get unlimited access to all premium features")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(DesignTokens.Text.secondary(themeManager.resolvedColorScheme))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }
    
    // MARK: - Benefits Section
    
    private var benefitsSection: some View {
        VStack(spacing: 20) {
            // Benefit 1
                            PreviewPaywallBenefitRow(
                icon: "sparkles",
                title: "Unlimited AI image edits",
                description: "Process as many images as you want"
            )
            .accessibilityLabel("Unlimited AI image edits. Process as many images as you want")
            .accessibilityHint("Premium benefit")
            
            // Benefit 2
                            PreviewPaywallBenefitRow(
                icon: "bolt.fill",
                title: "Faster processing priority",
                description: "Skip the queue and get results instantly"
            )
            .accessibilityLabel("Faster processing priority. Skip the queue and get results instantly")
            .accessibilityHint("Premium benefit")
            
            // Benefit 3
                            PreviewPaywallBenefitRow(
                icon: "star.fill",
                title: "Exclusive premium filters",
                description: "Access to advanced AI models and effects"
            )
            .accessibilityLabel("Exclusive premium filters. Access to advanced AI models and effects")
            .accessibilityHint("Premium benefit")
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.8))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
        )
    }
    
    // MARK: - Loading Section
    
    private var loadingSection: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(DesignTokens.Brand.accent(themeManager.resolvedColorScheme))
            
            Text("Loading products...")
                .font(.subheadline)
                .foregroundColor(DesignTokens.Text.secondary(themeManager.resolvedColorScheme))
        }
        .padding(DesignTokens.Spacing.xl)
    }
    
    // MARK: - Products Section
    
    private var productsSection: some View {
        HStack(spacing: 16) {
            // Weekly Product
                        PreviewPaywallProductCard(
                product: MockProduct(
                    id: "weekly_pro",
                    vendorProductId: "banana_weekly",
                    localizedTitle: "Weekly Pro",
                    localizedDescription: "Perfect for trying out premium features",
                    localizedPrice: "$4.99 / week",
                    price: NSDecimalNumber(string: "4.99"),
                    currencyCode: "USD",
                    subscriptionPeriod: "1 week",
                    trialPeriod: nil,
                    isTrialAvailable: false,
                    savings: nil
                ),
                isSelected: viewModel.selectedProduct?.id == "weekly_pro",
                shouldHighlight: false,
                shouldShowTrialBadge: false
            ) {
                let weeklyProduct = MockProduct(
                    id: "weekly_pro",
                    vendorProductId: "banana_weekly",
                    localizedTitle: "Weekly Pro",
                    localizedDescription: "Perfect for trying out premium features",
                    localizedPrice: "$4.99 / week",
                    price: NSDecimalNumber(string: "4.99"),
                    currencyCode: "USD",
                    subscriptionPeriod: "1 week",
                    trialPeriod: nil,
                    isTrialAvailable: false,
                    savings: nil
                )
                viewModel.selectProduct(weeklyProduct)
                viewModel.trackProductSelected(weeklyProduct)
            }
            .accessibilityLabel("Weekly Pro. Perfect for trying out premium features. $4.99 / week")
            .accessibilityHint("Subscription option")
            .accessibilityAddTraits(viewModel.selectedProduct?.id == "weekly_pro" ? .isSelected : [])
            
            // Yearly Product
                        PreviewPaywallProductCard(
                product: MockProduct(
                    id: "yearly_pro",
                    vendorProductId: "banana_yearly",
                    localizedTitle: "Yearly Pro",
                    localizedDescription: "Best value - save 70% compared to weekly",
                    localizedPrice: "$79.99 / year",
                    price: NSDecimalNumber(string: "79.99"),
                    currencyCode: "USD",
                    subscriptionPeriod: "1 year",
                    trialPeriod: "3 days",
                    isTrialAvailable: true,
                    savings: "Save 70%"
                ),
                isSelected: viewModel.selectedProduct?.id == "yearly_pro",
                shouldHighlight: viewModel.shouldHighlightAnnual(),
                shouldShowTrialBadge: viewModel.shouldShowTrialBadge()
            ) {
                let yearlyProduct = MockProduct(
                    id: "yearly_pro",
                    vendorProductId: "banana_yearly",
                    localizedTitle: "Yearly Pro",
                    localizedDescription: "Best value - save 70% compared to weekly",
                    localizedPrice: "$79.99 / year",
                    price: NSDecimalNumber(string: "79.99"),
                    currencyCode: "USD",
                    subscriptionPeriod: "1 year",
                    trialPeriod: "3 days",
                    isTrialAvailable: true,
                    savings: "Save 70%"
                )
                viewModel.selectProduct(yearlyProduct)
                viewModel.trackProductSelected(yearlyProduct)
            }
            .accessibilityLabel("Yearly Pro. Best value - save 70% compared to weekly. $79.99 / year")
            .accessibilityHint("Subscription option")
            .accessibilityAddTraits(viewModel.selectedProduct?.id == "yearly_pro" ? .isSelected : [])
        }
    }
    
    // MARK: - CTA Button
    
    private var ctaButton: some View {
        Button(action: {
            Task {
                guard let selectedProduct = viewModel.selectedProduct else {
                    return
                }
                viewModel.trackPurchaseAttempt(selectedProduct)
                await viewModel.purchaseSelectedProduct()
            }
        }) {
            HStack(spacing: 12) {
                if viewModel.isPurchasing {
                    ProgressView()
                        .scaleEffect(0.8)
                        .tint(.white)
                } else {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 18, weight: .semibold))
                }
                
                Text("Unlock Premium")
                    .font(.system(size: 18, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                LinearGradient(
                    colors: [DesignTokens.Brand.accent(themeManager.resolvedColorScheme), DesignTokens.Brand.accent(themeManager.resolvedColorScheme).opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: DesignTokens.Brand.accent(themeManager.resolvedColorScheme).opacity(0.3), radius: 12, x: 0, y: 6)
        }
        .disabled(!viewModel.canPurchase)
        .opacity(viewModel.canPurchase ? 1.0 : 0.6)
        .accessibilityLabel("Unlock Premium")
        .accessibilityHint("Tap to purchase selected product")
    }
    
    // MARK: - Footer Section
    
    private var footerSection: some View {
        VStack(spacing: 16) {
            // Restore purchases button
            Button(action: {
                Task {
                    viewModel.trackRestoreAttempt()
                    await viewModel.restorePurchases()
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14, weight: .medium))
                    Text("Restore Purchases")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(DesignTokens.Text.link(themeManager.resolvedColorScheme))
            }
            .accessibilityLabel("Restore Purchases")
            .accessibilityHint("Tap to restore previous purchases")
            
            // Legal links
            HStack(spacing: 24) {
                Button("Terms of Service") {
                    // In a real app, this would open Terms of Service
                }
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(DesignTokens.Text.link(themeManager.resolvedColorScheme))
                .accessibilityLabel("Terms of Service")
                
                Button("Privacy Policy") {
                    if let url = URL(string: Config.privacyPolicyURL) {
                        UIApplication.shared.open(url)
                    }
                }
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(DesignTokens.Text.link(themeManager.resolvedColorScheme))
                .accessibilityLabel("Privacy Policy")
            }
        }
        .padding(.bottom, 20)
    }
}

// MARK: - Benefit Row Component

struct PreviewPaywallBenefitRow: View {
    let icon: String
    let title: String
    let description: String
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(DesignTokens.Brand.accent(themeManager.resolvedColorScheme))
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(DesignTokens.Brand.accent(themeManager.resolvedColorScheme).opacity(0.1))
                )
            
            // Text content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "1A202C"))
                
                Text(description)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color(hex: "2D3748"))
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Product Card Component

struct PreviewPaywallProductCard: View {
    let product: MockProduct
    let isSelected: Bool
    let shouldHighlight: Bool
    let shouldShowTrialBadge: Bool
    let onTap: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // Header with title and badge
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(product.localizedTitle)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(hex: "1A202C"))
                        
                        Text(product.localizedDescription)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(DesignTokens.Text.secondary(themeManager.resolvedColorScheme))
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    // Trial badge
                    if shouldShowTrialBadge {
                        Text("3-Day Free Trial")
                            .font(.system(size: 11, weight: .bold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(6)
                    }
                }
                
                // Price and savings
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(product.localizedPrice)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(hex: "1A202C"))
                        
                        if let savings = product.savings {
                            Text(savings)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color.green)
                        }
                    }
                    
                    Spacer()
                    
                    // Selection indicator
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(DesignTokens.Brand.accent(themeManager.resolvedColorScheme))
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? DesignTokens.Brand.accent(themeManager.resolvedColorScheme) : (shouldHighlight ? Color.green : Color.clear),
                                lineWidth: isSelected ? 2 : (shouldHighlight ? 1 : 0)
                            )
                    )
            )
            .scaleEffect(shouldHighlight ? 1.02 : 1.0)
            .shadow(
                color: .black.opacity(0.08),
                radius: 8,
                x: 0,
                y: 4
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
        .animation(.easeInOut(duration: 0.2), value: shouldHighlight)
    }
}

// MARK: - Preview

#Preview("iPhone 14 Pro Max") {
    PreviewPaywallView()
        .environmentObject(ThemeManager())
}

#Preview("iPhone SE") {
    PreviewPaywallView()
        .environmentObject(ThemeManager())
}

#Preview("Dark Mode") {
    PreviewPaywallView()
        .environmentObject(ThemeManager())
        .preferredColorScheme(.dark)
}

