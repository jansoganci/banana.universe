//
//  HistoryList.swift
//  noname_banana
//
//  Created by AI Assistant on 16.10.2025.
//  History list component for Library screen
//

import SwiftUI

// MARK: - History List
struct HistoryList: View {
    let items: [HistoryItem]
    let isRefreshing: Bool
    let onRefresh: () async -> Void
    let onItemTap: (HistoryItem) -> Void
    let onRerun: (HistoryItem) async -> Void
    let onShare: (HistoryItem) -> Void
    let onDownload: (HistoryItem) async -> Void
    let onDelete: (HistoryItem) async -> Void
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(items) { item in
                    HistoryItemRow(
                        item: item,
                        onTap: { onItemTap(item) },
                        onRerun: { Task { await onRerun(item) } },
                        onShare: { onShare(item) },
                        onDownload: { Task { await onDownload(item) } },
                        onDelete: { Task { await onDelete(item) } }
                    )
                    
                    // Divider
                    Rectangle()
                        .fill(DesignTokens.Surface.divider(themeManager.resolvedColorScheme))
                        .frame(height: 1)
                }
            }
        }
        .refreshable {
            await onRefresh()
        }
        .accessibilityLabel("History list")
        .accessibilityHint("Swipe down to refresh")
    }
}
