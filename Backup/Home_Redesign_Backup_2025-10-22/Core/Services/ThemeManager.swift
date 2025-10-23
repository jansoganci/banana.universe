//
//  ThemeManager.swift
//  noname_banana
//
//  Created by AI Assistant on 16.10.2025.
//  Theme management for light/dark mode support
//

import SwiftUI

// MARK: - Theme Preference Enum

enum ThemePreference: String, CaseIterable, Identifiable {
    case light = "Light"
    case dark = "Dark"
    case system = "Auto (Follow System)"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .light: return "Light"
        case .dark: return "Dark"
        case .system: return "Auto"
        }
    }
    
    var icon: String {
        switch self {
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        case .system: return "circle.lefthalf.filled"
        }
    }
}

// MARK: - Theme Manager

class ThemeManager: ObservableObject {
    
    // Persisted user preference (defaults to system)
    @AppStorage("themePreference") var preference: ThemePreference = .system
    
    // Current resolved color scheme
    @Published var resolvedColorScheme: ColorScheme = .light
    
    init() {
        // Will be updated when system scheme is available in ContentView
    }
    
    /// Resolves the actual color scheme based on user preference and system theme
    func resolveTheme(systemScheme: ColorScheme) -> ColorScheme {
        switch preference {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return systemScheme
        }
    }
    
    /// Updates the resolved color scheme (call when system scheme or preference changes)
    func updateResolvedScheme(systemScheme: ColorScheme) {
        let newScheme = resolveTheme(systemScheme: systemScheme)
        if resolvedColorScheme != newScheme {
            withAnimation(.easeInOut(duration: 0.3)) {
                resolvedColorScheme = newScheme
            }
        }
    }
}

