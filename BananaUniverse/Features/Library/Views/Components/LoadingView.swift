//
//  LoadingView.swift
//  noname_banana
//
//  Created by AI Assistant on 16.10.2025.
//  Loading state view for Library screen
//

import SwiftUI

// MARK: - Loading View
struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: DesignTokens.Brand.primary(.light)))
                .scaleEffect(1.2)
                .accessibilityLabel("Loading history")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
    }
}
