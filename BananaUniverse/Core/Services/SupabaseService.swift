//
//  SupabaseService.swift
//  BananaUniverse
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
        guard let supabaseURL = URL(string: Config.supabaseURL) else {
            fatalError("Invalid Supabase URL: \(Config.supabaseURL)")
        }
        client = SupabaseClient(
            supabaseURL: supabaseURL,
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
            .from(Config.supabaseBucket)
            .download(path: path)
    }
    
    /// Upload image to Supabase Storage and return public URL
    func uploadImageToStorage(imageData: Data, fileName: String? = nil) async throws -> String {
        Config.debugLog("Uploading image to storage...")
        
        // Generate unique filename if not provided
        let finalFileName = fileName ?? "\(UUID().uuidString).jpg"
        
        // Get user state for path organization
        let userState = HybridAuthService.shared.userState
        let userOrDeviceID = userState.identifier
        let path = "uploads/\(userOrDeviceID)/\(finalFileName)"
        
        Config.debugLog("Upload path: \(path)")
        Config.debugLog("Image data size: \(imageData.count) bytes")
        Config.debugLog("User state: \(userState.isAuthenticated ? "authenticated" : "anonymous")")
        Config.debugLog("User/Device ID: \(userOrDeviceID.prefix(8))...")
        
        // Debug: Check current session and JWT
        do {
            let session = try await getCurrentSession()
            Config.debugLog("Current session: \(session != nil ? "present" : "none")")
            
            if let token = session?.accessToken {
                // Decode JWT to see what's inside
                let parts = token.split(separator: ".")
                if parts.count == 3 {
                    let payload = String(parts[1])
                    if let data = Data(base64Encoded: payload + "==") {
                        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                            Config.debugLog("JWT payload decoded successfully")
                            Config.debugLog("JWT device_id: \(json["device_id"] != nil ? "present" : "missing")")
                        }
                    }
                }
            }
        } catch {
            Config.debugLog("Error getting session: \(error)")
        }
        
        // Upload to Supabase Storage
        let _ = try await client.storage
            .from(Config.supabaseBucket)
            .upload(path, data: imageData, options: FileOptions(
                contentType: "image/jpeg",
                upsert: true
            ))
        
        Config.debugLog("Image uploaded successfully")
        
        // Get public URL
        let publicURL = try await client.storage
            .from(Config.supabaseBucket)
            .getPublicURL(path: path)
        
        Config.debugLog("Public URL generated successfully")
        
        return publicURL.absoluteString
    }
    
    // MARK: - AI Processing
    
    /// 🍎 STEVE JOBS STYLE: Direct image processing with new process-image edge function
    /// Works for both authenticated and anonymous users
    /// Returns processed image URL directly - no polling needed!
    func processImageSteveJobsStyle(
        imageURL: String,
        prompt: String,
        options: [String: Any] = [:]
    ) async throws -> SteveJobsProcessResponse {
        Config.debugLog("processImageSteveJobsStyle called")
        Config.debugLog("Image URL provided")
        Config.debugLog("Prompt: \(prompt.prefix(50))...")
        
        // Get user state from hybrid auth service
        let userState = HybridAuthService.shared.userState
        
        if userState.isAuthenticated {
            Config.debugLog("Authenticated user processing: \(userState.identifier.prefix(8))...")
        } else {
            Config.debugLog("Anonymous user processing: \(userState.identifier.prefix(8))...")
        }
        
        // Prepare request body
        var body: [String: Any] = [
            "image_url": imageURL,
            "prompt": prompt
        ]
        
        // Add device_id for anonymous users
        if !userState.isAuthenticated {
            body["device_id"] = userState.identifier
        }
        
        Config.debugLog("Calling Steve Jobs Edge Function...")
        
        let jsonData = try JSONSerialization.data(withJSONObject: body)
        
        do {
            // Call the new Steve Jobs style edge function
            guard let functionURL = URL(string: "\(Config.supabaseURL)/functions/v1/process-image") else {
                Config.debugLog("Failed to create process-image URL")
                throw SupabaseError.invalidURL
            }
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
            
            Config.debugLog("HTTP Status Code: \(httpResponse.statusCode)")
            
            // Parse response
            let response = try JSONDecoder().decode(SteveJobsProcessResponse.self, from: responseData)
            
            if response.success {
                Config.debugLog("Processing completed successfully!")
                Config.debugLog("Processed image URL generated")
                return response
            } else {
                Config.debugLog("Processing failed: \(response.error ?? "Unknown error")")
                throw SupabaseError.processingFailed(response.error ?? "Processing failed")
            }
            
        } catch {
            Config.debugLog("Processing error: \(error)")
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
        Config.debugLog("processImageData called with model: \(model)")
        
        // Check if user has credits (works for both authenticated and anonymous)
        guard await HybridCreditManager.shared.hasCredits() else {
            Config.debugLog("Insufficient credits")
            throw SupabaseError.insufficientCredits
        }
        
        // ✅ DON'T spend credit yet - only after success
        let creditsBefore = await HybridCreditManager.shared.credits
        Config.debugLog("Credits available: \(creditsBefore)")
        
        // Get user state from hybrid auth service
        let userState = HybridAuthService.shared.userState
        
        if userState.isAuthenticated {
            Config.debugLog("Authenticated user processing: \(userState.identifier.prefix(8))...")
        } else {
            Config.debugLog("Anonymous user processing: \(userState.identifier.prefix(8))...")
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
        
        Config.debugLog("Calling Edge Function with body size: \(body.count) keys")
        
        let jsonData = try JSONSerialization.data(withJSONObject: body)
        
        do {
            Config.debugLog("About to invoke edge function...")
            Config.debugLog("Request body size: \(jsonData.count) bytes")
            
            // Use URLSession directly instead of Supabase SDK to avoid response parsing issues
            guard let functionURL = URL(string: "\(Config.supabaseURL)/functions/v1/ai-process") else {
                Config.debugLog("Failed to create ai-process URL")
                throw SupabaseError.invalidURL
            }
            var request = URLRequest(url: functionURL)
            request.httpMethod = "POST"
            request.setValue("Bearer \(Config.supabaseAnonKey)", forHTTPHeaderField: "Authorization")
            request.setValue(Config.supabaseAnonKey, forHTTPHeaderField: "apikey")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            
            let (responseData, urlResponse) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = urlResponse as? HTTPURLResponse {
                Config.debugLog("HTTP Status Code: \(httpResponse.statusCode)")
                
                // Handle 202 Accepted (async processing)
                if httpResponse.statusCode == 202 {
                    Config.debugLog("Processing started (202), polling for result...")
                    
                    // Parse job_id from response
                    if let responseString = String(data: responseData, encoding: .utf8) {
                        Config.debugLog("Async response received")
                    }
                    
                    // For now, throw error - we need to implement polling
                    throw SupabaseError.processingFailed("Async processing not yet supported. Please wait and try again.")
                }
            }
            
            Config.debugLog("Edge Function response received, size: \(responseData.count) bytes")
            
            // Debug: Print raw response data
            if let responseString = String(data: responseData, encoding: .utf8) {
                Config.debugLog("Edge Function response received (\(responseString.count) chars)")
            } else {
                Config.debugLog("Could not decode response as UTF-8 string")
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            do {
                let response = try decoder.decode(AIProcessResponse.self, from: responseData)
                Config.debugLog("Response decoded successfully")
                
                // ✅ ONLY deduct credit on success
                _ = try await HybridCreditManager.shared.spendCredit()
                Config.debugLog("Processing successful, credit spent. Remaining: \(await HybridCreditManager.shared.credits)")
                
                return response
            } catch DecodingError.dataCorrupted(let context) {
                Config.debugLog("Data corrupted: \(context.debugDescription)")
                throw SupabaseError.processingFailed("Data corrupted")
            } catch DecodingError.keyNotFound(let key, let context) {
                Config.debugLog("Key '\(key)' not found: \(context.debugDescription)")
                Config.debugLog("codingPath: \(context.codingPath)")
                throw SupabaseError.processingFailed("Key '\(key)' not found")
            } catch DecodingError.valueNotFound(let value, let context) {
                Config.debugLog("Value '\(value)' not found: \(context.debugDescription)")
                Config.debugLog("codingPath: \(context.codingPath)")
                throw SupabaseError.processingFailed("Value '\(value)' not found")
            } catch DecodingError.typeMismatch(let type, let context) {
                Config.debugLog("Type '\(type)' mismatch: \(context.debugDescription)")
                Config.debugLog("codingPath: \(context.codingPath)")
                Config.debugLog("Expected type: \(type)")
                throw SupabaseError.processingFailed("Type '\(type)' mismatch")
            } catch {
                Config.debugLog("Other decoding error: \(error)")
                throw error
            }
            
        } catch {
            // ❌ Processing failed - credit NOT spent
            Config.debugLog("Edge Function call failed: \(error)")
            Config.debugLog("Error type: \(type(of: error))")
            Config.debugLog("Credit NOT deducted due to error")
            
            // Try to extract error details
            if let data = error as? Data {
                let errorString = String(data: data, encoding: .utf8) ?? "Could not decode error"
                Config.debugLog("Error response (Data): \(errorString)")
            }
            
            // Check if it's a URLError or other network error
            if let urlError = error as? URLError {
                Config.debugLog("URLError code: \(urlError.code)")
                Config.debugLog("URLError description: \(urlError.localizedDescription)")
            }
            
            throw error
        }
    }
    
    // MARK: - Async Processing (V2)
    
    /// Process image with AI using V2 async API (returns 202 immediately)
    /// Works for both authenticated and anonymous users
    func processImageDataV2(
        model: String,
        imageURL: String,
        options: [String: Any] = [:]
    ) async throws -> JobSubmissionResponse {
        Config.debugLog("processImageDataV2 called with model: \(model)")
        Config.debugLog("Image URL provided")
        
        // Check if user has credits (works for both authenticated and anonymous)
        guard await HybridCreditManager.shared.hasCredits() else {
            Config.debugLog("Insufficient credits")
            throw SupabaseError.insufficientCredits
        }
        
        let creditsBefore = await HybridCreditManager.shared.credits
        Config.debugLog("Credits available: \(creditsBefore)")
        
        // Get user state from hybrid auth service
        let userState = HybridAuthService.shared.userState
        
        if userState.isAuthenticated {
            Config.debugLog("Authenticated user processing: \(userState.identifier.prefix(8))...")
        } else {
            Config.debugLog("Anonymous user processing: \(userState.identifier.prefix(8))...")
        }
        
        // Use image URL directly (no base64 conversion needed)
        var body: [String: Any] = [
            "model": model,
            "image_url": imageURL,
            "options": options
        ]
        
        // Add user context based on state
        if userState.isAuthenticated {
            body["user_id"] = userState.identifier
        } else {
            body["device_id"] = userState.identifier
        }
        
        Config.debugLog("Calling V2 Edge Function...")
        
        let jsonData = try JSONSerialization.data(withJSONObject: body)
        
        do {
            // Use URLSession directly for V2 endpoint
            guard let functionURL = URL(string: "\(Config.supabaseURL)/functions/v1/ai-process-v2") else {
                Config.debugLog("Failed to create ai-process-v2 URL")
                throw SupabaseError.invalidURL
            }
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
            
            Config.debugLog("HTTP Status Code: \(httpResponse.statusCode)")
            
            // V2 returns 202 Accepted
            if httpResponse.statusCode == 202 {
                Config.debugLog("Job accepted (202)")
                
                // Debug: Print raw response
                if let rawResponse = String(data: responseData, encoding: .utf8) {
                    Config.debugLog("Raw 202 response: \(rawResponse)")
                } else {
                    Config.debugLog("Could not decode response data as UTF-8 string")
                }
                
                // Enhanced debugging for decode process
                Config.debugLog("===== DECODE PROCESS START =====")
                Config.debugLog("Attempting to decode into: JobSubmissionResponse")
                Config.debugLog("Response data size: \(responseData.count) bytes")
                
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                Config.debugLog("Decoder configured with: convertFromSnakeCase")
                
                // Try to parse as JSON first to see structure
                do {
                    if let jsonObject = try JSONSerialization.jsonObject(with: responseData) as? [String: Any] {
                        Config.debugLog("JSON structure:")
                        for (key, value) in jsonObject {
                            Config.debugLog("  '\(key)': \(value)")
                        }
                    }
                } catch {
                    Config.debugLog("Failed to parse as JSON object: \(error)")
                }
                
                Config.debugLog("Starting decode into JobSubmissionResponse...")
                let response = try decoder.decode(JobSubmissionResponse.self, from: responseData)
                Config.debugLog("===== DECODE SUCCESS =====")
                Config.debugLog("Decoded response: \(response)")
                Config.debugLog("===== DECODE PROCESS END =====")
                
                // ✅ SPEND CREDIT IMMEDIATELY ON ACCEPTANCE
                _ = try await HybridCreditManager.shared.spendCredit()
                Config.debugLog("Credit spent on job acceptance. Remaining: \(await HybridCreditManager.shared.credits)")
                
                return response
            } else if httpResponse.statusCode == 429 {
                // Rate limit or concurrent limit exceeded
                if let errorString = String(data: responseData, encoding: .utf8) {
                    Config.debugLog("Rate limit: \(errorString)")
                }
                throw SupabaseError.rateLimitExceeded
            } else {
                // Other errors
                if let errorString = String(data: responseData, encoding: .utf8) {
                    Config.debugLog("Error: \(errorString)")
                }
                throw SupabaseError.serverError("Failed to submit job")
            }
            
        } catch let error as SupabaseError {
            Config.debugLog("SupabaseError: \(error)")
            throw error
        } catch DecodingError.keyNotFound(let key, let context) {
            Config.debugLog("===== DECODE ERROR: KEY NOT FOUND =====")
            Config.debugLog("Missing key: '\(key)'")
            Config.debugLog("Coding path: \(context.codingPath)")
            Config.debugLog("Context description: \(context.debugDescription)")
            Config.debugLog("===== DECODE ERROR END =====")
            throw SupabaseError.processingFailed("Key '\(key)' not found in response")
        } catch DecodingError.typeMismatch(let type, let context) {
            Config.debugLog("===== DECODE ERROR: TYPE MISMATCH =====")
            Config.debugLog("Expected type: \(type)")
            Config.debugLog("Coding path: \(context.codingPath)")
            Config.debugLog("Context description: \(context.debugDescription)")
            Config.debugLog("===== DECODE ERROR END =====")
            throw SupabaseError.processingFailed("Type mismatch: expected \(type)")
        } catch DecodingError.valueNotFound(let value, let context) {
            Config.debugLog("===== DECODE ERROR: VALUE NOT FOUND =====")
            Config.debugLog("Missing value: \(value)")
            Config.debugLog("Coding path: \(context.codingPath)")
            Config.debugLog("Context description: \(context.debugDescription)")
            Config.debugLog("===== DECODE ERROR END =====")
            throw SupabaseError.processingFailed("Value '\(value)' not found")
        } catch DecodingError.dataCorrupted(let context) {
            Config.debugLog("===== DECODE ERROR: DATA CORRUPTED =====")
            Config.debugLog("Context description: \(context.debugDescription)")
            Config.debugLog("Coding path: \(context.codingPath)")
            Config.debugLog("===== DECODE ERROR END =====")
            throw SupabaseError.processingFailed("Data corrupted: \(context.debugDescription)")
        } catch {
            Config.debugLog("Unexpected error: \(error)")
            Config.debugLog("Error type: \(type(of: error))")
            throw error
        }
    }
    
    /// Poll job status until completion with progress callbacks
    func pollJobStatus(
        jobId: String,
        deviceId: String? = nil,
        onProgress: @escaping (JobStatusResponse) -> Void
    ) async throws -> JobStatusResponse {
        Config.debugLog("Starting to poll job: \(jobId.prefix(8))...")
        
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
                
                guard let url = urlComponents.url else {
                    Config.debugLog("Failed to create job-status URL")
                    throw SupabaseError.invalidURL
                }
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                request.setValue("Bearer \(Config.supabaseAnonKey)", forHTTPHeaderField: "Authorization")
                request.setValue(Config.supabaseAnonKey, forHTTPHeaderField: "apikey")
                
                let (responseData, _) = try await URLSession.shared.data(for: request)
                
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let status = try decoder.decode(JobStatusResponse.self, from: responseData)
                
                Config.debugLog("Job status: \(status.status), elapsed: \(status.elapsedTime ?? 0)s")
                
                // Call progress callback
                onProgress(status)
                
                // Check if done
                if status.status == "completed" {
                    Config.debugLog("Job completed")
                    return status
                } else if status.status == "failed" {
                    Config.debugLog("Job failed: \(status.errorMessage ?? "Unknown error")")
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
                Config.debugLog("Polling error (attempt \(attempts)): \(error)")
                
                // Don't fail on network errors, just retry
                if attempts >= maxAttempts - 1 {
                    throw SupabaseError.timeout
                }
                
                try await Task.sleep(nanoseconds: pollInterval)
                attempts += 1
            }
        }
        
        Config.debugLog("Polling timeout after \(attempts) attempts")
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
        
        guard let functionURL = URL(string: "\(Config.supabaseURL)/rest/v1/rpc/get_active_job_count") else {
            Config.debugLog("Failed to create get_active_job_count URL")
            throw SupabaseError.invalidURL
        }
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
        
        Config.debugLog("Starting upscale with factor: \(upscaleFactor)")
        Config.debugLog("Image data size: \(imageData.count) bytes")
        
        do {
            let response = try await processImageData(
                model: "upscale",
                imageData: imageData,
                options: options
            )
            Config.debugLog("Upscale successful")
            return response
        } catch {
            Config.debugLog("Upscale failed: \(error)")
            Config.debugLog("Error type: \(type(of: error))")
            if let supabaseError = error as? SupabaseError {
                Config.debugLog("SupabaseError: \(supabaseError)")
            }
            throw error
        }
    }
    
    // MARK: - Library / Job History
    
    /// Fetch user's job history from database
    /// Works for both authenticated and anonymous users
    func fetchUserJobs(
        userState: UserState,
        limit: Int = 50,
        offset: Int = 0
    ) async throws -> [JobRecord] {
        Config.debugLog("Fetching jobs for user: \(userState.identifier.prefix(8))...")
        Config.debugLog("User authenticated: \(userState.isAuthenticated)")
        Config.debugLog("Query limit: \(limit), offset: \(offset)")
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let response: [JobRecord]
            
            if userState.isAuthenticated {
                // Authenticated users: use direct table query
                Config.debugLog("Querying by user_id: \(userState.identifier.prefix(8))...")
                
                let query = client
                    .from("jobs")
                    .select()
                    .eq("status", value: "completed")
                    .eq("user_id", value: userState.identifier)
                    .order("completed_at", ascending: false)
                    .limit(limit)
                    .range(from: offset, to: offset + limit - 1)
                
                Config.debugLog("Executing authenticated query")
                response = try await query
                    .execute()
                    .value
                    
            } else {
                // Anonymous users: use custom function to bypass RLS
                Config.debugLog("Querying by device_id using function: \(userState.identifier.prefix(8))...")
                
                Config.debugLog("Executing anonymous function query...")
                response = try await client
                    .rpc("get_jobs_by_device_id", params: ["device_id_param": userState.identifier])
                    .execute()
                    .value
            }
            
            Config.debugLog("Fetched \(response.count) jobs")
            
            // Debug: Print first few job details if any exist
            if !response.isEmpty {
                Config.debugLog("First job details:")
                for (index, job) in response.prefix(3).enumerated() {
                    Config.debugLog("  Job \(index + 1): ID=\(String(job.id.uuidString.prefix(8)))..., status=\(job.status)")
                }
            } else {
                Config.debugLog("No jobs found in database")
            }
            
            return response
            
        } catch {
            Config.debugLog("Failed to fetch jobs: \(error)")
            Config.debugLog("Error details: \(error)")
            throw error
        }
    }
    
    /// Generate signed URL for a storage path
    func getSignedURL(for path: String, expiresIn: Int = 2592000) async throws -> String {
        // 30 days expiration by default
        let result = try await client.storage
            .from(Config.supabaseBucket)
            .createSignedURL(path: path, expiresIn: expiresIn)
        
        return result.absoluteString
    }
    
    // MARK: - Database
    func getUserProfile() async throws -> UserProfile {
        guard let user = getCurrentUser() else {
            throw SupabaseError.notAuthenticated
        }
        
        let response: UserProfile = try await client
            .from("profiles")
            .select()
            .eq("id", value: user.id.uuidString)
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
            .eq("id", value: user.id.uuidString)
            .execute()
    }
    
    // MARK: - Account Deletion
    
    /// Delete user account and all associated data
    /// This method will be called by the RPC function that handles complete data cleanup
    func deleteUserAccount() async throws {
        Config.debugLog("Starting account deletion process...")
        
        guard let user = getCurrentUser() else {
            Config.debugLog("No authenticated user found for deletion")
            throw SupabaseError.notAuthenticated
        }
        
        Config.debugLog("Deleting account for user: \(user.id.uuidString.prefix(8))...")
        
        do {
            // Call the RPC function that handles complete account deletion
            // This will delete all user data including:
            // - User profile
            // - Job history
            // - Credit transactions
            // - Storage files
            // - Auth user record
            let _ = try await client
                .rpc("delete_user_account", params: ["user_id": user.id.uuidString])
                .execute()
            
            Config.debugLog("Account deletion RPC completed successfully")
            
            // Account deletion completed
            Config.debugLog("Account deletion completed successfully")
            
        } catch {
            Config.debugLog("Account deletion error: \(error)")
            throw error
        }
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
    let processedImageURL: String?
    let error: String?
    let rateLimitInfo: RateLimitInfo?
    
    enum CodingKeys: String, CodingKey {
        case success
        case processedImageURL = "processed_image_url"
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

struct JobRecord: Codable, Identifiable {
    let id: UUID
    let userId: UUID?
    let deviceId: String?
    let model: String
    let status: String
    let inputURL: String?
    let outputURL: String?
    let options: JobOptions?
    let errorMessage: String?
    let falRequestId: String?
    let createdAt: Date
    let completedAt: Date?
    let updatedAt: Date
    let processingTimeSeconds: Int?
    let falStatus: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case deviceId = "device_id"
        case model, status
        case inputURL = "input_url"
        case outputURL = "output_url"
        case options
        case errorMessage = "error_message"
        case falRequestId = "fal_request_id"
        case createdAt = "created_at"
        case completedAt = "completed_at"
        case updatedAt = "updated_at"
        case processingTimeSeconds = "processing_time_seconds"
        case falStatus = "fal_status"
    }
}

struct JobOptions: Codable {
    let prompt: String?
    let timestamp: Int?
    let falImageUrl: String?
    let processingTimeSeconds: Int?
    
    enum CodingKeys: String, CodingKey {
        case prompt
        case timestamp
        case falImageUrl = "fal_image_url"
        case processingTimeSeconds = "processing_time_seconds"
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
    case invalidURL
    
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
        case .invalidURL:
            return "Invalid URL configuration. Please contact support."
        }
    }
    
    /// Maps SupabaseError to user-friendly AppError
    var appError: AppError {
        switch self {
        case .notAuthenticated, .noSession:
            return .signInRequired
        case .insufficientCredits:
            return .insufficientCredits
        case .timeout:
            return .processingTimeout
        case .processingFailed(let message):
            return .processingFailed(message)
        case .rateLimitExceeded:
            return .dailyQuotaExceeded
        case .serverError(let message):
            return .unknown("Server error: \(message)")
        case .invalidResponse:
            return .invalidResponse
        case .invalidURL:
            return .serviceUnavailable
        }
    }
}
