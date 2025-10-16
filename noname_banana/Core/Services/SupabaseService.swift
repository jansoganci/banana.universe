//
//  SupabaseService.swift
//  noname_banana
//
//  Created by AI Assistant on 13.10.2025.
//

import Foundation
import Supabase

@MainActor
class SupabaseService: ObservableObject {
    static let shared = SupabaseService()
    
    let client: SupabaseClient
    
    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: Config.supabaseURL)!,
            supabaseKey: Config.supabaseAnonKey
        )
    }
    
    // MARK: - Authentication
    func signIn(email: String, password: String) async throws {
        try await client.auth.signIn(
            email: email,
            password: password
        )
    }
    
    func signUp(email: String, password: String) async throws {
        try await client.auth.signUp(
            email: email,
            password: password
        )
    }
    
    func signOut() async throws {
        try await client.auth.signOut()
    }
    
    func getCurrentUser() -> User? {
        return client.auth.currentUser
    }
    
    func getCurrentSession() async throws -> Session? {
        return try await client.auth.session
    }
    
    // MARK: - Storage
    func downloadImage(path: String) async throws -> Data {
        return try await client.storage
            .from("pixelmage-images-prod")
            .download(path: path)
    }
    
    /// Upload image to Supabase Storage and return public URL
    func uploadImageToStorage(imageData: Data, fileName: String? = nil) async throws -> String {
        print("📤 [SupabaseService] Uploading image to storage...")
        
        // Generate unique filename if not provided
        let finalFileName = fileName ?? "\(UUID().uuidString).jpg"
        
        // Get user state for path organization
        let userState = HybridAuthService.shared.userState
        let userOrDeviceId = userState.identifier
        let path = "uploads/\(userOrDeviceId)/\(finalFileName)"
        
        print("🔍 [SupabaseService] Upload path: \(path)")
        print("🔍 [SupabaseService] Image data size: \(imageData.count) bytes")
        print("🔍 [SupabaseService] User state: \(userState)")
        print("🔍 [SupabaseService] User/Device ID: \(userOrDeviceId)")
        
        // Debug: Check current session and JWT
        do {
            let session = try await getCurrentSession()
            print("🔍 [SupabaseService] Current session: \(session?.accessToken ?? "No session")")
            
            if let token = session?.accessToken {
                // Decode JWT to see what's inside
                let parts = token.split(separator: ".")
                if parts.count == 3 {
                    let payload = String(parts[1])
                    if let data = Data(base64Encoded: payload + "==") {
                        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                            print("🔍 [SupabaseService] JWT payload: \(json)")
                            print("🔍 [SupabaseService] JWT device_id: \(json["device_id"] ?? "NOT FOUND")")
                        }
                    }
                }
            }
        } catch {
            print("❌ [SupabaseService] Error getting session: \(error)")
        }
        
        // Upload to Supabase Storage
        let uploadResult = try await client.storage
            .from("pixelmage-images-prod")
            .upload(path: path, file: imageData, options: FileOptions(
                contentType: "image/jpeg",
                upsert: true
            ))
        
        print("✅ [SupabaseService] Image uploaded successfully")
        
        // Get public URL
        let publicURL = try await client.storage
            .from("pixelmage-images-prod")
            .getPublicURL(path: path)
        
        print("🔗 [SupabaseService] Public URL: \(publicURL)")
        
        return publicURL.absoluteString
    }
    
    // MARK: - AI Processing
    
    /// 🍎 STEVE JOBS STYLE: Direct image processing with new process-image edge function
    /// Works for both authenticated and anonymous users
    /// Returns processed image URL directly - no polling needed!
    func processImageSteveJobsStyle(
        imageUrl: String,
        prompt: String,
        options: [String: Any] = [:]
    ) async throws -> SteveJobsProcessResponse {
        print("🍎 [STEVE-JOBS] processImageSteveJobsStyle called")
        print("🔗 [STEVE-JOBS] Image URL: \(imageUrl)")
        print("💬 [STEVE-JOBS] Prompt: \(prompt)")
        
        // Get user state from hybrid auth service
        let userState = HybridAuthService.shared.userState
        
        if userState.isAuthenticated {
            print("✅ [STEVE-JOBS] Authenticated user processing: \(userState.identifier)")
        } else {
            print("ℹ️ [STEVE-JOBS] Anonymous user processing: \(userState.identifier)")
        }
        
        // Prepare request body
        var body: [String: Any] = [
            "image_url": imageUrl,
            "prompt": prompt
        ]
        
        // Add device_id for anonymous users
        if !userState.isAuthenticated {
            body["device_id"] = userState.identifier
        }
        
        print("🔍 [STEVE-JOBS] Calling Steve Jobs Edge Function...")
        
        let jsonData = try JSONSerialization.data(withJSONObject: body)
        
        do {
            // Call the new Steve Jobs style edge function
            let functionURL = URL(string: "\(Config.supabaseURL)/functions/v1/process-image")!
            var request = URLRequest(url: functionURL)
            request.httpMethod = "POST"
            request.setValue("Bearer \(Config.supabaseAnonKey)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(userState.identifier, forHTTPHeaderField: "device-id") // For anonymous users
            request.httpBody = jsonData
            
            // Set timeout to 60 seconds for processing
            request.timeoutInterval = 60
            
            let (responseData, urlResponse) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                throw SupabaseError.invalidResponse
            }
            
            print("🔍 [STEVE-JOBS] HTTP Status Code: \(httpResponse.statusCode)")
            
            // Parse response
            let response = try JSONDecoder().decode(SteveJobsProcessResponse.self, from: responseData)
            
            if response.success {
                print("✅ [STEVE-JOBS] Processing completed successfully!")
                print("🔗 [STEVE-JOBS] Processed image URL: \(response.processedImageUrl ?? "nil")")
                return response
            } else {
                print("❌ [STEVE-JOBS] Processing failed: \(response.error ?? "Unknown error")")
                throw SupabaseError.processingFailed(response.error ?? "Processing failed")
            }
            
        } catch {
            print("❌ [STEVE-JOBS] Error: \(error)")
            throw error
        }
    }
    
    /// Process image with AI using raw image data (recommended for iOS)
    /// Works for both authenticated and anonymous users
    func processImageData(
        model: String,
        imageData: Data,
        options: [String: Any] = [:]
    ) async throws -> AIProcessResponse {
        print("🔍 [SupabaseService] processImageData called with model: \(model)")
        
        // Check if user has credits (works for both authenticated and anonymous)
        guard await HybridCreditManager.shared.hasCredits() else {
            print("❌ [SupabaseService] Insufficient credits")
            throw SupabaseError.insufficientCredits
        }
        
        // ✅ DON'T spend credit yet - only after success
        let creditsBefore = await HybridCreditManager.shared.credits
        print("💳 [SupabaseService] Credits available: \(creditsBefore)")
        
        // Get user state from hybrid auth service
        let userState = HybridAuthService.shared.userState
        
        if userState.isAuthenticated {
            print("✅ [SupabaseService] Authenticated user processing: \(userState.identifier)")
        } else {
            print("ℹ️ [SupabaseService] Anonymous user processing: \(userState.identifier)")
        }
        
        // Convert image data to base64
        let base64String = imageData.base64EncodedString()
        let imageDataString = "data:image/jpeg;base64,\(base64String)"
        
        var body: [String: Any] = [
            "model": model,
            "image_data": imageDataString,
            "options": options
        ]
        
        // Add user context based on state
        if userState.isAuthenticated {
            body["user_id"] = userState.identifier
        } else {
            body["device_id"] = userState.identifier
        }
        
        print("🔍 [SupabaseService] Calling Edge Function with body size: \(body.count) keys")
        
        let jsonData = try JSONSerialization.data(withJSONObject: body)
        
        do {
            print("🔍 [DEBUG] About to invoke edge function...")
            print("🔍 [DEBUG] Request body size: \(jsonData.count) bytes")
            
            // Use URLSession directly instead of Supabase SDK to avoid response parsing issues
            let functionURL = URL(string: "\(Config.supabaseURL)/functions/v1/ai-process")!
            var request = URLRequest(url: functionURL)
            request.httpMethod = "POST"
            request.setValue("Bearer \(Config.supabaseAnonKey)", forHTTPHeaderField: "Authorization")
            request.setValue(Config.supabaseAnonKey, forHTTPHeaderField: "apikey")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            
            let (responseData, urlResponse) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = urlResponse as? HTTPURLResponse {
                print("🔍 [DEBUG] HTTP Status Code: \(httpResponse.statusCode)")
                
                // Handle 202 Accepted (async processing)
                if httpResponse.statusCode == 202 {
                    print("⏳ [SupabaseService] Processing started (202), polling for result...")
                    
                    // Parse job_id from response
                    if let responseString = String(data: responseData, encoding: .utf8) {
                        print("🔍 [DEBUG] Async response: \(responseString)")
                    }
                    
                    // For now, throw error - we need to implement polling
                    throw SupabaseError.processingFailed("Async processing not yet supported. Please wait and try again.")
                }
            }
            
            print("✅ [SupabaseService] Edge Function response received, size: \(responseData.count) bytes")
            
            // Debug: Print raw response data
            if let responseString = String(data: responseData, encoding: .utf8) {
                print("🔍 [DEBUG] Raw response from Edge Function: \(responseString)")
            } else {
                print("❌ [DEBUG] Could not decode response as UTF-8 string")
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            do {
                let response = try decoder.decode(AIProcessResponse.self, from: responseData)
                print("✅ [SupabaseService] Response decoded successfully: \(response)")
                
                // ✅ ONLY deduct credit on success
                _ = try await HybridCreditManager.shared.spendCredit()
                print("✅ [SupabaseService] Processing successful, credit spent. Remaining: \(await HybridCreditManager.shared.credits)")
                
                return response
            } catch DecodingError.dataCorrupted(let context) {
                print("❌ [DEBUG] Data corrupted:", context)
                throw SupabaseError.processingFailed("Data corrupted")
            } catch DecodingError.keyNotFound(let key, let context) {
                print("❌ [DEBUG] Key '\(key)' not found:", context.debugDescription)
                print("❌ [DEBUG] codingPath:", context.codingPath)
                throw SupabaseError.processingFailed("Key '\(key)' not found")
            } catch DecodingError.valueNotFound(let value, let context) {
                print("❌ [DEBUG] Value '\(value)' not found:", context.debugDescription)
                print("❌ [DEBUG] codingPath:", context.codingPath)
                throw SupabaseError.processingFailed("Value '\(value)' not found")
            } catch DecodingError.typeMismatch(let type, let context) {
                print("❌ [DEBUG] Type '\(type)' mismatch:", context.debugDescription)
                print("❌ [DEBUG] codingPath:", context.codingPath)
                print("❌ [DEBUG] Expected type:", type)
                throw SupabaseError.processingFailed("Type '\(type)' mismatch")
            } catch {
                print("❌ [DEBUG] Other decoding error:", error)
                throw error
            }
            
        } catch {
            // ❌ Processing failed - credit NOT spent
            print("❌ [SupabaseService] Edge Function call failed: \(error)")
            print("❌ [SupabaseService] Error type: \(type(of: error))")
            print("❌ [SupabaseService] Error description: \(error.localizedDescription)")
            print("❌ [SupabaseService] Credit NOT deducted due to error")
            
            // Try to extract error details
            if let data = error as? Data {
                let errorString = String(data: data, encoding: .utf8) ?? "Could not decode error"
                print("❌ [SupabaseService] Error response (Data): \(errorString)")
            }
            
            // Check if it's a URLError or other network error
            if let urlError = error as? URLError {
                print("❌ [SupabaseService] URLError code: \(urlError.code)")
                print("❌ [SupabaseService] URLError description: \(urlError.localizedDescription)")
            }
            
            // Print full error details
            print("❌ [SupabaseService] Full error: \(String(describing: error))")
            
            throw error
        }
    }
    
    // MARK: - Async Processing (V2)
    
    /// Process image with AI using V2 async API (returns 202 immediately)
    /// Works for both authenticated and anonymous users
    func processImageDataV2(
        model: String,
        imageUrl: String,
        options: [String: Any] = [:]
    ) async throws -> JobSubmissionResponse {
        print("🔍 [SupabaseService V2] processImageDataV2 called with model: \(model)")
        print("🔗 [SupabaseService V2] Image URL: \(imageUrl)")
        
        // Check if user has credits (works for both authenticated and anonymous)
        guard await HybridCreditManager.shared.hasCredits() else {
            print("❌ [SupabaseService V2] Insufficient credits")
            throw SupabaseError.insufficientCredits
        }
        
        let creditsBefore = await HybridCreditManager.shared.credits
        print("💳 [SupabaseService V2] Credits available: \(creditsBefore)")
        
        // Get user state from hybrid auth service
        let userState = HybridAuthService.shared.userState
        
        if userState.isAuthenticated {
            print("✅ [SupabaseService V2] Authenticated user processing: \(userState.identifier)")
        } else {
            print("ℹ️ [SupabaseService V2] Anonymous user processing: \(userState.identifier)")
        }
        
        // Use image URL directly (no base64 conversion needed)
        var body: [String: Any] = [
            "model": model,
            "image_url": imageUrl,
            "options": options
        ]
        
        // Add user context based on state
        if userState.isAuthenticated {
            body["user_id"] = userState.identifier
        } else {
            body["device_id"] = userState.identifier
        }
        
        print("🔍 [SupabaseService V2] Calling V2 Edge Function...")
        
        let jsonData = try JSONSerialization.data(withJSONObject: body)
        
        do {
            // Use URLSession directly for V2 endpoint
            let functionURL = URL(string: "\(Config.supabaseURL)/functions/v1/ai-process-v2")!
            var request = URLRequest(url: functionURL)
            request.httpMethod = "POST"
            request.setValue("Bearer \(Config.supabaseAnonKey)", forHTTPHeaderField: "Authorization")
            request.setValue(Config.supabaseAnonKey, forHTTPHeaderField: "apikey")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            
            let (responseData, urlResponse) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                throw SupabaseError.invalidResponse
            }
            
            print("🔍 [SupabaseService V2] HTTP Status Code: \(httpResponse.statusCode)")
            
            // V2 returns 202 Accepted
            if httpResponse.statusCode == 202 {
                print("✅ [SupabaseService V2] Job accepted (202)")
                
                // Debug: Print raw response
                if let rawResponse = String(data: responseData, encoding: .utf8) {
                    print("🔍 [DEBUG] Raw 202 response: \(rawResponse)")
                } else {
                    print("❌ [DEBUG] Could not decode response data as UTF-8 string")
                }
                
                // Enhanced debugging for decode process
                print("🔍 [DEBUG] ===== DECODE PROCESS START =====")
                print("🔍 [DEBUG] Attempting to decode into: JobSubmissionResponse")
                print("🔍 [DEBUG] Response data size: \(responseData.count) bytes")
                
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                print("🔍 [DEBUG] Decoder configured with: convertFromSnakeCase")
                
                // Try to parse as JSON first to see structure
                do {
                    if let jsonObject = try JSONSerialization.jsonObject(with: responseData) as? [String: Any] {
                        print("🔍 [DEBUG] JSON structure:")
                        for (key, value) in jsonObject {
                            print("🔍 [DEBUG]   '\(key)': \(value)")
                        }
                    }
                } catch {
                    print("❌ [DEBUG] Failed to parse as JSON object: \(error)")
                }
                
                print("🔍 [DEBUG] Starting decode into JobSubmissionResponse...")
                let response = try decoder.decode(JobSubmissionResponse.self, from: responseData)
                print("🔍 [DEBUG] ===== DECODE SUCCESS =====")
                print("🔍 [DEBUG] Decoded response: \(response)")
                print("🔍 [DEBUG] ===== DECODE PROCESS END =====")
                
                // ✅ SPEND CREDIT IMMEDIATELY ON ACCEPTANCE
                _ = try await HybridCreditManager.shared.spendCredit()
                print("💳 [SupabaseService V2] Credit spent on job acceptance. Remaining: \(await HybridCreditManager.shared.credits)")
                
                return response
            } else if httpResponse.statusCode == 429 {
                // Rate limit or concurrent limit exceeded
                if let errorString = String(data: responseData, encoding: .utf8) {
                    print("❌ [SupabaseService V2] Rate limit: \(errorString)")
                }
                throw SupabaseError.rateLimitExceeded
            } else {
                // Other errors
                if let errorString = String(data: responseData, encoding: .utf8) {
                    print("❌ [SupabaseService V2] Error: \(errorString)")
                }
                throw SupabaseError.serverError("Failed to submit job")
            }
            
        } catch let error as SupabaseError {
            print("❌ [SupabaseService V2] SupabaseError: \(error)")
            throw error
        } catch DecodingError.keyNotFound(let key, let context) {
            print("❌ [DEBUG] ===== DECODE ERROR: KEY NOT FOUND =====")
            print("❌ [DEBUG] Missing key: '\(key)'")
            print("❌ [DEBUG] Coding path: \(context.codingPath)")
            print("❌ [DEBUG] Context description: \(context.debugDescription)")
            print("❌ [DEBUG] ===== DECODE ERROR END =====")
            throw SupabaseError.processingFailed("Key '\(key)' not found in response")
        } catch DecodingError.typeMismatch(let type, let context) {
            print("❌ [DEBUG] ===== DECODE ERROR: TYPE MISMATCH =====")
            print("❌ [DEBUG] Expected type: \(type)")
            print("❌ [DEBUG] Coding path: \(context.codingPath)")
            print("❌ [DEBUG] Context description: \(context.debugDescription)")
            print("❌ [DEBUG] ===== DECODE ERROR END =====")
            throw SupabaseError.processingFailed("Type mismatch: expected \(type)")
        } catch DecodingError.valueNotFound(let value, let context) {
            print("❌ [DEBUG] ===== DECODE ERROR: VALUE NOT FOUND =====")
            print("❌ [DEBUG] Missing value: \(value)")
            print("❌ [DEBUG] Coding path: \(context.codingPath)")
            print("❌ [DEBUG] Context description: \(context.debugDescription)")
            print("❌ [DEBUG] ===== DECODE ERROR END =====")
            throw SupabaseError.processingFailed("Value '\(value)' not found")
        } catch DecodingError.dataCorrupted(let context) {
            print("❌ [DEBUG] ===== DECODE ERROR: DATA CORRUPTED =====")
            print("❌ [DEBUG] Context description: \(context.debugDescription)")
            print("❌ [DEBUG] Coding path: \(context.codingPath)")
            print("❌ [DEBUG] ===== DECODE ERROR END =====")
            throw SupabaseError.processingFailed("Data corrupted: \(context.debugDescription)")
        } catch {
            print("❌ [SupabaseService V2] Unexpected error: \(error)")
            print("❌ [DEBUG] Error type: \(type(of: error))")
            throw error
        }
    }
    
    /// Poll job status until completion with progress callbacks
    func pollJobStatus(
        jobId: String,
        deviceId: String? = nil,
        onProgress: @escaping (JobStatusResponse) -> Void
    ) async throws -> JobStatusResponse {
        print("🔄 [SupabaseService] Starting to poll job: \(jobId)")
        
        var attempts = 0
        let maxAttempts = 120 // 10 minutes max (with exponential backoff)
        var pollInterval: UInt64 = 3_000_000_000 // Start with 3 seconds
        
        while attempts < maxAttempts {
            do {
                // Build URL with parameters
                var urlComponents = URLComponents(string: "\(Config.supabaseURL)/functions/v1/job-status")!
                var queryItems = [URLQueryItem(name: "job_id", value: jobId)]
                
                // Add device_id for anonymous users
                if let deviceId = deviceId {
                    queryItems.append(URLQueryItem(name: "device_id", value: deviceId))
                }
                
                urlComponents.queryItems = queryItems
                
                var request = URLRequest(url: urlComponents.url!)
                request.httpMethod = "GET"
                request.setValue("Bearer \(Config.supabaseAnonKey)", forHTTPHeaderField: "Authorization")
                request.setValue(Config.supabaseAnonKey, forHTTPHeaderField: "apikey")
                
                let (responseData, _) = try await URLSession.shared.data(for: request)
                
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let status = try decoder.decode(JobStatusResponse.self, from: responseData)
                
                print("📊 [SupabaseService] Job status: \(status.status), elapsed: \(status.elapsedTime ?? 0)s")
                
                // Call progress callback
                onProgress(status)
                
                // Check if done
                if status.status == "completed" {
                    print("✅ [SupabaseService] Job completed!")
                    return status
                } else if status.status == "failed" {
                    print("❌ [SupabaseService] Job failed: \(status.errorMessage ?? "Unknown error")")
                    throw SupabaseError.processingFailed(status.errorMessage ?? "Unknown error")
                }
                
                // Exponential backoff: 3s → 5s → 8s → 10s (max)
                try await Task.sleep(nanoseconds: pollInterval)
                
                if pollInterval < 10_000_000_000 {
                    pollInterval = min(pollInterval + 2_000_000_000, 10_000_000_000)
                }
                
                attempts += 1
                
            } catch let error as SupabaseError {
                throw error
            } catch {
                print("⚠️ [SupabaseService] Polling error (attempt \(attempts)): \(error)")
                
                // Don't fail on network errors, just retry
                if attempts >= maxAttempts - 1 {
                    throw SupabaseError.timeout
                }
                
                try await Task.sleep(nanoseconds: pollInterval)
                attempts += 1
            }
        }
        
        print("⏱️ [SupabaseService] Polling timeout after \(attempts) attempts")
        throw SupabaseError.timeout
    }
    
    /// Get count of active (pending/processing) jobs for current user
    func getActiveJobCount() async throws -> Int {
        let userState = HybridAuthService.shared.userState
        
        var body: [String: Any?] = [:]
        
        if userState.isAuthenticated {
            body["p_user_id"] = userState.identifier
            body["p_device_id"] = nil
        } else {
            body["p_user_id"] = nil
            body["p_device_id"] = userState.identifier
        }
        
        let jsonData = try JSONSerialization.data(withJSONObject: body)
        
        let functionURL = URL(string: "\(Config.supabaseURL)/rest/v1/rpc/get_active_job_count")!
        var request = URLRequest(url: functionURL)
        request.httpMethod = "POST"
        request.setValue("Bearer \(Config.supabaseAnonKey)", forHTTPHeaderField: "Authorization")
        request.setValue(Config.supabaseAnonKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let (responseData, _) = try await URLSession.shared.data(for: request)
        
        if let count = try? JSONDecoder().decode(Int.self, from: responseData) {
            return count
        }
        
        return 0 // Fail open
    }
    
    /// Upscale image (convenience method)
    func upscaleImage(
        imageData: Data,
        upscaleFactor: Int = 2,
        creativity: Double = 0.35,
        resemblance: Double = 0.6
    ) async throws -> AIProcessResponse {
        let options: [String: Any] = [
            "upscale_factor": upscaleFactor,
            "creativity": creativity,
            "resemblance": resemblance
        ]
        
        print("🔍 [SupabaseService] Starting upscale with factor: \(upscaleFactor)")
        print("🔍 [SupabaseService] Image data size: \(imageData.count) bytes")
        
        do {
            let response = try await processImageData(
                model: "upscale",
                imageData: imageData,
                options: options
            )
            print("✅ [SupabaseService] Upscale successful: \(response)")
            return response
        } catch {
            print("❌ [SupabaseService] Upscale failed: \(error)")
            print("❌ [SupabaseService] Error type: \(type(of: error))")
            if let supabaseError = error as? SupabaseError {
                print("❌ [SupabaseService] SupabaseError: \(supabaseError)")
            }
            throw error
        }
    }
    
    // MARK: - Database
    func getUserProfile() async throws -> UserProfile {
        guard let user = getCurrentUser() else {
            throw SupabaseError.notAuthenticated
        }
        
        let response: UserProfile = try await client
            .from("profiles")
            .select()
            .eq("id", value: user.id)
            .single()
            .execute()
            .value
        
        return response
    }
    
    func updateUserProfile(_ profile: UserProfile) async throws {
        guard let user = getCurrentUser() else {
            throw SupabaseError.notAuthenticated
        }
        
        try await client
            .from("profiles")
            .update(profile)
            .eq("id", value: user.id)
            .execute()
    }
}

