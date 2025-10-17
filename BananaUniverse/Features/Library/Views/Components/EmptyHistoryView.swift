//
//  EmptyHistoryView.swift
//  noname_banana
//
//  Created by AI Assistant on 16.10.2025.
//  Empty state view for Library screen
//

import SwiftUI

// MARK: - Empty State View
struct EmptyHistoryView: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            Image(systemName: "clock")
                .font(.system(size: 64))
                .foregroundColor(DesignTokens.Text.tertiary(themeManager.resolvedColorScheme))
                .accessibilityHidden(true)
            
            Text("No editing history found")
                .font(DesignTokens.Typography.title3)
                .foregroundColor(DesignTokens.Text.accent(themeManager.resolvedColorScheme))
                .accessibilityAddTraits(.isHeader)
            
            Text("Your AI edits will appear here")
                .font(DesignTokens.Typography.callout)
                .foregroundColor(DesignTokens.Text.secondary(themeManager.resolvedColorScheme))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("No editing history found. Your AI edits will appear here.")
    }
}
