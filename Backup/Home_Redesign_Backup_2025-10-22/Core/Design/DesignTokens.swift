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
    
    /// **Background Colors** - Adaptive to light/dark theme (Golden Premium Theme)
    struct Background {
        static func primary(_ colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? Color(hex: "1A1D29") : Color(hex: "F8F9FA")
        }
        
        static func secondary(_ colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? Color(hex: "2B3147") : Color(hex: "FFFFFF")
        }
        
        static func tertiary(_ colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? Color(hex: "363C52") : Color(hex: "F0F1F3")
        }
        
        static func elevated(_ colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? Color(hex: "363C52") : Color(hex: "FFFFFF")
        }
    }
    
    /// **Surface Colors** - For cards, modals, overlays (Golden Premium Theme)
    struct Surface {
        static func primary(_ colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? Color(hex: "2B3147") : Color(hex: "FFFFFF")
        }
        
        static func secondary(_ colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? Color(hex: "1A1D29") : Color(hex: "F8F9FA")
        }
        
        static func elevated(_ colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? Color(hex: "363C52") : Color(hex: "FFFFFF")
        }
        
        static func overlay(_ colorScheme: ColorScheme) -> Color {
            Color.black.opacity(colorScheme == .dark ? 0.6 : 0.4)
        }
        
        // Chat-specific surfaces
        static func messageBubbleIncoming(_ colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? Color(hex: "363C52") : Color(hex: "E9ECEF")
        }
        
        static func inputBackground(_ colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? Color(hex: "363C52") : Color(hex: "F0F1F3")
        }
        
        static func divider(_ colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? Color(hex: "3A4256") : Color(hex: "E1E4E8")
        }
        
        // New surface colors for better hierarchy
        static func subtleDivider(_ colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? Color(hex: "2E3446") : Color(hex: "F0F1F3")
        }
        
        static func strongBorder(_ colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? Color(hex: "4A5568") : Color(hex: "D1D5DB")
        }
        
        static func defaultBorder(_ colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? Color(hex: "374151") : Color(hex: "E5E7EB")
        }
    }
    
    /// **Brand Colors** - Golden Premium Theme (theme-aware)
    struct Brand {
        // Primary brand color - Golden theme
        static func primary(_ colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? Color(hex: "E5A820") : Color(hex: "F4B731")
        }
        
        // Secondary brand color - Success green
        static let secondary = Color(hex: "34C759")    // iOS Green (success)
        
        // Accent color - Golden theme
        static func accent(_ colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? Color(hex: "E5A820") : Color(hex: "F4B731")
        }
        
        // Warning color - Updated for better harmony
        static let warning = Color(hex: "FF4444")      // Softer red for better harmony
        
        // Additional brand colors
        static let teal = Color(hex: "33C3A4")         // Teal accent (keep existing)
        static let gold = Color(hex: "F4B731")         // Gold (Premium) - updated
        static let purple = Color(hex: "8B5CF6")       // Purple (Pro gradient) - softer
        static let lightBlue = Color(hex: "60A5FA")    // Light blue (Pro gradient) - softer
        
        // Interactive states for golden theme
        static func pressed(_ colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? Color(hex: "CC9318") : Color(hex: "D9A127")
        }
        
        static func hover(_ colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? Color(hex: "EDB929") : Color(hex: "F6C552")
        }
        
        static func disabled(_ colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? Color(hex: "E5A820").opacity(0.4) : Color(hex: "F4B731").opacity(0.4)
        }
        
        // Premium feature colors
        static let vipBadge = Color(hex: "F4B731")     // VIP Badge
        static let crownIcon = Color(hex: "EFBF04")    // Crown Icon
        static let goldShimmer = Color(hex: "FFFFFF")  // Gold Shimmer (with opacity)
    }
    
    /// **Text Colors** - Perfect contrast ratios (Golden Premium Theme)
    struct Text {
        static func primary(_ colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? Color.white : Color(hex: "1A1D29")
        }
        
        static func secondary(_ colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? Color(hex: "A8ADB8") : Color(hex: "666C7A")
        }
        
        static func tertiary(_ colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? Color(hex: "6B7280") : Color(hex: "8E95A3")
        }
        
        static func quaternary(_ colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? Color(hex: "6C6C70") : Color(hex: "C7C7CC")
        }
        
        static let inverse = Color.white  // Always white (for dark backgrounds)
        
        // Special text colors for specific use cases
        static func accent(_ colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? Color(hex: "E5A820") : Color(hex: "F4B731")
        }
        
        // Text on golden backgrounds (high contrast)
        static let onGold = Color(hex: "1A1D29")  // Dark text on gold buttons
        
        // Link text
        static func link(_ colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? Color(hex: "5DADE2") : Color(hex: "147EFB")
        }
    }
    
    /// **Semantic Colors** - Context-aware (Golden Premium Theme)
    struct Semantic {
        static let success = Color(hex: "34C759")     // Green (success)
        static let warning = Color(hex: "F4B731")     // Golden (warning - matches brand)
        static let error = Color(hex: "FF4444")       // Softer red (error)
        static let info = Color(hex: "60A5FA")        // Soft blue (info)
    }
    
    /// **Gradient Colors** - For premium/paywall (Golden Premium Theme)
    struct Gradients {
        // Premium gradients
        static let goldStart = Color(hex: "F4B731")
        static let goldEnd = Color(hex: "EFBF04")
        
        static func premiumStart(_ colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? Color(hex: "E5A820") : Color(hex: "F4B731")
        }
        
        static func premiumEnd(_ colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? Color(hex: "C89615") : Color(hex: "EFBF04")
        }
        
        // Sunset gold gradient
        static let sunsetStart = Color(hex: "F4B731")
        static let sunsetEnd = Color(hex: "FF9500")
        
        // Paywall gradients
        static func paywallStart(_ colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? Color(hex: "E5A820").opacity(0.2) : Color(hex: "F4B731").opacity(0.1)
        }
        
        static func paywallEnd(_ colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? Color(hex: "FF9500").opacity(0.2) : Color(hex: "FF9500").opacity(0.1)
        }
        
        // Gold shimmer effect
        static func goldShimmer(_ colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? Color(hex: "FFFFFF").opacity(0.6) : Color(hex: "FFFFFF").opacity(0.8)
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
    }
    
    // MARK: - 📳 Haptic System
    
    struct Haptics {
        private static let lightImpact = UIImpactFeedbackGenerator(style: .light)
        private static let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
        private static let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
        private static let notification = UINotificationFeedbackGenerator()
        private static let selection = UISelectionFeedbackGenerator()
        
        static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
            let generator: UIImpactFeedbackGenerator
            switch style {
            case .light:
                generator = lightImpact
            case .medium:
                generator = mediumImpact
            case .heavy:
                generator = heavyImpact
            case .soft:
                generator = lightImpact // Use light impact for soft
            case .rigid:
                generator = heavyImpact // Use heavy impact for rigid
            @unknown default:
                generator = mediumImpact
            }
            generator.prepare()
            generator.impactOccurred()
        }
        
        static func success() {
            notification.prepare()
            notification.notificationOccurred(.success)
        }
        
        static func warning() {
            notification.prepare()
            notification.notificationOccurred(.warning)
        }
        
        static func error() {
            notification.prepare()
            notification.notificationOccurred(.error)
        }
        
        static func selectionChanged() {
            selection.prepare()
            selection.selectionChanged()
        }
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
            DesignTokens.Haptics.impact(style)
        }
    }
    
    /// Apply success haptic
    func successHaptic() -> some View {
        self.onTapGesture {
            DesignTokens.Haptics.success()
        }
    }
}