// MARK: - Models

struct AIProcessResponse: Codable {
    let jobId: String
    let status: String
    let resultUrl: String?
    let resultUrls: [String]?
    let description: String?
    let seed: Int?
    let modelUsed: String
    let usage: UsageInfo?
    let userType: String?
    
    enum CodingKeys: String, CodingKey {
        case jobId = "job_id"
        case status
        case resultUrl = "result_url"
        case resultUrls = "result_urls"
        case description
        case seed
        case modelUsed = "model_used"
        case usage
        case userType = "user_type"
    }
}

// 🍎 STEVE JOBS STYLE RESPONSE MODEL
struct SteveJobsProcessResponse: Codable {
    let success: Bool
    let processedImageUrl: String?
    let error: String?
    let rateLimitInfo: RateLimitInfo?
    
    enum CodingKeys: String, CodingKey {
        case success
        case processedImageUrl = "processed_image_url"
        case error
        case rateLimitInfo = "rate_limit_info"
    }
}

struct RateLimitInfo: Codable {
    let requestsToday: Int
    let limit: Int
    let resetTime: String
    
    enum CodingKeys: String, CodingKey {
        case requestsToday = "requests_today"
        case limit
        case resetTime = "reset_time"
    }
}

struct JobSubmissionResponse: Codable {
    let jobId: String
    let status: String
    let message: String
    let falRequestId: String?
    let estimatedTime: Int?
    let pollUrl: String?
    let usage: UsageInfo?
    let userType: String?
    
