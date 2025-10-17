//
//  ProfileView.swift
//  noname_banana
//
//  Created by AI Assistant on 13.10.2025.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @StateObject private var authService = HybridAuthService.shared
    @StateObject private var creditManager = HybridCreditManager.shared
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showPaywall = false
    @State private var showSignIn = false
    @Environment(\.openURL) var openURL
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header Bar
                UnifiedHeaderBar(title: "Profile")
                
                // Main Content
                ScrollView {
                    profileContent
                }
            }
            .background(DesignTokens.Background.primary(themeManager.resolvedColorScheme))
            .navigationTitle("")
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
        .sheet(isPresented: $showSignIn) {
            SignInView()
        }
        .alert("Restore Purchases", isPresented: $viewModel.showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.alertMessage)
        }
    }
    
    @ViewBuilder
    private var profileContent: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            // Pro Card
            ProCard(
                isProActive: viewModel.isPRO,
                features: [
                    "Unlimited edits",
                    "Fast processing",
                    "No watermark"
                ],
                onUpgradeTap: {
                    showPaywall = true
                },
                onManageTap: {
                    viewModel.openManageSubscription()
                }
            )
            .padding(.horizontal, DesignTokens.Spacing.md)
            .padding(.top, DesignTokens.Spacing.lg)
            
            // Restore Purchases Button
            if !viewModel.isPRO {
                Button {
                    viewModel.restorePurchases()
                } label: {
                    Text("Restore Purchases")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(DesignTokens.Brand.primary(.light))
                }
                .padding(.top, DesignTokens.Spacing.sm)
            }
            
            // User State Section
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                Text("Account")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(DesignTokens.Text.secondary(themeManager.resolvedColorScheme))
                    .padding(.horizontal, DesignTokens.Spacing.md)
                    .padding(.top, DesignTokens.Spacing.lg)
                
                VStack(spacing: 0) {
                    // Credits Display
                    HStack {
                        Text("Credits:")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(DesignTokens.Text.primary(themeManager.resolvedColorScheme))
                        
                        Spacer()
                        
                        Text("\(creditManager.credits)")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(DesignTokens.Brand.primary(.light))
                    }
                    .padding(.horizontal, DesignTokens.Spacing.md)
                    .padding(.vertical, DesignTokens.Spacing.md)
                    
                    Divider()
                        .background(Color.white.opacity(0.06))
                    
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
                        
                        // Clean dropdown picker
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
                                
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundColor(DesignTokens.Text.secondary(themeManager.resolvedColorScheme))
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(DesignTokens.Surface.secondary(themeManager.resolvedColorScheme))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(DesignTokens.Brand.primary(.light).opacity(0.2), lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal, DesignTokens.Spacing.md)
                    .frame(height: 50)
                    
                    Divider()
                        .background(Color.white.opacity(0.06))
                        .padding(.leading, 56)
                    
                    // Unlimited Mode Toggle (Testing Feature)
                    HStack(spacing: 16) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 20))
                            .foregroundColor(DesignTokens.Brand.gold)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Unlimited Mode")
                                .font(.system(size: 16))
                                .foregroundColor(DesignTokens.Text.accent(themeManager.resolvedColorScheme))
                            
                            Text(creditManager.isUnlimitedMode ? "Simulating Premium User" : "For testing only")
                                .font(.system(size: 12))
                                .foregroundColor(DesignTokens.Text.secondary(themeManager.resolvedColorScheme))
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $creditManager.isUnlimitedMode)
                            .toggleStyle(SwitchToggleStyle(tint: DesignTokens.Brand.gold))
                            .onChange(of: creditManager.isUnlimitedMode) { value in
                                if value {
                                    creditManager.enableUnlimitedMode()
                                } else {
                                    creditManager.disableUnlimitedMode()
                                }
                            }
                    }
                    .padding(.horizontal, DesignTokens.Spacing.md)
                    .frame(height: 50)
                }
                .background(DesignTokens.Background.tertiary(themeManager.resolvedColorScheme))
                .cornerRadius(16)
                .padding(.horizontal, DesignTokens.Spacing.md)
                .padding(.bottom, DesignTokens.Spacing.lg)
                
                // Settings Section
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                    Text("Settings")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(DesignTokens.Text.secondary(themeManager.resolvedColorScheme))
                        .padding(.horizontal, DesignTokens.Spacing.md)
                        .padding(.top, DesignTokens.Spacing.lg)
                    
                    VStack(spacing: 0) {
                        SettingsRow(icon: "person.circle", title: "Account Settings") {
                            // Handle account settings
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.06))
                            .padding(.leading, 56)
                        
                        SettingsRow(icon: "bell", title: "Notifications") {
                            // Handle notifications
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.06))
                            .padding(.leading, 56)
                        
                        SettingsRow(icon: "questionmark.circle", title: "Help & Support") {
                            // Handle help
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.06))
                            .padding(.leading, 56)
                        
                        SettingsRow(icon: "doc.text", title: "Terms & Privacy") {
                            // Handle terms
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
    let onUpgradeTap: () -> Void
    let onManageTap: () -> Void
    
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
    let onTap: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(DesignTokens.Text.accent(themeManager.resolvedColorScheme))
                    .frame(width: 24)
                
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(DesignTokens.Text.accent(themeManager.resolvedColorScheme))
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(DesignTokens.Text.quaternary(themeManager.resolvedColorScheme))
            }
            .padding(.horizontal, DesignTokens.Spacing.md)
            .frame(height: 50)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ProfileView()
        .environmentObject(ThemeManager())
}
