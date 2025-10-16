import Foundation

struct Config {
    // MARK: - Supabase Configuration
    static let supabaseURL = "https://jiorfutbmahpfgplkats.supabase.co"
    static let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imppb3JmdXRibWFocGZncGxrYXRzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAzMzIxNjIsImV4cCI6MjA3NTkwODE2Mn0.wZXlQ3r47PqURmOoMoXfhdbtlTKm-yb3FLW78JG2HyU"
    
    // MARK: - Edge Function Configuration
    static let edgeFunctionURL = "https://jiorfutbmahpfgplkats.supabase.co/functions/v1"
    
    // MARK: - AI Configuration
    static let falAIModel = "fal-ai/clarity-upscaler"
    
    // MARK: - Architecture Decision
    // Using Apple-friendly stack: SwiftUI + Supabase Edge Functions + fal.ai
    
    // MARK: - Security
    #if DEBUG
    static let isDebug = true
    #else
    static let isDebug = false
    #endif
}