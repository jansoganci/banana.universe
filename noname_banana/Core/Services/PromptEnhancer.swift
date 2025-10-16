//
//  PromptEnhancer.swift
//  noname_banana
//
//  Created by AI Assistant on 14.10.2025.
//  Steve Jobs Inspired Prompt Enhancement - "Think Different"
//

import Foundation

/// **Steve Jobs Philosophy**: "Details are not details. They make the design."
/// This service enhances user prompts to get better AI results
@MainActor
class PromptEnhancer: ObservableObject {
    
    // MARK: - 🎯 Core Enhancement Logic
    
    /// Enhances a user prompt for better AI processing
    /// - Parameter userPrompt: Raw user input
    /// - Returns: Enhanced, optimized prompt for AI
    func enhancePrompt(_ userPrompt: String) -> String {
        // Step 1: Clean and normalize
        let cleaned = cleanAndNormalize(userPrompt)
        
        // Step 2: Add context and quality instructions
        let contextualized = addContextualInstructions(cleaned)
        
        // Step 3: Optimize for image processing
        let optimized = optimizeForImageProcessing(contextualized)
        
        return optimized
    }
    
    // MARK: - 🧹 Cleaning and Normalization
    
    private func cleanAndNormalize(_ prompt: String) -> String {
        var cleaned = prompt
        
        // Remove extra whitespace
        cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
        cleaned = cleaned.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        
        // Fix common typos and improve clarity
        cleaned = fixCommonTypos(cleaned)
        
        // Ensure proper capitalization
        cleaned = improveCapitalization(cleaned)
        
        return cleaned
    }
    
    private func fixCommonTypos(_ prompt: String) -> String {
        var fixed = prompt
        
        // Common image editing typos
        let fixes = [
            "remov": "remove",
            "backround": "background",
            "backgound": "background",
            "picutre": "picture",
            "phote": "photo",
            "imge": "image",
            "pic": "image",
            "bg": "background",
            "obj": "object",
            "pers": "person"
        ]
        
        for (wrong, correct) in fixes {
            fixed = fixed.replacingOccurrences(of: wrong, with: correct, options: .caseInsensitive)
        }
        
        return fixed
    }
    
    private func improveCapitalization(_ prompt: String) -> String {
        // Capitalize first letter and proper nouns
        var improved = prompt
        
        // Ensure first letter is capitalized
        if !improved.isEmpty {
            improved = String(improved.prefix(1).uppercased()) + String(improved.dropFirst())
        }
        
        // Capitalize common proper nouns
        let properNouns = ["iPhone", "iOS", "Android", "LinkedIn", "Twitter", "Instagram", "Facebook", "YouTube", "TikTok"]
        for noun in properNouns {
            improved = improved.replacingOccurrences(of: noun.lowercased(), with: noun)
        }
        
        return improved
    }
    
    // MARK: - 🎯 Contextual Instructions
    
    private func addContextualInstructions(_ prompt: String) -> String {
        // Add quality and style instructions based on context
        var enhanced = prompt
        
        // Add quality instructions if not present
        if !containsQualityInstructions(prompt) {
            enhanced += ", high quality, professional result"
        }
        
        // Add style consistency instructions
        if !containsStyleInstructions(prompt) {
            enhanced += ", natural and realistic appearance"
        }
        
        return enhanced
    }
    
    private func containsQualityInstructions(_ prompt: String) -> Bool {
        let qualityKeywords = ["high quality", "professional", "detailed", "sharp", "clear", "crisp", "HD", "4K"]
        return qualityKeywords.contains { prompt.localizedCaseInsensitiveContains($0) }
    }
    
    private func containsStyleInstructions(_ prompt: String) -> Bool {
        let styleKeywords = ["natural", "realistic", "photorealistic", "authentic", "lifelike"]
        return styleKeywords.contains { prompt.localizedCaseInsensitiveContains($0) }
    }
    
    // MARK: - 🖼️ Image Processing Optimization
    
    private func optimizeForImageProcessing(_ prompt: String) -> String {
        var optimized = prompt
        
        // Add image-specific instructions based on detected intent
        if isBackgroundRemoval(prompt) {
            optimized += ", clean edges, transparent background"
        } else if isObjectRemoval(prompt) {
            optimized += ", seamless inpainting, natural background fill"
        } else if isStyleTransfer(prompt) {
            optimized += ", maintain original composition and lighting"
        } else if isUpscaling(prompt) {
            optimized += ", preserve details, enhance sharpness"
        } else if isProfessionalHeadshot(prompt) {
            optimized += ", professional lighting, clean background, business attire"
        }
        
        return optimized
    }
    
    // MARK: - 🔍 Intent Detection
    
    private func isBackgroundRemoval(_ prompt: String) -> Bool {
        let keywords = ["remove background", "transparent", "isolate", "cut out", "extract"]
        return keywords.contains { prompt.localizedCaseInsensitiveContains($0) }
    }
    
