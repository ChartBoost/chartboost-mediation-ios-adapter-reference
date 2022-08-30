//
//  ReferenceBannerAd.swift
//  ReferenceAdapter
//
//  Created by Vu Chau on 8/22/22.
//

import Foundation
import HeliumSdk
import SafariServices
import UIKit
import WebKit

/// INTERNAL. FOR DEMO AND TESTING PURPOSES ONLY. DO NOT USE DIRECTLY.
/// A dummy SDK designed to support the reference adapter.
/// Do NOT copy.
class ReferenceBannerAd: ReferenceAd {
    /// The Reference banner ad instance
    var bannerAd: WKWebView?
    
    /// The current placement name
    var placement: String?
    
    /// The banner ad size
    var size: Size?
    
    /// The ViewController for ad presentation purposes.
    var viewController: UIViewController?
    
    /// Closure for notifying Helium of an ad impression event
    var onAdImpression: (() -> Void)?
    
    /// Closure for notifying Helium of an ad click event
    var onAdClicked: (() -> Void)?
    
    /// The click through URL to navigate to after a click event has been processed
    let clickThroughUrl = "https://www.chartboost.com/helium/"
    
    /// Initialize the Reference banner ad.
    /// - Parameters:
    ///   - placement: The placement name.
    ///   - size: The banner ad size.
    init(placement: String, size: Size, viewController: UIViewController?) {
        self.placement = placement
        self.size = size
        self.viewController = viewController
    }
    
    /// Enumeration of the Reference banner ad sizes.
    enum Size: String {
        case banner = "https://chartboost.s3.amazonaws.com/helium/creatives/creative-320x50.png"
        case leaderboard = "https://chartboost.s3.amazonaws.com/helium/creatives/creative-728x90.png"
        case mediumRectangle = "https://chartboost.s3.amazonaws.com/helium/creatives/creative-300x250.png"
    }
    
    /// Attempt to load a banner ad.
    /// - Parameters:
    ///   - adm: The ad markup.
    func load(adm: String?) {
        print("Loading a Reference banner ad with ad markup: \(adm ?? "nil").")
        
        destroy()
        
        bannerAd = WKWebView()
        bannerAd?.load(URLRequest(url: URL(string: size?.rawValue ?? "")!))
        bannerAd?.addGestureRecognizer(createSingleTap())
        
        /// For simplicity, simulate an impression event after 1s
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000)) {
            if let onAdImpression = self.onAdImpression {
                onAdImpression()
            }
        }
    }
    
    /// No-op
    func show() {
    }
    
    /// Attempt to destroy the current Reference banner ad instance.
    func destroy() {
        bannerAd?.stopLoading()
        bannerAd?.removeFromSuperview()
        bannerAd = nil
    }
    
    /// Create a single tap gesture recognizer for UIView clickthrough purposes.
    /// - Returns: An instance of UITapGestureRecognizer that is for a single tap gesture.
    private func createSingleTap() -> UITapGestureRecognizer {
        let singleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(clickthrough))
        singleTap.numberOfTapsRequired = 1
        singleTap.numberOfTouchesRequired = 1
        return singleTap
    }
    
    /// Perform a clickthrough to a predetermined landing page.
    @objc func clickthrough() {
        /// Show the ad as a webpage via an SFSafariViewController
        guard let url = URL(string: clickThroughUrl) else {
            print("Failed to perform clickthrough action due to invalid destination URL.")
            return
        }
        
        /// Present the VC after a small delay due to known restrictions by Apple.
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
            UIApplication.shared.keyWindow?.rootViewController?.present(SFSafariViewController(url: url), animated: true, completion: nil)
        }
        
        /// For simplicity, simulate a click event after 1s.
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000)) {
            if let onAdClicked = self.onAdClicked {
                onAdClicked()
            }
        }
    }
}
