//
//  UnifiedHeaderBar.swift
//  BananaUniverse
//
//  Created by AI Assistant on 14.10.2025.
//

import SwiftUI

// MARK: - Unified Header Bar Component
struct UnifiedHeaderBar: View {
    let title: String
    let leftContent: HeaderContent?
    let rightContent: HeaderContent?
    
    @EnvironmentObject var themeManager: ThemeManager
    
    init(
        title: String,
        leftContent: HeaderContent? = nil,
        rightContent: HeaderContent? = nil
    ) {
        self.title = title
        self.leftContent = leftContent
        self.rightContent = rightContent
    }
    
    var body: some View {
        HStack(spacing: 8) {
            // Left Content
            if let left = leftContent {
                headerContentView(left)
            }
            
            // Center Title
            Spacer()
            if !title.isEmpty {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(DesignTokens.Text.primary(themeManager.resolvedColorScheme))
                Spacer()
            }
            
            // Right Content
            if let right = rightContent {
                headerContentView(right)
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
        .padding(.top, DesignTokens.Spacing.sm)
        .frame(height: DesignTokens.Layout.headerHeight)
        .background(DesignTokens.Surface.primary(themeManager.resolvedColorScheme))
        .designShadow(DesignTokens.Shadow.sm)
    }
    
    @ViewBuilder
    private func headerContentView(_ content: HeaderContent) -> some View {
        switch content {
        case .brandLogo(let brandName):
            HStack(spacing: 6) {
                Text("🍌")
                    .font(.system(size: 18))
                
                Text(brandName)
                    .font(DesignTokens.Typography.headline)
                    .foregroundColor(DesignTokens.Text.primary(themeManager.resolvedColorScheme))
            }
            
        case .appLogo(let size):
            AppLogo(size: size)
            
        case .getProButton(let action):
            Button(action: action) {
                HStack(spacing: 4) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 10))
                    Text("Get PRO")
                        .font(DesignTokens.Typography.caption1)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, DesignTokens.Spacing.md)
                .padding(.vertical, DesignTokens.Spacing.sm)
                .background(DesignTokens.Brand.primary(.light))
                .cornerRadius(DesignTokens.CornerRadius.round)
            }
            
        case .quotaBadge(let quota, let action):
            Button(action: action) {
                Text("\(quota) Free Edits")
                    .font(DesignTokens.Typography.caption1)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .padding(.horizontal, DesignTokens.Spacing.md)
                    .padding(.vertical, DesignTokens.Spacing.sm)
                    .background(DesignTokens.Brand.secondary)
                    .cornerRadius(DesignTokens.CornerRadius.round)
            }
            
        case .unlimitedBadge(let action):
            Button(action: action) {
                HStack(spacing: 6) {
                    Image(systemName: "infinity")
                        .font(.system(size: 12, weight: .semibold))
                    
                    Text("Unlimited")
                        .font(DesignTokens.Typography.caption1)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .lineLimit(1)
                .padding(.horizontal, DesignTokens.Spacing.md)
                .padding(.vertical, DesignTokens.Spacing.sm)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "FFD700"), Color(hex: "FFA500")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(DesignTokens.CornerRadius.round)
            }
            
        case .empty:
            EmptyView()
        }
    }
}

// MARK: - Header Content Types
enum HeaderContent {
    case brandLogo(String)
    case appLogo(CGFloat)
    case getProButton(() -> Void)
    case quotaBadge(Int, () -> Void)
    case unlimitedBadge(() -> Void)
    case empty
}

#Preview {
    VStack(spacing: 0) {
        // Home style
        UnifiedHeaderBar(
            title: "Banana Universe",
            leftContent: .brandLogo("Banana Universe"),
            rightContent: .getProButton({})
        )
        
        // Chat style - Free user
        UnifiedHeaderBar(
            title: "Banana Universe",
            leftContent: .brandLogo("Banana Universe"),
            rightContent: .quotaBadge(3, {})
        )
        
        // Chat style - Unlimited mode with App Logo
        UnifiedHeaderBar(
            title: "",
            leftContent: .appLogo(32),
            rightContent: .unlimitedBadge({})
        )
        
        // Library/Profile style
        UnifiedHeaderBar(
            title: "History",
            leftContent: nil,
            rightContent: nil
        )
    }
}

