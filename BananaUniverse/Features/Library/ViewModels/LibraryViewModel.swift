//
//  LibraryViewModel.swift
//  noname_banana
//
//  Created by AI Assistant on 16.10.2025.
//  ViewModel for Library screen
//

import Foundation
import SwiftUI
import Photos
import PhotosUI

// MARK: - Library Error Types
enum LibraryError: LocalizedError {
    case loadFailed(String)
    case deleteFailed(String)
    case downloadFailed(String)
    case noQuotaRemaining
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .loadFailed(let message):
            return "Failed to load history: \(message)"
        case .deleteFailed(let message):
            return "Failed to delete item: \(message)"
        case .downloadFailed(let message):
            return "Failed to download image: \(message)"
        case .noQuotaRemaining:
            return "No credits remaining. Please upgrade to Pro for unlimited edits."
        case .networkError:
            return "Network error. Please check your connection and try again."
        }
    }
}

// MARK: - Library View Model
@MainActor
class LibraryViewModel: ObservableObject {
    @Published var historyItems: [HistoryItem] = []
    @Published var isLoading = false
    @Published var isRefreshing = false
    @Published var errorMessage: String?
    @Published var showingError = false
    @Published var selectedItem: HistoryItem?
    @Published var showingShareSheet = false
    @Published var showingDeleteConfirmation = false
    @Published var itemToDelete: HistoryItem?
    @Published var isDownloading = false
    @Published var downloadingItemID: String?
    
    // Services
    private let supabaseService: SupabaseService
    private let authService: HybridAuthService
    private let storageService: StorageService
    private let creditManager: HybridCreditManager
    
    // Image Cache
    private let imageCache = NSCache<NSString, UIImage>()
    
    // MARK: - Computed Properties
    
    var hasHistoryItems: Bool {
        !historyItems.isEmpty
    }
    
    var isLoadingOrRefreshing: Bool {
        isLoading || isRefreshing
    }
    
    var canPerformActions: Bool {
        !isLoadingOrRefreshing && hasHistoryItems
    }
    
