//
//  ReferenceFullscreenAd.swift
//  ReferenceAdapter
//
//  Created by Vu Chau on 8/22/22.
//

import Foundation
import SafariServices
import HeliumSdk

/// INTERNAL. FOR DEMO AND TESTING PURPOSES ONLY. DO NOT USE DIRECTLY.
/// A dummy SDK designed to support the reference adapter.
/// Do NOT copy.
class ReferenceFullscreenAd: ReferenceAd {    
    /// The current placement name
    var placement: String?
    
    /// The format (interstitial or rewarded) of the fullscreen ad
    var fullscreenAdFormat: FullscreenAdFormat?
    
    /// Whether the current ad is a rewarded ad
    var isRewardedAd: Bool
    
    /// An instance of the Helium logging mechanism.
    var logger: HeliumLogger?
    
    /// Closure for notifying Helium of an ad impression event
    var onAdImpression: (() -> Void)?
    
    /// Closure for notifying Helium of an ad show failure event
    var onAdShowFailed: (() -> Void)?
    
    /// Closure for notifying Helium of an ad click event
    var onAdClicked: (() -> Void)?
    
    /// Closure for notifying Helium of an ad reward event
    var onAdRewarded: (() -> Void)?
    
    /// Closure for notifying Helium of an ad dismissal event
    var onAdDismissed: (() -> Void)?
    
    /// Initialize the Reference fullscreen ad.
    /// - Parameters:
    ///   - placement: The placement name.
    ///   - adFormat: The format (interstitial or rewarded) of the fullscreen ad.
    init(placement: String, adFormat: FullscreenAdFormat) {
        self.placement = placement
        self.fullscreenAdFormat = adFormat
        self.isRewardedAd = adFormat == FullscreenAdFormat.rewarded
        self.logger = HeliumLogger(logsPrefix: "[Reference]")
    }
    
    /// Enumeration of the Reference fullscreen ad formats.
    enum FullscreenAdFormat: String, CaseIterable {
        case interstitial = "https://chartboost.s3.amazonaws.com/helium/creatives/creative-320x480.png"
        case rewarded = "https://chartboost.s3.amazonaws.com/helium/creatives/cbvideoad-portrait.mp4"
        
        /// Pick a random fullscreen ad format.
        /// - Parameter generator: The random number generator.
        /// - Returns: An interstitial or rewarded ad format.
        static func random<G: RandomNumberGenerator>(using generator: inout G) -> FullscreenAdFormat {
            return FullscreenAdFormat.allCases.randomElement(using: &generator)!
        }
        
        /// Pick a random fullscreen ad format.
        /// - Returns: An interstitial or rewarded ad format.
        static func random() -> FullscreenAdFormat {
            var choice = SystemRandomNumberGenerator()
            return FullscreenAdFormat.random(using: &choice)
        }
    }
    
    /// Attempt to load a fullscreen ad.
    /// In this example, there are no "load" and "destroy" implementations as the fullscreen ad is tied to the SFSafariViewController.
    func load(adm: String?) {
        logger?.log("Loading a Reference fullscreen ad with ad markup: \(adm ?? "nil").")
    }
    
    /// Attempt to show the currently loaded fullscreen ad.
    func show() {
        /// Show the ad as a webpage via an SFSafariViewController
        let resource = isRewardedAd ? FullscreenAdFormat.rewarded.rawValue : FullscreenAdFormat.interstitial.rawValue
        guard let url = URL(string: resource) else {
            logger?.log("Failed to show fullscreen ad due to invalid creative URL.")
            
            if let onAdShowFailed = onAdShowFailed {
                onAdShowFailed()
            }
            
            return
        }
        
        /// Present the VC after a small delay due to known restrictions by Apple.
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
            UIApplication.shared.keyWindow?.rootViewController?.present(SFSafariViewController(url: url), animated: true, completion: nil)
        }
        
        /// For simplicity, this implementation fires all completion handlers after a small delay.
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000)) {
            if let onAdImpression = self.onAdImpression {
                onAdImpression()
            }
            
            if let onAdClicked = self.onAdClicked {
                onAdClicked()
            }
            
            if let onAdRewarded = self.onAdRewarded {
                onAdRewarded()
            }
            
            if let onAdDismissed = self.onAdDismissed {
                onAdDismissed()
            }
        }
    }
    
    /// Attempt to destroy the current fullscreen ad.
    /// In this example, there are no "load" and "destroy" implementations as the fullscreen ad is tied to the SFSafariViewController.
    func destroy() {
        logger?.log("Destroying the Reference fullscreen ad.")
    }
}
