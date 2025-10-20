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
    @Published var profile: UserProfile? = nil
    @Published var isProfileLoading: Bool = false
    @Published var profileError: String? = nil
    
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
            
            
        } catch {
            
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

    // MARK: - Profile Loading
    func onAuthStateChanged(_ newState: UserState) async {
        switch newState {
        case .authenticated:
            await loadProfile()
        case .anonymous:
            await MainActor.run {
                self.profile = nil
                self.profileError = nil
                self.isProfileLoading = false
            }
        }
    }
    
    func loadProfile() async {
        await MainActor.run {
            self.isProfileLoading = true
            self.profileError = nil
        }
        do {
            let data = try await supabaseService.getUserProfile()
            await MainActor.run {
                self.profile = data
                self.isProfileLoading = false
            }
        } catch {
            await MainActor.run {
                self.profileError = AppError.from(error).errorDescription
                self.isProfileLoading = false
            }
        }
    }
    
    func clearProfile() {
        profile = nil
        profileError = nil
        isProfileLoading = false
    }
}
