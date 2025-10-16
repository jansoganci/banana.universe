//
//  DesignTokens.swift
//  noname_banana
//
//  Created by AI Assistant on 14.10.2025.
//  Steve Jobs Inspired Design System - Think Different, Design Simple
//

import SwiftUI

// MARK: - 🎨 DESIGN TOKENS - Apple HIG Inspired

/// **Steve Jobs Philosophy**: "Simplicity is the ultimate sophistication"
/// This file contains all design tokens for consistent, beautiful UI
struct DesignTokens {
    
    // MARK: - 🌈 Color Palette (Apple HIG Compliant - Theme Aware)
    
    /// **Background Colors** - Adaptive to light/dark theme
    struct Background {
        static func primary(_ colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? Color(hex: "0E1012") : Color(hex: "F8F9FA")
        }
        
        static func secondary(_ colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? Color(hex: "1A1C1E") : Color(hex: "FFFFFF")
        }
        
        static func tertiary(_ colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? Color(hex: "2C2F32") : Color(hex: "F1F3F4")
        }
        
        static func elevated(_ colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? Color(hex: "2C2F32") : Color(hex: "FFFFFF")
        }
    }
    
    /// **Surface Colors** - For cards, modals, overlays
    struct Surface {
        static func primary(_ colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? Color(hex: "2C2F32") : Color(hex: "FFFFFF")
        }
        
        static func secondary(_ colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? Color(hex: "1A1C1E") : Color(hex: "F8F9FA")
        }
        
        static func elevated(_ colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? Color(hex: "3A3D40") : Color(hex: "FFFFFF")
        }
        
        static func overlay(_ colorScheme: ColorScheme) -> Color {
            Color.black.opacity(colorScheme == .dark ? 0.6 : 0.4)
        }
        
        // Chat-specific surfaces
        static func messageBubbleIncoming(_ colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? Color(hex: "3A3D40") : Color(hex: "E9ECEF")
        }
        
        static func inputBackground(_ colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? Color(hex: "2C2F32") : Color(hex: "F1F3F4")
        }
    }
    
    /// **Brand Colors** - Vibrant, purposeful (same in both themes)
    struct Brand {
        static let primary = Color(hex: "007AFF")      // iOS Blue
        static let secondary = Color(hex: "34C759")    // iOS Green (success)
        static let accent = Color(hex: "FF9500")       // iOS Orange (CTA)
        static let warning = Color(hex: "FF3B30")      // iOS Red (error)
        
        // Additional brand colors
        static let teal = Color(hex: "33C3A4")         // Teal accent
        static let gold = Color(hex: "FFD700")         // Gold (Premium)
        static let purple = Color(hex: "6A4CFF")       // Purple (Pro gradient)
        static let lightBlue = Color(hex: "4D7CFF")    // Light blue (Pro gradient)
    }
    
    /// **Text Colors** - Perfect contrast ratios (theme adaptive)
    struct Text {
        static func primary(_ colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? Color.white : Color(hex: "1C1C1E")
        }
        
        static func secondary(_ colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? Color(hex: "A0A9B0") : Color(hex: "3C3C43")
        }
        
        static func tertiary(_ colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? Color(hex: "8E8E93") : Color(hex: "8E8E93")
        }
        
        static func quaternary(_ colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? Color(hex: "6C6C70") : Color(hex: "C7C7CC")
        }
        
        static let inverse = Color.white  // Always white (for dark backgrounds)
        
        // Special text colors for specific use cases
        static func accent(_ colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? Color(hex: "C8DAFF") : Color(hex: "007AFF")
        }
    }
    
    /// **Semantic Colors** - Context-aware (same in both themes)
    struct Semantic {
        static let success = Color(hex: "34C759")
        static let warning = Color(hex: "FF9500")
        static let error = Color(hex: "FF3B30")
        static let info = Color(hex: "007AFF")
    }
    
    /// **Gradient Colors** - For premium/paywall
    struct Gradients {
        static let premiumStart = Color(hex: "6A4CFF")
        static let premiumEnd = Color(hex: "4D7CFF")
        
        static func paywallStart(_ colorScheme: ColorScheme) -> Color {
            Color.blue.opacity(colorScheme == .dark ? 0.2 : 0.1)
        }
        