    init(
        supabaseService: SupabaseService = .shared,
        authService: HybridAuthService = .shared,
        storageService: StorageService = .shared,
        creditManager: HybridCreditManager = .shared
    ) {
        self.supabaseService = supabaseService
        self.authService = authService
        self.storageService = storageService
        self.creditManager = creditManager
        
        // Configure image cache
        imageCache.countLimit = 50
        imageCache.totalCostLimit = 50 * 1024 * 1024 // 50MB
        
        // Add memory warning observer
        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.clearImageCache()
        }
    }
    
    func loadHistory() async {
        isLoading = true
        errorMessage = nil
        showingError = false
        
        do {
            // Get current user state
            let userState = authService.userState
            
            print("📚 [LibraryViewModel] Loading history for: \(userState.identifier)")
            
            // Fetch jobs from database
            let jobs = try await supabaseService.fetchUserJobs(
                userState: userState,
                limit: 50
            )
            
            print("✅ [LibraryViewModel] Fetched \(jobs.count) jobs")
            
            // Transform jobs to history items
            var newHistoryItems: [HistoryItem] = []
            for job in jobs {
                guard let completedAt = job.completedAt else { continue }
                
                let thumbnailURL = job.outputURL != nil ? await generateSignedURL(from: job.outputURL!) : nil
                let resultURL = job.outputURL != nil ? await generateSignedURL(from: job.outputURL!) : nil
                
                let historyItem = HistoryItem(
                    id: job.id.uuidString,
                    thumbnailURL: thumbnailURL,
                    effectTitle: extractEffectTitle(from: job),
                    effectId: job.model,
                    status: mapJobStatus(job.status),
                    createdAt: completedAt,
                    resultURL: resultURL,
                    originalImageKey: job.inputURL
                )
                newHistoryItems.append(historyItem)
            }
            
            // Update UI on main thread
            historyItems = newHistoryItems
            
            print("✅ [LibraryViewModel] Transformed to \(historyItems.count) history items")
            
        } catch {
            print("❌ [LibraryViewModel] Failed to load history: \(error)")
            let libraryError = LibraryError.loadFailed(error.localizedDescription)
            errorMessage = libraryError.errorDescription
            showingError = true
        }
        
        isLoading = false
    }
    
    func refreshHistory() async {
        isRefreshing = true
        await loadHistory()
        isRefreshing = false
    }
    
    func rerunJob(_ item: HistoryItem) async {
        print("🔄 [LibraryViewModel] Re-running job: \(item.id)")
        
        // Check if user has quota
        guard creditManager.hasCredits() else {
            let libraryError = LibraryError.noQuotaRemaining
            errorMessage = libraryError.errorDescription
            showingError = true
            return
        }
        
        // TODO: Implement re-run job logic
        // This would involve:
        // 1. Re-submitting the job with the same parameters
        // 2. Updating the item status to "processing"
        // 3. Polling for completion
        // 4. Updating the UI when complete
        
        print("✅ [LibraryViewModel] Job re-run initiated for: \(item.id)")
    }
    
    func shareResult(_ item: HistoryItem) {
        print("📤 [LibraryViewModel] Sharing result: \(item.id)")
        selectedItem = item
        showingShareSheet = true
    }
    
    func deleteJob(_ item: HistoryItem) async {
        print("🗑️ [LibraryViewModel] Deleting job: \(item.id)")
        
        // TODO: Implement proper delete with API
        // This would involve:
        // 1. Delete from database
        // 2. Delete from storage
        // 3. Update local state
        
        // For now, just remove from local array
        historyItems.removeAll { $0.id == item.id }
        
        print("✅ [LibraryViewModel] Job deleted successfully: \(item.id)")
    }
    
    func navigateToResult(_ item: HistoryItem) {
        print("🔍 [LibraryViewModel] Navigating to result: \(item.id)")
        selectedItem = item
        // TODO: Implement navigation to ResultView
        // This would involve:
        // 1. Setting up navigation state
        // 2. Passing the item data
        // 3. Presenting the result view
    }
    
    // MARK: - Error Handling
    
    func clearError() {
        errorMessage = nil
        showingError = false
    }
    
    func dismissShareSheet() {
        showingShareSheet = false
        selectedItem = nil
    }
    
    func confirmDelete() {
        guard let item = itemToDelete else { return }
        Task {
            await deleteJob(item)
        }
        itemToDelete = nil
        showingDeleteConfirmation = false
    }
    
    func cancelDelete() {
        itemToDelete = nil
        showingDeleteConfirmation = false
    }
    
    // MARK: - Helper Methods
    
    private func extractEffectTitle(from job: JobRecord) -> String {
        // Try to get from prompt first
        if let prompt = job.options?.prompt, !prompt.isEmpty {
            // Take first 40 chars of prompt as title
            let trimmed = String(prompt.prefix(40))
            return trimmed.count < prompt.count ? trimmed + "..." : trimmed
        }
        
        // Fallback to model name
        switch job.model {
        case "nano-banana-edit":
            return "AI Enhancement"
        case "upscale":
            return "Upscale"
        default:
            return job.model.capitalized
        }
    }
    
    private func mapJobStatus(_ status: String) -> JobStatus {
        switch status.lowercased() {
        case "completed":
            return .completed
        case "processing":
            return .processing
        case "failed":
            return .failed
        case "cancelled":
            return .cancelled
        default:
            return .failed
        }
    }
    
    func generateSignedURL(from path: String) async -> URL? {
        // Use proper Supabase signed URL generation
        do {
            let signedURLString = try await supabaseService.getSignedURL(for: path)
            print("✅ [LibraryViewModel] Generated signed URL for: \(path)")
            return URL(string: signedURLString)
        } catch {
            print("❌ [LibraryViewModel] Failed to generate signed URL for \(path): \(error)")
            // Fallback to public URL if signed URL fails
            let baseURL = "https://jiorfutbmahpfgplkats.supabase.co/storage/v1/object/public/\(Config.supabaseBucket)"
            let fullPath = "\(baseURL)/\(path)"
            return URL(string: fullPath)
        }
    }
    
    // MARK: - Download Functionality
    
    func downloadImage(_ item: HistoryItem) async {
        guard let resultURL = item.resultURL else {
            print("❌ [LibraryViewModel] No result URL available for download")
            return
        }
        
        // Set loading state
        isDownloading = true
        downloadingItemID = item.id
        
        print("📥 [LibraryViewModel] Starting download for: \(item.effectTitle)")
        
        do {
            // Download image data
            let (data, response) = try await URLSession.shared.data(from: resultURL)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                print("❌ [LibraryViewModel] Failed to download image: Invalid response")
                isDownloading = false
                downloadingItemID = nil
                return
            }
            
            // Save to Photos library
            try await saveImageToPhotos(data: data)
            
            print("✅ [LibraryViewModel] Successfully downloaded and saved image: \(item.effectTitle)")
            
        } catch {
            print("❌ [LibraryViewModel] Download failed: \(error)")
            // Show error to user
            errorMessage = "Failed to download image: \(error.localizedDescription)"
            showingError = true
        }
        
        // Clear loading state
        isDownloading = false
        downloadingItemID = nil
    }
    
    private func saveImageToPhotos(data: Data) async throws {
        // Request photo library permission
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        
        switch status {
        case .authorized, .limited:
            // Permission already granted, proceed with saving
            try await performPhotoSave(data: data)
            
        case .notDetermined:
            // Request permission
            let newStatus = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
            if newStatus == .authorized || newStatus == .limited {
                try await performPhotoSave(data: data)
            } else {
                print("❌ [LibraryViewModel] Photo library permission denied")
            }
            
        case .denied, .restricted:
            print("❌ [LibraryViewModel] Photo library access denied or restricted")
            
        @unknown default:
            print("❌ [LibraryViewModel] Unknown photo library authorization status")
        }
    }
    
    private func performPhotoSave(data: Data) async throws {
        try await withCheckedThrowingContinuation { continuation in
            PHPhotoLibrary.shared().performChanges({
                let creationRequest = PHAssetCreationRequest.forAsset()
                creationRequest.addResource(with: .photo, data: data, options: nil)
            }) { success, error in
                if success {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: error ?? LibraryError.downloadFailed("Unknown error saving to Photos"))
                }
            }
        }
    }
    
    // MARK: - Image Caching
    
    func getCachedImage(for url: URL) -> UIImage? {
        let key = NSString(string: url.absoluteString)
        return imageCache.object(forKey: key)
    }
    
    func cacheImage(_ image: UIImage, for url: URL) {
        let key = NSString(string: url.absoluteString)
        imageCache.setObject(image, forKey: key)
        print("📸 [LibraryViewModel] Cached image for: \(url.lastPathComponent)")
    }
    
    private func clearImageCache() {
        imageCache.removeAllObjects()
        print("🧹 [LibraryViewModel] Cleared image cache due to memory warning")
    }
}
