//
//  Tool.swift
//  noname_banana
//
//  Created by AI Assistant on 16.10.2025.
//  Tool Data Model
//

import Foundation

// MARK: - Tool Data Model
struct Tool: Identifiable, Codable {
    let id: String
    let title: String
    let imageUrl: URL?
    let category: String
    let requiresPro: Bool
    let modelName: String
    var placeholderIcon: String // For MVP, use SF Symbol
    let prompt: String // Associated prompt for the tool
}

// MARK: - Static Tool Data
extension Tool {
    static let mainTools: [Tool] = [
        Tool(id: "remove_object", title: "Remove Object from Image", imageUrl: nil, category: "main_tools", requiresPro: false, modelName: "lama-cleaner", placeholderIcon: "eraser.fill", prompt: "Remove the selected object from this image while keeping the background intact"),
        Tool(id: "remove_background", title: "Remove Background", imageUrl: nil, category: "main_tools", requiresPro: false, modelName: "rembg", placeholderIcon: "scissors", prompt: "Remove the background from this image, making it transparent"),
        Tool(id: "put_items_on_models", title: "Put Items on Models", imageUrl: nil, category: "main_tools", requiresPro: false, modelName: "virtual-try-on", placeholderIcon: "person.crop.rectangle", prompt: "Place the selected item naturally on the person in this image"),
        Tool(id: "add_objects", title: "Add Objects to Images", imageUrl: nil, category: "main_tools", requiresPro: false, modelName: "stable-diffusion-inpainting", placeholderIcon: "plus.square.fill", prompt: "Add the requested object to this image in a realistic way"),
        Tool(id: "change_perspective", title: "Change Image Perspectives", imageUrl: nil, category: "main_tools", requiresPro: false, modelName: "perspective-transform", placeholderIcon: "rotate.3d", prompt: "Transform this image to show a different perspective or angle"),
        Tool(id: "generate_series", title: "Generate Image Series", imageUrl: nil, category: "main_tools", requiresPro: false, modelName: "stable-diffusion", placeholderIcon: "square.grid.3x3.fill", prompt: "Create variations of this image with different styles or compositions"),
        Tool(id: "style_transfer", title: "Style Transfers on Images", imageUrl: nil, category: "main_tools", requiresPro: false, modelName: "neural-style", placeholderIcon: "paintbrush.fill", prompt: "Apply artistic style transfer to this image")
    ]
    
    static let proLooksTools: [Tool] = [
        Tool(id: "linkedin_headshot", title: "LinkedIn Headshot", imageUrl: nil, category: "pro_looks", requiresPro: true, modelName: "professional-headshot", placeholderIcon: "person.crop.square", prompt: "Create a professional LinkedIn headshot from this image"),
        Tool(id: "passport_photo", title: "Passport Photo", imageUrl: nil, category: "pro_looks", requiresPro: true, modelName: "passport-photo-generator", placeholderIcon: "doc.text.image", prompt: "Generate a passport-style photo from this image"),
        Tool(id: "twitter_avatar", title: "Twitter/X Avatar", imageUrl: nil, category: "pro_looks", requiresPro: true, modelName: "social-media-avatar", placeholderIcon: "at", prompt: "Create a Twitter/X avatar from this image"),
        Tool(id: "gradient_headshot", title: "Gradient Headshot", imageUrl: nil, category: "pro_looks", requiresPro: true, modelName: "gradient-background-portrait", placeholderIcon: "square.split.diagonal.2x2", prompt: "Create a professional headshot with gradient background"),
        Tool(id: "resume_photo", title: "Resume Photo", imageUrl: nil, category: "pro_looks", requiresPro: true, modelName: "professional-resume-photo", placeholderIcon: "doc.plaintext", prompt: "Generate a professional resume photo from this image"),
        Tool(id: "slide_background", title: "Slide Background Maker", imageUrl: nil, category: "pro_looks", requiresPro: true, modelName: "presentation-background-generator", placeholderIcon: "rectangle.on.rectangle", prompt: "Create a professional slide background from this image"),
        Tool(id: "thumbnail_generator", title: "Thumbnail Generator", imageUrl: nil, category: "pro_looks", requiresPro: true, modelName: "youtube-thumbnail-generator", placeholderIcon: "play.rectangle.fill", prompt: "Create an engaging YouTube thumbnail from this image"),
        Tool(id: "cv_portrait", title: "CV/Portfolio Portrait", imageUrl: nil, category: "pro_looks", requiresPro: true, modelName: "portfolio-portrait", placeholderIcon: "person.text.rectangle", prompt: "Create a professional CV/portfolio portrait"),
        Tool(id: "profile_banner", title: "Profile Banner Generator", imageUrl: nil, category: "pro_looks", requiresPro: true, modelName: "banner-generator", placeholderIcon: "rectangle.fill", prompt: "Create a social media profile banner"),
        Tool(id: "designer_id_photo", title: "Designer-Style ID Photo", imageUrl: nil, category: "pro_looks", requiresPro: true, modelName: "designer-id-photo", placeholderIcon: "person.crop.circle.badge.checkmark", prompt: "Create a designer-style professional ID photo")
    ]
    
    static let restorationTools: [Tool] = [
        Tool(id: "image_upscaler", title: "Image Upscaler (2x-4x)", imageUrl: nil, category: "restoration", requiresPro: false, modelName: "upscale", placeholderIcon: "arrow.up.backward.and.arrow.down.forward", prompt: "Upscale this image by 2x while maintaining quality"),
        Tool(id: "historical_photo_restore", title: "Historical Photo Restore", imageUrl: nil, category: "restoration", requiresPro: false, modelName: "codeformer", placeholderIcon: "clock.arrow.circlepath", prompt: "Restore and enhance this historical photograph")
    ]
}

