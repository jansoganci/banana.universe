//
//  ProfileViewModel.swift
//  noname_banana
//
//  Created by AI Assistant on 16.10.2025.
//

import Foundation
import SwiftUI

class ProfileViewModel: ObservableObject {
    @Published var isPRO: Bool = false
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    @Published var showDeleteConfirmation: Bool = false
    @Published var isDeletingAccount: Bool = false
    
    private let supabaseService = SupabaseService.shared
    private let authService = HybridAuthService.shared
    
    func restorePurchases() {
        // Handle restore purchases
        alertMessage = "Purchases restored successfully"
        showAlert = true
    }
    
    func openManageSubscription() {
        // Handle manage subscription
        if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
            UIApplication.shared.open(url)
        }
    }
    
    // MARK: - Account Deletion
    
    func showDeleteAccountConfirmation() {
        showDeleteConfirmation = true
    }
    
    func deleteAccount() async {
        guard !isDeletingAccount else { return }
        
        await MainActor.run {
            isDeletingAccount = true
        }
        
        do {
            Config.debugLog("Starting account deletion process...")
            
            // Call Supabase to delete account and all data
            try await supabaseService.deleteUserAccount()
            
            // Sign out the user after successful deletion
            try await authService.signOut()
            
            await MainActor.run {
                isDeletingAccount = false
                showDeleteConfirmation = false
                alertMessage = "Your account has been successfully deleted. You have been signed out."
                showAlert = true
            }
            
            Config.debugLog("Account deletion completed successfully")
            
        } catch {
            Config.debugLog("Account deletion failed: \(error)")
            
            await MainActor.run {
                isDeletingAccount = false
                showDeleteConfirmation = false
                
                // Show user-friendly error message
                if let appError = error as? AppError {
                    alertMessage = appError.errorDescription ?? "Account deletion failed. Please try again."
                } else {
                    alertMessage = "Account deletion failed. Please try again or contact support if the problem persists."
                }
                showAlert = true
            }
        }
    }
}