    // ✅ REMOVED CodingKeys - using convertFromSnakeCase instead
    // This eliminates the conflict between automatic and manual key mapping
}

struct UsageInfo: Codable {
    let requestsToday: Int
    let requestsMonth: Int
    let subscriptionTier: String
    
    // ✅ REMOVED CodingKeys - using convertFromSnakeCase instead
}

struct JobStatusResponse: Codable {
    let jobId: String
    let status: String
    let model: String
    let resultUrl: String?
    let errorMessage: String?
    let message: String?
    let elapsedTime: Int?
    let processingTime: Int?
    let estimatedRemaining: Int?
    let falRequestId: String?
    let falStatus: String?
    let createdAt: String
    let updatedAt: String
    let completedAt: String?
    
    // ✅ REMOVED CodingKeys - using convertFromSnakeCase instead
    // This eliminates the conflict between automatic and manual key mapping
}

struct UserProfile: Codable {
    let id: UUID
    let email: String
    let subscriptionTier: String
    let requestsUsedToday: Int
    let requestsUsedThisMonth: Int
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, email
        case subscriptionTier = "subscription_tier"
        case requestsUsedToday = "requests_used_today"
        case requestsUsedThisMonth = "requests_used_this_month"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct ErrorResponse: Codable {
    let error: String
    let details: String?
}

enum SupabaseError: Error, LocalizedError {
    case notAuthenticated
    case insufficientCredits
    case invalidResponse
    case serverError(String)
    case noSession
    case processingFailed(String)
    case timeout
    case rateLimitExceeded
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "You must be signed in to use this feature"
        case .insufficientCredits:
            return "You don't have enough credits. Purchase more credits to continue!"
        case .invalidResponse:
            return "Invalid response from server"
        case .serverError(let message):
            return message
        case .noSession:
            return "No active session found"
        case .processingFailed(let message):
            return "Processing failed: \(message)"
        case .timeout:
            return "Processing timed out. Please try again."
        case .rateLimitExceeded:
            return "You have too many jobs processing. Please wait for one to complete."
        }
    }
}
