// Copyright 2022-2024 Chartboost, Inc.
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file.

import ChartboostMediationSDK
import Foundation

/// INTERNAL. FOR DEMO AND TESTING PURPOSES ONLY. DO NOT USE DIRECTLY.
///
/// A list of externally configurable properties pertaining to the partner SDK that can be retrieved and set by publishers.
@objc public class ReferenceAdapterConfiguration: NSObject, PartnerAdapterConfiguration {
    /// The version of the partner SDK.
    @objc public static var partnerSDKVersion: String {
        ReferenceSdk.getVersion()
    }

    /// The version of the adapter.
    /// It should have either 5 or 6 digits separated by periods, where the first digit is Chartboost Mediation SDK's major version, the
    /// last digit is the adapter's build version, and intermediate digits are the partner SDK's version.
    /// Format: `<Chartboost Mediation major version>.<Partner major version>.<Partner minor version>.<Partner patch version>.
    /// <Partner build version>.<Adapter build version>` where `.<Partner build version>` is optional.
    @objc public static let adapterVersion = "5.1.0.0.0"

    /// The partner's unique identifier.
    @objc public static let partnerID = "reference"

    /// The human-friendly partner name.
    @objc public static let partnerDisplayName = "Reference"

    /// Flag that can optionally be set to enable the partner's test mode.
    /// Disabled by default.
    @objc public static var testMode = false {
        didSet {
            ReferenceSdk.setTestMode(enabled: testMode)
            if #available(iOS 12.0, *) {
                log("Test mode set to \(testMode)")
            }
        }
    }

    /// Flag that can optionally be set to enable the partner's verbose logging.
    /// Disabled by default.
    @objc public static var verboseLogging = false {
        didSet {
            ReferenceSdk.setVerboseLogging(enabled: verboseLogging)
            if #available(iOS 12.0, *) {
                log("Verbose logging set to \(verboseLogging)")
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
                log("Oversized banner ads set to \(newValue)")
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
                log("Auto-dismiss fullscreen ads delay set to \(newValue?.description ?? "nil")")
            }
        }
    }

    /// Append any other properties that publishers can configure.
}
