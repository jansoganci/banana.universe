//
//  ToolCard.swift
//  noname_banana
//
//  Created by AI Assistant on 16.10.2025.
//  Reusable Tool Card Component
//

import SwiftUI

// MARK: - Tool Card Component
struct ToolCard: View {
    let tool: Tool
    let onTap: () -> Void
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        AppCard(onTap: onTap) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                // Title
                Text(tool.title)
                    .font(DesignTokens.Typography.headline)
                    .foregroundColor(DesignTokens.Text.primary(themeManager.resolvedColorScheme))
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                // Circular Preview - Clean and modern
                ZStack {
                    Circle()
                        .fill(DesignTokens.Brand.primary.opacity(0.1))
                        .frame(width: 100, height: 100)
                    
                    // Tool icon
                    Image(systemName: tool.placeholderIcon)
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(DesignTokens.Brand.primary)
                    
                    // PRO Lock Badge - Subtle but clear
                    if tool.requiresPro {
                        ZStack {
                            Circle()
                                .fill(DesignTokens.Brand.accent)
                                .frame(width: 20, height: 20)
                            
                            Image(systemName: "crown.fill")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .offset(x: 35, y: -35)
                    }
                }
                .frame(maxWidth: .infinity)
                
                Spacer()
            }
            .frame(height: 160)
        }
    }
}

#Preview {
    LazyVGrid(
        columns: [
            GridItem(.flexible(), spacing: 8),
            GridItem(.flexible(), spacing: 8)
        ],
        spacing: 8
    ) {
        ToolCard(
            tool: Tool(
                id: "remove_object",
                title: "Remove Object from Image",
                imageUrl: nil,
                category: "main_tools",
                requiresPro: false,
                modelName: "lama-cleaner",
                placeholderIcon: "eraser.fill",
                prompt: "Remove the selected object"
            ),
            onTap: {}
        )
        
        ToolCard(
            tool: Tool(
                id: "linkedin_headshot",
                title: "LinkedIn Headshot",
                imageUrl: nil,
                category: "pro_looks",
                requiresPro: true,
                modelName: "professional-headshot",
                placeholderIcon: "person.crop.square",
                prompt: "Create a professional LinkedIn headshot"
            ),
            onTap: {}
        )
    }
    .padding()
    .background(DesignTokens.Background.primary(.light))
    .environmentObject(ThemeManager())
}

