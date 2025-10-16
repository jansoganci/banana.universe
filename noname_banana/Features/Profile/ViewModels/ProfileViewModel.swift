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
}
