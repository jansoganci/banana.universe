//
//  HomeView.swift
//  noname_banana
//
//  Created by AI Assistant on 13.10.2025.
//

import SwiftUI

struct HomeView: View {
    @State private var selectedCategory: String = "main_tools"
    @State private var showPaywall = false
    @StateObject private var authService = HybridAuthService.shared
    @StateObject private var creditManager = HybridCreditManager.shared
    @EnvironmentObject var themeManager: ThemeManager
    let onToolSelected: (String) -> Void // Callback for tool selection
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header Bar
                UnifiedHeaderBar(
                    title: "",
                    leftContent: .appLogo(32),
                    rightContent: .getProButton({ 
                        showPaywall = true
                        // TODO: insert Adapty Paywall ID here - placement: home_get_pro
                    })
                )
                
                // Category Tabs
                CategoryTabs(
                    selectedCategory: $selectedCategory
                )
                
                // Tools Grid
                ScrollView {
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: DesignTokens.Spacing.sm),
                            GridItem(.flexible(), spacing: DesignTokens.Spacing.sm)
                        ],
                        spacing: DesignTokens.Spacing.sm
                    ) {
                        ForEach(currentTools) { tool in
                            ToolCard(
                                tool: tool,
                                onTap: { handleToolTap(tool) },
                                showPremiumBadge: shouldShowPremiumBadge
                            )
                        }
                    }
                    .padding(.horizontal, DesignTokens.Spacing.md)
                    .padding(.top, DesignTokens.Spacing.md)
                    .padding(.bottom, DesignTokens.Spacing.lg)
                }
            }
            .background(DesignTokens.Background.primary(themeManager.resolvedColorScheme))
            .navigationTitle("")
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }
    
    private var currentTools: [Tool] {
        switch selectedCategory {
        case "main_tools":
            return Tool.mainTools
        case "pro_looks":
            return Tool.proLooksTools
        case "restoration":
            return Tool.restorationTools
        default:
            return Tool.mainTools
        }
    }
    
    private var shouldShowPremiumBadge: Bool {
        // Hide badges for premium-only sections to reduce visual clutter
        switch selectedCategory {
        case "pro_looks":
            return false // All Pro Looks tools are premium, no need for individual badges
        default:
            return true // Show badges for mixed sections (Main Tools, Restoration)
        }
    }
    
    private func handleToolTap(_ tool: Tool) {
        if tool.requiresPro {
            showPaywall = true
            // TODO: insert Adapty Paywall ID here - placement: home_tool_lock
        } else {
            // Navigate to Chat tab with the tool's prompt
            onToolSelected(tool.prompt)
        }
    }
}

// MARK: - Category Tabs Component
struct CategoryTabs: View {
    @Binding var selectedCategory: String
    @EnvironmentObject var themeManager: ThemeManager
    
    private let categories = [
        (id: "main_tools", icon: "wrench.and.screwdriver", label: "Main Tools"),
        (id: "pro_looks", icon: "camera.fill", label: "Pro Looks"),
        (id: "restoration", icon: "arrow.triangle.2.circlepath", label: "Restoration")
    ]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignTokens.Spacing.sm) {
                ForEach(categories, id: \.id) { category in
                    TabButton(
                        icon: category.icon,
                        label: category.label,
                        isActive: selectedCategory == category.id,
                        onTap: {
                            withAnimation {
                                selectedCategory = category.id
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.md)
            .padding(.vertical, DesignTokens.Spacing.sm)
        }
        .background(DesignTokens.Background.primary(themeManager.resolvedColorScheme))
    }
}

#Preview {
    HomeView(onToolSelected: { _ in })
        .environmentObject(ThemeManager())
}
