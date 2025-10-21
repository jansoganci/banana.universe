//
//  ProfileView.swift
//  noname_banana
//
//  Created by AI Assistant on 13.10.2025.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @ObservedObject private var authService = HybridAuthService.shared
    @StateObject private var creditManager = HybridCreditManager.shared
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showPaywall = false
    @State private var showSignIn = false
    @State private var showAI_Disclosure = false
    @State private var authStateRefreshTrigger = false
    @Environment(\.openURL) var openURL
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header Bar
                UnifiedHeaderBar(title: "Profile")
                
                // Main Content
                ScrollView {
                    profileContent
                        .id(authStateRefreshTrigger) // Force refresh when auth state changes
                }
            }
            .background(DesignTokens.Background.primary(themeManager.resolvedColorScheme))
            .navigationTitle("")
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showPaywall) {
            PreviewPaywallView()
        }
        .sheet(isPresented: $showSignIn) {
            SignInView()
        }
        .sheet(isPresented: $showAI_Disclosure) {
            AI_Disclosure_View()
        }
        .onReceive(authService.$userState) { newState in
            // Force UI refresh by toggling the trigger
            authStateRefreshTrigger.toggle()
            Task {
                await viewModel.onAuthStateChanged(newState)
            }
        }
        .onReceive(viewModel.$isPremiumUser) { newValue in
            #if DEBUG
            print("🔄 ProfileView: Premium status changed to \(newValue)")
            #endif
            // UI will automatically update due to @Published property
        }
        .alert("Restore Purchases", isPresented: $viewModel.showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.alertMessage)
        }
        .alert("Delete Account", isPresented: $viewModel.showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete Account", role: .destructive) {
                Task {
                    await viewModel.deleteAccount()
                }
            }
        } message: {
            VStack(spacing: 8) {
                Text("Are you sure you want to delete your account?")
                Text("This action cannot be undone. All your data, including processed images and credits, will be permanently deleted.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    @ViewBuilder
    private var profileContent: some View {
        VStack(spacing: 0) {
            // Pro Card
            ProCard(
                isProActive: viewModel.isPremiumUser,
                features: [
                    "Unlimited edits",
                    "Fast processing",
                    "No watermark"
                ],
                subscriptionStatusText: viewModel.getSubscriptionStatusText(),
                isLoadingSubscription: viewModel.isLoadingSubscription,
                onUpgradeTap: {
                    showPaywall = true
                    // TODO: insert Adapty Paywall ID here - placement: profile_upgrade
                },
                onManageTap: {
                    viewModel.openManageSubscription()
                },
                onRefreshTap: {
                    Task {
                        await viewModel.refreshSubscriptionDetails()
                    }
                }
            )
            .padding(.horizontal, DesignTokens.Spacing.md)
            .padding(.top, DesignTokens.Spacing.lg)
            
            // Premium Status Banner (for premium users)
            if viewModel.isPremiumUser {
                PremiumStatusBanner()
                    .padding(.horizontal, DesignTokens.Spacing.md)
                    .padding(.top, DesignTokens.Spacing.sm)
            }
            
            // Sign In or Create Account Button (for anonymous users)
            if !authService.isAuthenticated {
                Button {
                    showSignIn = true
                } label: {
                    HStack {
                        Image(systemName: "person.circle")
                            .font(.system(size: 18, weight: .medium))
                        Text("Sign In or Create Account")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(DesignTokens.Brand.primary(.light))
                    .cornerRadius(12)
                }
                .padding(.horizontal, DesignTokens.Spacing.md)
                .padding(.top, DesignTokens.Spacing.md)
            }
            
            // User State Section
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                VStack(spacing: 0) {
                    
                }
                .background(DesignTokens.Background.tertiary(themeManager.resolvedColorScheme))
                .cornerRadius(16)
                .padding(.horizontal, DesignTokens.Spacing.md)
                .padding(.bottom, DesignTokens.Spacing.sm)
            
            // Spacing between offer and account info (reduced)
            if authService.isAuthenticated {
                Spacer()
                    .frame(height: DesignTokens.Spacing.sm)
            }
                
                // User Info Section (for authenticated users)
                if authService.isAuthenticated {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                        Text("Account Info")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(DesignTokens.Text.secondary(themeManager.resolvedColorScheme))
                            .padding(.horizontal, DesignTokens.Spacing.md)
                            .padding(.top, DesignTokens.Spacing.md)
                        
                        VStack(spacing: 0) {
                            // User Email
                            HStack {
                                Image(systemName: "envelope")
                                    .font(.system(size: 20))
                                    .foregroundColor(DesignTokens.Brand.primary(.light))
                                    .frame(width: 24)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Email")
                                        .font(.system(size: 16))
                                        .foregroundColor(DesignTokens.Text.primary(themeManager.resolvedColorScheme))
                                    
                                    Text(authService.currentUser?.email ?? "Unknown")
                                        .font(.system(size: 14))
                                        .foregroundColor(DesignTokens.Text.secondary(themeManager.resolvedColorScheme))
                                }
                                
                                Spacer()
                            }
                            .padding(.horizontal, DesignTokens.Spacing.md)
                            .padding(.vertical, DesignTokens.Spacing.md)
                            
                            Divider()
                                .background(Color.white.opacity(0.06))
                            
                            // Quota Display
                            QuotaDisplayView(style: .detailed)
                            
                            Divider()
                                .background(Color.white.opacity(0.06))
                            
                            // Logout Button
                            Button(action: {
                                Task {
                                    try? await authService.signOut()
                                }
                            }) {
                                HStack(spacing: 16) {
                                    Image(systemName: "arrow.right.square")
                                        .font(.system(size: 20))
                                        .foregroundColor(DesignTokens.Semantic.warning)
                                        .frame(width: 24)
                                    
                                    Text("Sign Out")
                                        .font(.system(size: 16))
                                        .foregroundColor(DesignTokens.Semantic.warning)
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, DesignTokens.Spacing.md)
                                .frame(height: 50)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .background(DesignTokens.Background.tertiary(themeManager.resolvedColorScheme))
                        .cornerRadius(16)
                        .padding(.horizontal, DesignTokens.Spacing.md)
                        .padding(.bottom, DesignTokens.Spacing.sm)
                    }
                }
                
                // Spacing before Settings section (reduced)
                Spacer()
                    .frame(height: DesignTokens.Spacing.sm)
                
                // Settings Section
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                    Text("Settings")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(DesignTokens.Text.secondary(themeManager.resolvedColorScheme))
                        .padding(.horizontal, DesignTokens.Spacing.md)
                        .padding(.top, DesignTokens.Spacing.md)
                    
                    VStack(spacing: 0) {
                        SettingsRow(icon: "questionmark.circle", title: "Help & Support") {
                            if let url = URL(string: Config.supportURL) {
                                UIApplication.shared.open(url)
                            }
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.06))
                            .padding(.leading, 56)
                        
                        SettingsRow(icon: "doc.text", title: "Terms & Privacy") {
                            if let url = URL(string: Config.privacyPolicyURL) {
                                UIApplication.shared.open(url)
                            }
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.06))
                            .padding(.leading, 56)
                        
                        SettingsRow(icon: "brain.head.profile", title: "AI Service Disclosure") {
                            showAI_Disclosure = true
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.06))
                            .padding(.leading, 56)
                        
                        // Restore Purchases Button (always visible)
                        SettingsRow(icon: "arrow.clockwise", title: "Restore Purchases") {
                            Task {
                                await viewModel.restorePurchases()
                            }
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.06))
                            .padding(.leading, 56)
                        
                        // Theme Selector
                        HStack(spacing: 16) {
                            Image(systemName: "paintbrush.fill")
                                .font(.system(size: 20))
                                .foregroundColor(DesignTokens.Brand.primary(.light))
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Theme")
                                    .font(.system(size: 16))
                                    .foregroundColor(DesignTokens.Text.primary(themeManager.resolvedColorScheme))
                                
                                // Show subtitle only for Auto mode
                                if themeManager.preference == .system {
                                    Text("(Follow System)")
                                        .font(.system(size: 12))
                                        .foregroundColor(DesignTokens.Text.secondary(themeManager.resolvedColorScheme))
                                }
                            }
                            
                            Spacer()
                            
                            // Fixed dropdown picker with proper width and no background
                            Menu {
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        themeManager.preference = .light
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "sun.max.fill")
                                            .foregroundColor(.orange)
                                        Text("Light")
                                        if themeManager.preference == .light {
                                            Spacer()
                                            Image(systemName: "checkmark")
                                                .foregroundColor(DesignTokens.Brand.primary(.light))
                                        }
                                    }
                                }
                                
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        themeManager.preference = .dark
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "moon.fill")
                                            .foregroundColor(.blue)
                                        Text("Dark")
                                        if themeManager.preference == .dark {
                                            Spacer()
                                            Image(systemName: "checkmark")
                                                .foregroundColor(DesignTokens.Brand.primary(.light))
                                        }
                                    }
                                }
                                
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        themeManager.preference = .system
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "circle.lefthalf.filled")
                                            .foregroundColor(.gray)
                                        Text("Auto")
                                        if themeManager.preference == .system {
                                            Spacer()
                                            Image(systemName: "checkmark")
                                                .foregroundColor(DesignTokens.Brand.primary(.light))
                                        }
                                    }
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    // Theme icon
                                    Image(systemName: themeManager.preference.icon)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(DesignTokens.Brand.primary(.light))
                                    
                                    Text(themeManager.preference.displayName)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(DesignTokens.Text.primary(themeManager.resolvedColorScheme))
                                        .lineLimit(1)
                                        .fixedSize(horizontal: true, vertical: false)
                                    
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundColor(DesignTokens.Text.secondary(themeManager.resolvedColorScheme))
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .frame(minWidth: 80)
                            }
                            .menuStyle(BorderlessButtonMenuStyle())
                        }
                        .padding(.horizontal, DesignTokens.Spacing.md)
                        .frame(height: 50)
                        
                        // Only show Delete Account for authenticated users
                        if authService.isAuthenticated {
                            Divider()
                                .background(Color.white.opacity(0.06))
                                .padding(.leading, 56)
                            
                            Button(action: {
                                if !viewModel.isDeletingAccount {
                                    viewModel.showDeleteAccountConfirmation()
                                }
                            }) {
                                HStack(spacing: 16) {
                                    if viewModel.isDeletingAccount {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                            .frame(width: 24, height: 24)
                                    } else {
                                        Image(systemName: "trash")
                                            .font(.system(size: 20))
                                            .foregroundColor(DesignTokens.Semantic.error)
                                            .frame(width: 24)
                                    }
                                    
                                    Text(viewModel.isDeletingAccount ? "Deleting Account..." : "Delete Account")
                                        .font(.system(size: 16))
                                        .foregroundColor(DesignTokens.Semantic.error)
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, DesignTokens.Spacing.md)
                                .frame(height: 50)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .disabled(viewModel.isDeletingAccount)
                        }
                    }
                    .background(DesignTokens.Background.tertiary(themeManager.resolvedColorScheme))
                    .cornerRadius(16)
                    .padding(.horizontal, DesignTokens.Spacing.md)
                    .padding(.bottom, DesignTokens.Spacing.lg)
                }
            }
        }
    }
}

