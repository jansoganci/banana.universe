//
//  BananaUniverseApp.swift
//  BananaUniverse
//
//  Created by Can Soğancı on 13.10.2025.
//

import SwiftUI
import Adapty

@main
struct BananaUniverseApp: App {
    init() {
        // Initialize Adapty SDK - ensure full activation before any other calls
        Task {
            do {
                try await Adapty.activate("public_live_q60OFUaR.i63zkyyKSFCAKR0vkB9B")
                print("✅ Adapty fully activated before loading paywalls")
            } catch {
                Config.debugLog("Failed to activate Adapty SDK: \(error)")
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
