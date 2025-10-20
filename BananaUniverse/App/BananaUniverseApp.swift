//
//  BananaUniverseApp.swift
//  BananaUniverse
//
//  Created by AI Assistant on 14.10.2025.
//

import SwiftUI

@main
struct BananaUniverseApp: App {
    init() {
        Task {
            do {
                // Mock Adapty activation - always succeeds
                // try await Adapty.activate("public_live_q60OFUaR.i63zkyyKSFCAKR0vkB9B")
                print("Mock: Adapty activated successfully")
            } catch {
                print("Mock: Adapty activation skipped")
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
