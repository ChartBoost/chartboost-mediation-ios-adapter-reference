//
//  ReferenceSdk.swift
//  ReferenceAdapter
//
//  Created by Vu Chau on 8/22/22.
//

import Foundation

/// INTERNAL. FOR DEMO AND TESTING PURPOSES ONLY. DO NOT USE DIRECTLY.
/// A dummy SDK designed to support the Reference adapter.
/// Do NOT copy.
class ReferenceSdk {
    /// Simulate a partner SDK initialization that does nothing and completes after 500 ms.
    /// For simplicity, the current implementation always assumes success.
    /// Do NOT copy.
    /// - Parameter completion: The completion block to be called when the setup is complete.
    static func setUp(completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
            completion()
        }
    }
    
    /// Simulate a partner SDK computation of a bid token.
    /// Using the random UUID as an example.
    /// Do NOT copy.
    /// - Returns: the UUID String.
    static func getBidToken() -> String {
        return UUID().uuidString
    }
    
    /// Get the version of the Reference SDK.
    /// - Returns:
    static func getVersion() -> String {
        return "1.0.0"
    }

    /// Simulate a no-op test mode for demo purposes.
    /// Do NOT copy.
    /// - Parameter enabled: true if test mode is enabled, false otherwise.
    static func setTestMode(enabled: Bool) {
    }
    
    /// Simulate a no-op verbose logging setting.
    /// Do NOT copy.
    /// - Parameter enabled: true if verbose logging is enabled, false otherwise.
    static func setVerboseLogging(enabled: Bool) {
    }
}
