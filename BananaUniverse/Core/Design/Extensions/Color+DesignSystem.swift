//
//  Color+DesignSystem.swift
//  noname_banana
//
//  Created by AI Assistant on 13.10.2025.
//  Color extensions for the design system
//

import SwiftUI

// MARK: - Color Hex Initializer

extension Color {
    /// Initialize a Color from a hex string (e.g., "FF0000" for red)
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        
        self.init(
            red: Double((rgb & 0xFF0000) >> 16) / 255.0,
            green: Double((rgb & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgb & 0x0000FF) / 255.0
        )
    }
}

// MARK: - UIColor Hex Initializer (for UIKit components)

extension UIColor {
    /// Initialize a UIColor from a hex string (e.g., "FF0000" for red)
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: 1.0
        )
    }
    
    /// Convert SwiftUI Color to UIColor (for UIKit components like TabBar)
    convenience init(swiftUIColor: Color) {
        // Convert SwiftUI Color to UIColor
        let uiColor = UIColor(swiftUIColor)
        
        // Extract RGBA components
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

// NOTE: All color definitions have been moved to DesignTokens.swift for centralized management
