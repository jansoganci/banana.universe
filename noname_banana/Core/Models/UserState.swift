//
//  UserState.swift
//  noname_banana
//
//  Created by AI Assistant on 14.10.2025.
//

import Foundation
import Supabase

/// Represents the current user state in the hybrid authentication system
enum UserState: Equatable {
    case anonymous(deviceId: String)
    case authenticated(user: User)
    
    var identifier: String {
        switch self {
        case .anonymous(let deviceId):
            return deviceId
        case .authenticated(let user):
            return user.id.uuidString
        }
    }
    
    var isAuthenticated: Bool {
        if case .authenticated = self { return true }
        return false
    }
    
    var user: User? {
        if case .authenticated(let user) = self {
            return user
        }
        return nil
    }
    
    var deviceId: String? {
        if case .anonymous(let deviceId) = self {
            return deviceId
        }
        return nil
    }
}

// MARK: - Codable Support
extension UserState: Codable {
    private enum CodingKeys: String, CodingKey {
        case type, deviceId, user
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
        switch type {
        case "anonymous":
            let deviceId = try container.decode(String.self, forKey: .deviceId)
            self = .anonymous(deviceId: deviceId)
        case "authenticated":
            let user = try container.decode(User.self, forKey: .user)
            self = .authenticated(user: user)
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Invalid UserState type: \(type)"
                )
            )
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .anonymous(let deviceId):
            try container.encode("anonymous", forKey: .type)
            try container.encode(deviceId, forKey: .deviceId)
        case .authenticated(let user):
            try container.encode("authenticated", forKey: .type)
            try container.encode(user, forKey: .user)
        }
    }
}
