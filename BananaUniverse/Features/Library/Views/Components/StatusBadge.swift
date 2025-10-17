//
//  StatusBadge.swift
//  noname_banana
//
//  Created by AI Assistant on 16.10.2025.
//  Status badge component for Library screen
//

import SwiftUI

// MARK: - Status Badge Component
struct StatusBadge: View {
    let status: JobStatus
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        Text(status.displayText)
            .font(DesignTokens.Typography.caption2)
            .foregroundColor(.white)
            .padding(.horizontal, DesignTokens.Spacing.sm)
            .padding(.vertical, DesignTokens.Spacing.xs)
            .background(status.badgeColor(for: themeManager.resolvedColorScheme))
            .cornerRadius(DesignTokens.CornerRadius.round)
            .accessibilityLabel("Status: \(status.displayText)")
            .accessibilityAddTraits(.isStaticText)
    }
}
