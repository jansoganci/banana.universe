//
//  StorageService.swift
//  noname_banana
//
//  Created by AI Assistant on 13.10.2025.
//

import Foundation
import UIKit
import Photos
import PhotosUI

@MainActor
class StorageService: ObservableObject {
    static let shared = StorageService()
    
    @Published var errorMessage: String?
    
    private let supabase: SupabaseService
    
    init(supabase: SupabaseService) {
        self.supabase = supabase
    }
    
    convenience init() {
        self.init(supabase: SupabaseService.shared)
    }
    
    // MARK: - Image Download
    func downloadImage(from path: String) async throws -> UIImage {
        errorMessage = nil
        
        do {
            let data = try await supabase.downloadImage(path: path)
            
            guard let image = UIImage(data: data) else {
                throw StorageError.invalidImage
            }
            
            return image
        } catch {
            let appError = AppError.from(error)
            errorMessage = appError.errorDescription ?? "Storage operation failed"
            throw appError
        }
    }
    
    // MARK: - Photos Library
    func saveToPhotos(_ image: UIImage) async throws {
        errorMessage = nil
        
        do {
            try await PHPhotoLibrary.shared().performChanges {
                PHAssetCreationRequest.creationRequestForAsset(from: image)
            }
        } catch {
            let appError = AppError.from(error)
            errorMessage = appError.errorDescription ?? "Storage operation failed"
            throw appError
        }
    }
    
    func requestPhotoLibraryPermission() async -> Bool {
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        
        switch status {
        case .authorized, .limited:
            return true
        case .notDetermined:
            let newStatus = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
            return newStatus == .authorized || newStatus == .limited
        case .denied, .restricted:
            return false
        @unknown default:
            return false
        }
    }
    
    // MARK: - Image Processing
    func compressImage(_ image: UIImage, maxSize: CGSize = CGSize(width: 1024, height: 1024)) -> UIImage {
        let size = image.size
        
        // Calculate scaling factor
        let widthScale = maxSize.width / size.width
        let heightScale = maxSize.height / size.height
        let scale = min(widthScale, heightScale, 1.0)
        
        // Skip if no scaling needed
        if scale >= 1.0 {
            return image
        }
        
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        defer { UIGraphicsEndImageContext() }
        
        image.draw(in: CGRect(origin: .zero, size: newSize))
        
        return UIGraphicsGetImageFromCurrentImageContext() ?? image
    }
    
    // MARK: - Share Image
    func shareImage(_ image: UIImage) -> UIActivityViewController {
        let activityViewController = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        
        // Configure for iPad
        if let popover = activityViewController.popoverPresentationController {
            popover.sourceView = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }
            popover.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        return activityViewController
    }
    
    func clearError() {
        errorMessage = nil
    }
}

// MARK: - Errors
enum StorageError: Error {
    case invalidImage
    case saveFailed
    case permissionDenied
    case uploadFailed
    
    var localizedDescription: String {
        switch self {
        case .invalidImage:
            return "Invalid image data"
        case .saveFailed:
            return "Failed to save image to Photos"
        case .permissionDenied:
            return "Photo library access denied"
        case .uploadFailed:
            return "Failed to upload image"
        }
    }
}