// MARK: - Pro Card Component
struct ProCard: View {
    let isProActive: Bool
    let features: [String]
    let subscriptionStatusText: String
    let isLoadingSubscription: Bool
    let onUpgradeTap: () -> Void
    let onManageTap: () -> Void
    let onRefreshTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(isProActive ? "Unlimited Mode" : "Upgrade to Pro")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(isProActive ? "You have unlimited access" : "Get unlimited edits")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                Image(systemName: "crown.fill")
                    .font(.system(size: 24))
                    .foregroundColor(DesignTokens.Brand.gold)
            }
            
            if !isProActive {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(features, id: \.self) { feature in
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(DesignTokens.Brand.secondary)
                            Text(feature)
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                }
                
                Button(action: onUpgradeTap) {
                    Text("Upgrade Now")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(DesignTokens.Brand.gold)
                        .cornerRadius(12)
                }
            } else {
                Button(action: onManageTap) {
                    Text("Manage Subscription")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(12)
                }
                
                // Subscription Status Display
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(subscriptionStatusText)
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        Button(action: onRefreshTap) {
                            if isLoadingSubscription {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }
                        .disabled(isLoadingSubscription)
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [DesignTokens.Brand.purple, DesignTokens.Brand.primary(.light)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
    }
}

// MARK: - Settings Row Component
struct SettingsRow: View {
    let icon: String
    let title: String
    let isDestructive: Bool
    let onTap: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    
    init(icon: String, title: String, isDestructive: Bool = false, onTap: @escaping () -> Void) {
        self.icon = icon
        self.title = title
        self.isDestructive = isDestructive
        self.onTap = onTap
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(isDestructive ? DesignTokens.Semantic.error : DesignTokens.Text.accent(themeManager.resolvedColorScheme))
                    .frame(width: 24)
                
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(isDestructive ? DesignTokens.Semantic.error : DesignTokens.Text.accent(themeManager.resolvedColorScheme))
                
                Spacer()
                
                if !isDestructive {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(DesignTokens.Text.quaternary(themeManager.resolvedColorScheme))
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.md)
            .frame(height: 50)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Premium Status Banner Component
struct PremiumStatusBanner: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "crown.fill")
                .font(.system(size: 16))
                .foregroundColor(DesignTokens.Brand.gold)
            
            Text("You're Premium! Enjoy unlimited access.")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(DesignTokens.Text.primary(themeManager.resolvedColorScheme))
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(DesignTokens.Brand.gold.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(DesignTokens.Brand.gold.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

#Preview {
    ProfileView()
        .environmentObject(ThemeManager())
}
