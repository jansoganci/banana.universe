import Foundation

struct Config {
    // MARK: - Supabase Configuration
    static let supabaseURL = "https://jiorfutbmahpfgplkats.supabase.co"
    static let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imppb3JmdXRibWFocGZncGxrYXRzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAzMzIxNjIsImV4cCI6MjA3NTkwODE2Mn0.wZXlQ3r47PqURmOoMoXfhdbtlTKm-yb3FLW78JG2HyU"
    
    // MARK: - Edge Function Configuration
    static let edgeFunctionURL = "https://jiorfutbmahpfgplkats.supabase.co/functions/v1"
    
    // MARK: - AI Configuration
    static let falAIModel = "fal-ai/nano-banana/edit"
    
    // MARK: - Storage Configuration
    static let supabaseBucket = "noname-banana-images-prod"
    
    // MARK: - Architecture Decision
    // Using Apple-friendly stack: SwiftUI + Supabase Edge Functions + fal.ai
    
    // MARK: - Security
    #if DEBUG
    static let isDebug = true
    #else
    static let isDebug = false
    #endif
    
    // MARK: - Paywall Configuration
    static let useTestPaywall = false // Always use Adapty now
    static let testPaywallPlacementId = "test_paywall_review" // Fake paywall for App Review testing only
    
    // MARK: - Privacy & Legal
    static let privacyPolicyURL = "https://jansoganci.github.io/bananauniverse/privacy"
    static let termsOfServiceURL = "https://jansoganci.github.io/bananauniverse/terms"
    static let supportURL = "https://jansoganci.github.io/bananauniverse/support"
    
    // MARK: - Debug Logging
    static func debugLog(_ message: String, file: String = #file, function: String = #function) {
        #if DEBUG
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        #endif
    }
}