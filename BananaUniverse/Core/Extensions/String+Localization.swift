//
//  String+Localization.swift
//  BananaUniverse
//
//  Created by AI Assistant on 14.10.2025.
//  String localization extension for easy access
//

import Foundation

extension String {
    /// Localized string using NSLocalizedString
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
    
    /// Localized string with format arguments
    func localized(_ arguments: CVarArg...) -> String {
        String(format: localized, arguments: arguments)
    }
    
    /// Localized string with specific table name
    func localized(tableName: String? = nil, bundle: Bundle = .main) -> String {
        NSLocalizedString(self, tableName: tableName, bundle: bundle, comment: "")
    }
}