    private func isObjectRemoval(_ prompt: String) -> Bool {
        let keywords = ["remove", "erase", "delete", "take out", "eliminate"]
        return keywords.contains { prompt.localizedCaseInsensitiveContains($0) } && 
               !isBackgroundRemoval(prompt)
    }
    
    private func isStyleTransfer(_ prompt: String) -> Bool {
        let keywords = ["style", "artistic", "filter", "effect", "look like", "make it"]
        return keywords.contains { prompt.localizedCaseInsensitiveContains($0) }
    }
    
    private func isUpscaling(_ prompt: String) -> Bool {
        let keywords = ["upscale", "enhance", "improve quality", "make bigger", "increase resolution"]
        return keywords.contains { prompt.localizedCaseInsensitiveContains($0) }
    }
    
    private func isProfessionalHeadshot(_ prompt: String) -> Bool {
        let keywords = ["professional", "headshot", "linkedin", "resume", "business", "corporate"]
        return keywords.contains { prompt.localizedCaseInsensitiveContains($0) }
    }
    
    // MARK: - 🎯 Smart Suggestions
    
    /// Generates smart prompt suggestions based on user input
    func generateSuggestions(for prompt: String) -> [String] {
        var suggestions: [String] = []
        
        let cleaned = cleanAndNormalize(prompt)
        
        // Generate contextual suggestions
        if isBackgroundRemoval(cleaned) {
            suggestions.append("Remove background with clean, professional edges")
            suggestions.append("Create transparent background, preserve all details")
        } else if isObjectRemoval(cleaned) {
            suggestions.append("Remove selected object seamlessly from image")
            suggestions.append("Erase object while maintaining natural background")
        } else if isProfessionalHeadshot(cleaned) {
            suggestions.append("Create professional LinkedIn headshot with clean background")
            suggestions.append("Generate business-ready portrait with professional lighting")
        } else {
            // Generic improvements
            suggestions.append("Enhance image quality and clarity")
            suggestions.append("Apply professional photo editing")
            suggestions.append("Improve composition and visual appeal")
        }
        
        return suggestions.prefix(3).map { $0 }
    }
    
    // MARK: - 📊 Prompt Analysis
    
    /// Analyzes prompt quality and provides feedback
    func analyzePrompt(_ prompt: String) -> PromptAnalysis {
        let cleaned = cleanAndNormalize(prompt)
        
        return PromptAnalysis(
            originalLength: prompt.count,
            cleanedLength: cleaned.count,
            hasQualityInstructions: containsQualityInstructions(cleaned),
            hasStyleInstructions: containsStyleInstructions(cleaned),
            detectedIntent: detectPrimaryIntent(cleaned),
            confidence: calculateConfidence(cleaned),
            suggestions: generateSuggestions(for: cleaned)
        )
    }
    
    private func detectPrimaryIntent(_ prompt: String) -> String {
        if isBackgroundRemoval(prompt) { return "Background Removal" }
        if isObjectRemoval(prompt) { return "Object Removal" }
        if isStyleTransfer(prompt) { return "Style Transfer" }
        if isUpscaling(prompt) { return "Image Enhancement" }
        if isProfessionalHeadshot(prompt) { return "Professional Headshot" }
        return "General Image Editing"
    }
    
    private func calculateConfidence(_ prompt: String) -> Double {
        var confidence: Double = 0.5 // Base confidence
        
        // Length factor
        if prompt.count > 10 { confidence += 0.1 }
        if prompt.count > 20 { confidence += 0.1 }
        
        // Specificity factor
        if containsQualityInstructions(prompt) { confidence += 0.1 }
        if containsStyleInstructions(prompt) { confidence += 0.1 }
        
        // Intent clarity
        if detectPrimaryIntent(prompt) != "General Image Editing" { confidence += 0.2 }
        
        return min(confidence, 1.0)
    }
}

// MARK: - 📊 Prompt Analysis Model

struct PromptAnalysis {
    let originalLength: Int
    let cleanedLength: Int
    let hasQualityInstructions: Bool
    let hasStyleInstructions: Bool
    let detectedIntent: String
    let confidence: Double
    let suggestions: [String]
    
    var qualityScore: Int {
        var score = 50
        
        if hasQualityInstructions { score += 20 }
        if hasStyleInstructions { score += 20 }
        if confidence > 0.7 { score += 10 }
        
        return min(score, 100)
    }
}

// MARK: - 🎯 Usage Example

/*
 Usage in ChatViewModel:
 
 let enhancer = PromptEnhancer()
 let enhancedPrompt = enhancer.enhancePrompt(userInput)
 
 // Send enhanced prompt to AI
 let result = await supabaseService.processImage(imageUrl: url, prompt: enhancedPrompt)
 
 // Get suggestions for better prompts
 let suggestions = enhancer.generateSuggestions(for: userInput)
 
 // Analyze prompt quality
 let analysis = enhancer.analyzePrompt(userInput)
 print("Prompt quality score: \(analysis.qualityScore)")
 */
