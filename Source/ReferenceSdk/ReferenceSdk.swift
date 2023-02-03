// Copyright 2022-2023 Chartboost, Inc.
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file.

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
    
    // The privacy API is intentionally inconsistent, to demonstrate the wide
    // variety of implementations found in partner SDKs
    
    /// Simulate an update to GDPR consent
    /// - A string that contains either "YES" or "NO"
    static func consentsToTracking(_ consents: String) {
    }
    
    /// Simulate an update to COPPA setting
    /// - false if the user is subject to COPPA restrictions, true otherwise
    static func coppaExempt(_ exempt: Bool) {
    }
    
    /// Simulate an update to CCPA settings
    /// - set to "1" if the user consents, or nil if they decline
    static func ccpaConsent(_ consent: String?) {
    }
    
}
