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
            // Mock Adapty activation - always succeeds
            print("Mock: Adapty activated successfully")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
