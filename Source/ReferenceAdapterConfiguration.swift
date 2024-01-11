// Copyright 2022-2024 Chartboost, Inc.
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file.

import Foundation
import os.log

/// INTERNAL. FOR DEMO AND TESTING PURPOSES ONLY. DO NOT USE DIRECTLY.
///
/// A list of externally configurable properties pertaining to the partner SDK that can be retrieved and set by publishers.
@objc public class ReferenceAdapterConfiguration: NSObject {
    
    private static let log = OSLog(subsystem: "com.chartboost.mediation.adapter.reference", category: "Configuration")

    /// Flag that can optionally be set to enable the partner's test mode.
    /// Disabled by default.
    @objc public static var testMode: Bool = false {
        didSet {
            ReferenceSdk.setTestMode(enabled: testMode)
            if #available(iOS 12.0, *) {
                os_log(.debug, log: log, "Reference SDK test mode set to %{public}s", "\(testMode)")
            }
        }
    }
    
    /// Flag that can optionally be set to enable the partner's verbose logging.
    /// Disabled by default.
    @objc public static var verboseLogging: Bool = false {
        didSet {
            ReferenceSdk.setVerboseLogging(enabled: verboseLogging)
            if #available(iOS 12.0, *) {
                os_log(.debug, log: log, "Reference SDK verbose logging set to %{public}s", "\(verboseLogging)")
            }
        }
    }

    /// Flag that can optionally be set to force the Reference SDK to return oversized banner ads for testing purposes.
    /// Disabled by default.
    @objc public static var oversizedBannerAds: Bool {
        get {
            ReferenceAdapterBannerAd.oversizedBannerAds
        }
        set {
            ReferenceAdapterBannerAd.oversizedBannerAds = newValue
            if #available(iOS 12.0, *) {
                os_log(.debug, log: log, "Reference SDK oversized banner ads set to %{public}s", "\(newValue)")
            }
        }
    }

    /// Flag that can optionally be set to indicate the time interval to wait before auto-dismissing shown ads.
    /// Auto-dismiss is disabled if the value is `nil`, which is the default.
    public static var autoDismissFullscreenAdsDelay: TimeInterval? {
        get {
            ReferenceFullscreenAd.autoDismissAdsDelay
        }
        set {
            ReferenceFullscreenAd.autoDismissAdsDelay = newValue
            if #available(iOS 12.0, *) {
                os_log(.debug, log: log, "Reference SDK auto-dismiss fullscreen ads delay set to %{public}s", "\(newValue?.description ?? "nil")")
            }
        }
    }

    /// Append any other properties that publishers can configure.
}
