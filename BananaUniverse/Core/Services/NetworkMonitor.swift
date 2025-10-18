//
//  NetworkMonitor.swift
//  BananaUniverse
//
//  Created by AI Assistant on 18.10.2025.
//  Real-time network connectivity monitoring for proactive error handling
//

import Network
import SwiftUI

/// Monitors network connectivity in real-time and provides reactive updates
@MainActor
class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global(qos: .background)
    
    @Published var isConnected = true
    @Published var connectionType: NWInterface.InterfaceType?
    
    private init() {
        startMonitoring()
    }
    
    deinit {
        monitor.cancel()
    }
    
    /// Starts monitoring network connectivity
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.isConnected = path.status == .satisfied
                self?.connectionType = path.availableInterfaces.first?.type
                
                Config.debugLog("Network status changed: \(path.status), type: \(path.availableInterfaces.first?.type ?? .other)")
            }
        }
        monitor.start(queue: queue)
    }
    
    /// Checks if network is available before making API calls
    func checkConnectivity() -> Bool {
        return isConnected
    }
    
    /// Gets a user-friendly connection type description
    var connectionDescription: String {
        guard isConnected else { return "No Connection" }
        
        switch connectionType {
        case .wifi:
            return "Wi-Fi"
        case .cellular:
            return "Cellular"
        case .wiredEthernet:
            return "Ethernet"
        case .loopback:
            return "Local"
        case .other:
            return "Other"
        case .none:
            return "Unknown"
        @unknown default:
            return "Unknown"
        }
    }
    
    /// Gets network error message for display
    var networkErrorMessage: String {
        if isConnected {
            return "Network connection is available"
        } else {
            return "No internet connection. Please check your network settings and try again."
        }
    }
}
