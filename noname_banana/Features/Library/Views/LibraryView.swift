//
//  LibraryView.swift
//  noname_banana
//
//  Created by AI Assistant on 13.10.2025.
//

import SwiftUI

struct LibraryView: View {
    @StateObject private var viewModel = LibraryViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header Bar
                UnifiedHeaderBar(
                    title: "History"
                )
                
                // Main Content
                if viewModel.isLoading && viewModel.historyItems.isEmpty {
                    // Loading State
                    LoadingView()
                } else if viewModel.historyItems.isEmpty {
                    // Empty State
                    EmptyHistoryView()
                } else {
                    // History List
                    HistoryList(
                        items: viewModel.historyItems,
                        isRefreshing: viewModel.isLoading,
                        onRefresh: { await viewModel.refreshHistory() },
                        onItemTap: { item in viewModel.navigateToResult(item) },
                        onRerun: { item in await viewModel.rerunJob(item) },
                        onShare: { item in viewModel.shareResult(item) },
                        onDelete: { item in await viewModel.deleteJob(item) }
                    )
                }
            }
            .background(Color(hex: "0E1012"))
            .navigationTitle("")
            .navigationBarHidden(true)
        }
        .onAppear {
            Task {
                await viewModel.loadHistory()
            }
        }
    }
}

// MARK: - Empty State View
struct EmptyHistoryView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock")
                .font(.system(size: 64))
                .foregroundColor(Color(hex: "6A6C6E"))
            
            Text("No editing history found")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(Color(hex: "C8DAFF"))
            
            Text("Your AI edits will appear here")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "A0A9B0"))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Loading View
struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: DesignTokens.Brand.primary))
                .scaleEffect(1.2)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - History List
struct HistoryList: View {
    let items: [HistoryItem]
    let isRefreshing: Bool
    let onRefresh: () async -> Void
    let onItemTap: (HistoryItem) -> Void
    let onRerun: (HistoryItem) async -> Void
    let onShare: (HistoryItem) -> Void
    let onDelete: (HistoryItem) async -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(items) { item in
                    HistoryItemRow(
                        item: item,
                        onTap: { onItemTap(item) },
                        onRerun: { Task { await onRerun(item) } },
                        onShare: { onShare(item) },
                        onDelete: { Task { await onDelete(item) } }
                    )
                    
                    // Divider
                    Rectangle()
                        .fill(Color.white.opacity(0.06))
                        .frame(height: 1)
                }
            }
        }
        .refreshable {
            await onRefresh()
        }
    }
}

// MARK: - History Item Row
struct HistoryItemRow: View {
    let item: HistoryItem
    let onTap: () -> Void
    let onRerun: () -> Void
    let onShare: () -> Void
    let onDelete: () -> Void
    
    @State private var showingDeleteAlert = false
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Thumbnail
                AsyncImage(url: item.thumbnailUrl) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color(hex: "2C2F32")
                }
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                // Info Section
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.effectTitle)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "C8DAFF"))
                        .lineLimit(1)
                    
                    // Status Badge
                    Text(item.status.displayText)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(item.status.badgeColor)
                        .cornerRadius(12)
                    
                    Text(item.relativeDate)
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "A0A9B0"))
                }
                
                Spacer()
                
                // Action Menu
                Menu {
                    Button {
                        onRerun()
                    } label: {
                        Label("Re-run", systemImage: "arrow.clockwise")
                    }
                    
                    Button {
                        onShare()
                    } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                    
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(DesignTokens.Text.secondary(.light))
                        .frame(width: 44, height: 44)
                }
            }
            .padding(.horizontal, spacingMD)
            .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle())
        .alert("Delete Edit", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("Are you sure you want to delete this edit from your history?")
        }
    }
}

// MARK: - History Item Model
struct HistoryItem: Identifiable, Codable {
    let id: String
    let thumbnailUrl: URL?
    let effectTitle: String
    let effectId: String
    let status: JobStatus
    let createdAt: Date
    let resultUrl: URL?
    let originalImageKey: String?
    
    var relativeDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
}

enum JobStatus: String, Codable {
    case completed
    case processing
    case failed
    case cancelled
    
    var displayText: String {
        switch self {
        case .completed: return "Completed"
        case .processing: return "Processing"
        case .failed: return "Failed"
        case .cancelled: return "Cancelled"
        }
    }
    
    var badgeColor: Color {
        switch self {
        case .completed: return Color(hex: "33C3A4")
        case .processing: return Color(hex: "4D7CFF")
        case .failed: return Color(hex: "FF4444")
        case .cancelled: return Color(hex: "A0A9B0")
        }
    }
}

// MARK: - View Model
@MainActor
class LibraryViewModel: ObservableObject {
    @Published var historyItems: [HistoryItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Mock data for testing - replace with actual API calls
    func loadHistory() async {
        isLoading = true
        
        // Simulate API call
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        // For now, show empty state - replace with actual API
        historyItems = []
        
        isLoading = false
    }
    
    func refreshHistory() async {
        await loadHistory()
    }
    
    func rerunJob(_ item: HistoryItem) async {
        // TODO: Implement re-run job logic
        print("Re-running job: \(item.id)")
    }
    
    func shareResult(_ item: HistoryItem) {
        // TODO: Implement share sheet
        print("Sharing result: \(item.id)")
    }
    
    func deleteJob(_ item: HistoryItem) async {
        // TODO: Implement delete with API
        historyItems.removeAll { $0.id == item.id }
    }
    
    func navigateToResult(_ item: HistoryItem) {
        // TODO: Navigate to ResultView
        print("Navigating to result: \(item.id)")
    }
}

#Preview {
    LibraryView()
}
