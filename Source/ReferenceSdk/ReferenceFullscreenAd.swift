// Copyright 2022-2023 Chartboost, Inc.
// 
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file.

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
class ReferenceFullscreenAd {
    
    /// Enumeration of the Reference fullscreen ad formats.
    enum FullscreenAdFormat: String {
        case interstitial = "https://chartboost.s3.amazonaws.com/helium/creatives/creative-320x480.png"
        case rewarded = "https://chartboost.s3.amazonaws.com/helium/creatives/cbvideoad-portrait.mp4"
    }
    
    /// The current placement name
    let placement: String
    
    /// The format (interstitial or rewarded) of the fullscreen ad
    let fullscreenAdFormat: FullscreenAdFormat
    
    /// The delegate for this Reference ad.
    weak var delegate: ReferenceFullscreenAdDelegate?
        
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
        print("Loading a Reference fullscreen ad with ad markup: \(adm ?? "nil").")
    }
    
    /// Attempt to show the currently loaded fullscreen ad.
    func show() {
        /// Show the ad as a webpage via an SFSafariViewController
        guard let url = URL(string: fullscreenAdFormat.rawValue) else {
            print("Failed to show fullscreen ad due to invalid creative URL.")
            delegate?.onAdShowFailed(nil)
            return
        }
        
        /// Present the VC after a small delay due to known restrictions by Apple.
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
            let viewController = UIApplication.shared.keyWindow?.rootViewController
            let browser = SFSafariViewController(url: url)
            viewController?.present(browser, animated: true)
        }
        
        /// For simplicity, this implementation fires all completion handlers after a small delay.
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000)) { [self] in
            delegate?.onAdImpression()
            delegate?.onAdClicked()
            delegate?.onAdRewarded()
            delegate?.onAdDismissed()
        }
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
