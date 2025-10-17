//
//  HistoryItem.swift
//  noname_banana
//
//  Created by AI Assistant on 16.10.2025.
//  History item model for Library screen
//

import Foundation

// MARK: - History Item Model
struct HistoryItem: Identifiable, Codable {
    let id: String
    let thumbnailURL: URL?
    let effectTitle: String
    let effectId: String
    let status: JobStatus
    let createdAt: Date
    let resultURL: URL?
    let originalImageKey: String?
    
    var relativeDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
}
