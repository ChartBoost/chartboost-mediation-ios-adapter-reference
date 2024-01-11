// Copyright 2022-2024 Chartboost, Inc.
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file.

import ChartboostMediationSDK
import Foundation
import SafariServices
import os.log

/// INTERNAL. FOR DEMO AND TESTING PURPOSES ONLY. DO NOT USE DIRECTLY.
/// A dummy SDK designed to support the reference adapter.
/// Do NOT copy.
class ReferenceFullscreenAd: NSObject {

    /// Enumeration of the Reference fullscreen ad formats.
    enum FullscreenAdFormat: String {
        case interstitial = "https://chartboost.s3.amazonaws.com/helium/creatives/creative-320x480.png"
        case rewarded = "https://chartboost.s3.amazonaws.com/helium/creatives/cbvideoad-portrait.mp4"
    }

    /// Time interval to wait before auto-dismissing shown ads.
    /// Auto-dismiss is disabled if the value is `nil`.
    static var autoDismissAdsDelay: TimeInterval?

    /// The current placement name
    let placement: String
    
    /// The format (interstitial or rewarded) of the fullscreen ad
    let fullscreenAdFormat: FullscreenAdFormat
    
    /// The delegate for this Reference ad.
    weak var delegate: ReferenceFullscreenAdDelegate?
        
    /// The log configuration.
    private lazy var log = OSLog(subsystem: "com.chartboost.mediation.adapter.reference", category: "Fullscreen")

    /// Initialize the Reference fullscreen ad.
    /// - Parameters:
    ///   - placement: The placement name.
    ///   - adFormat: The format (interstitial or rewarded) of the fullscreen ad.
    init(placement: String, adFormat: FullscreenAdFormat) {
        self.placement = placement
        self.fullscreenAdFormat = adFormat
    }
    
    /// Attempt to load a fullscreen ad.
    /// In this example, there are no "load" and "destroy" implementations as the fullscreen ad is tied to the SFSafariViewController.
    func load(adm: String?) {
        if #available(iOS 12.0, *) {
            os_log(.debug, log: log, "Loading a Reference fullscreen ad with ad markup: %{public}s", adm ?? "nil")
        }
    }
    
    /// Attempt to show the currently loaded fullscreen ad.
    func show() {
        /// Show the ad as a webpage via an SFSafariViewController
        guard let url = URL(string: fullscreenAdFormat.rawValue) else {
            if #available(iOS 12.0, *) {
                os_log(.error, log: log, "Failed to show fullscreen ad due to invalid creative URL.")
            }
            delegate?.onAdShowFailed(nil)
            return
        }
        
        /// Present the VC after a small delay due to known restrictions by Apple.
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
            let viewController = UIApplication.shared.keyWindow?.rootViewController
            let browser = SFSafariViewController(url: url)
            browser.delegate = self
            viewController?.present(browser, animated: true) {
                // Auto-dismiss ad if enabled
                if let delay = Self.autoDismissAdsDelay {
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self, weak browser] in
                        browser?.dismiss(animated: true)
                        self?.delegate?.onAdDismissed()   // `safariViewControllerDidFinish(_:)` doesn't get called when dismissing the browser programmatically
                    }
                }
            }
        }
        
        /// For simplicity, this implementation fires all completion handlers after a small delay.
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000)) { [self] in
            delegate?.onAdShowSuccess()
            delegate?.onAdImpression()
            delegate?.onAdClicked()
            delegate?.onAdRewarded()
        }
    }
}

extension ReferenceFullscreenAd: SFSafariViewControllerDelegate {

    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        delegate?.onAdDismissed()
    }
}

protocol ReferenceFullscreenAdDelegate: AnyObject {
    func onAdShowSuccess()
    func onAdShowFailed(_ referenceError: Error?)
    func onAdImpression()
    func onAdClicked()
    func onAdRewarded()
    func onAdDismissed()
}