        static func paywallEnd(_ colorScheme: ColorScheme) -> Color {
            Color.purple.opacity(colorScheme == .dark ? 0.2 : 0.1)
        }
    }
    
    // MARK: - 📏 Spacing System (8pt Grid)
    
    /// **Steve Jobs Rule**: "Every pixel matters"
    struct Spacing {
        static let xs: CGFloat = 4      // Micro spacing
        static let sm: CGFloat = 8      // Small spacing
        static let md: CGFloat = 16     // Medium spacing
        static let lg: CGFloat = 24     // Large spacing
        static let xl: CGFloat = 32     // Extra large spacing
        static let xxl: CGFloat = 48    // Huge spacing
    }
    
    // MARK: - 🔤 Typography System
    
    /// **Typography Scale** - iOS native fonts, perfect hierarchy
    struct Typography {
        // Headers
        static let largeTitle = Font.system(size: 34, weight: .bold, design: .default)
        static let title1 = Font.system(size: 28, weight: .bold, design: .default)
        static let title2 = Font.system(size: 22, weight: .bold, design: .default)
        static let title3 = Font.system(size: 20, weight: .semibold, design: .default)
        
        // Body
        static let headline = Font.system(size: 17, weight: .semibold, design: .default)
        static let body = Font.system(size: 17, weight: .regular, design: .default)
        static let callout = Font.system(size: 16, weight: .regular, design: .default)
        static let subheadline = Font.system(size: 15, weight: .regular, design: .default)
        static let footnote = Font.system(size: 13, weight: .regular, design: .default)
        static let caption1 = Font.system(size: 12, weight: .regular, design: .default)
        static let caption2 = Font.system(size: 11, weight: .regular, design: .default)
    }
    
    // MARK: - 🎭 Corner Radius System
    
    struct CornerRadius {
        static let xs: CGFloat = 4      // Small elements
        static let sm: CGFloat = 8      // Buttons, inputs
        static let md: CGFloat = 12     // Cards
        static let lg: CGFloat = 16     // Large cards
        static let xl: CGFloat = 20     // Modals
        static let round: CGFloat = 50  // Pills, circles
    }
    
    // MARK: - 🌟 Shadow System
    
    struct Shadow {
        static let none = Shadow(color: .clear, radius: 0, x: 0, y: 0)
        static let sm = Shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        static let md = Shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
        static let lg = Shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        static let xl = Shadow(color: .black.opacity(0.25), radius: 16, x: 0, y: 8)
        
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }
    
    // MARK: - ⚡ Animation System
    
    /// **Steve Jobs Rule**: "Animation should feel alive, not mechanical"
    struct Animation {
        // Timing curves - natural, organic
        static let quick = SwiftUI.Animation.easeInOut(duration: 0.2)
        static let smooth = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let gentle = SwiftUI.Animation.easeInOut(duration: 0.4)
        static let spring = SwiftUI.Animation.spring(response: 0.6, dampingFraction: 0.8)
        static let bouncy = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.6)
        
        // Haptic feedback
        static let hapticLight = UIImpactFeedbackGenerator(style: .light)
        static let hapticMedium = UIImpactFeedbackGenerator(style: .medium)
        static let hapticHeavy = UIImpactFeedbackGenerator(style: .heavy)
        static let hapticSuccess = UINotificationFeedbackGenerator()
    }
    
    // MARK: - 📱 Layout Constants
    
    struct Layout {
        static let headerHeight: CGFloat = 56
        static let tabBarHeight: CGFloat = 83
        static let inputHeight: CGFloat = 44
        static let buttonHeight: CGFloat = 44
        static let cardMinHeight: CGFloat = 120
        static let imageAspectRatio: CGFloat = 16/9
    }
}

// MARK: - 🎨 Color Extension for Hex Support
// Note: Color(hex:) initializer is already defined in Color+DesignSystem.swift

// MARK: - 🌟 View Modifiers for Consistent Styling

extension View {
    /// Apply shadow with design tokens
    func designShadow(_ shadow: DesignTokens.Shadow) -> some View {
        self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
    
    /// Apply haptic feedback
    func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) -> some View {
        self.onTapGesture {
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.impactOccurred()
        }
    }
    
    /// Apply success haptic
    func successHaptic() -> some View {
        self.onTapGesture {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }
}
