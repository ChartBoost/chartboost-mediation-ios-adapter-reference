// Copyright 2022-2024 Chartboost, Inc.
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file.

import ChartboostMediationSDK
import Foundation
import SafariServices
import UIKit
import WebKit
import os.log

/// INTERNAL. FOR DEMO AND TESTING PURPOSES ONLY. DO NOT USE DIRECTLY.
/// A dummy SDK designed to support the reference adapter.
/// Do NOT copy.
class ReferenceBannerAd: UIView {
    
    /// The current placement name
    let placement: String?
    
    /// The banner ad size
    let size: Size
    
    /// The ViewController for ad presentation purposes.
    var viewController: UIViewController?
    
    /// The delegate for this Reference ad.
    weak var delegate: ReferenceBannerAdDelegate?
    
    /// The click through URL to navigate to after a click event has been processed
    let clickThroughUrl = "https://www.chartboost.com/helium/"

    /// The log configuration.
    private lazy var log = OSLog(subsystem: "com.chartboost.mediation.adapter.reference", category: "Banner")

    /// Initialize the Reference banner ad.
    /// - Parameters:
    ///   - placement: The placement name.
    ///   - size: The banner ad size.
    init(placement: String, size: Size, viewController: UIViewController?) {
        self.placement = placement
        self.size = size
        self.viewController = viewController
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Enumeration of the Reference banner ad sizes.
    enum Size: String {
        case banner = "https://chartboost.s3.amazonaws.com/helium/creatives/creative-320x50.png"
        case leaderboard = "https://chartboost.s3.amazonaws.com/helium/creatives/creative-728x90.png"
        case mediumRectangle = "https://chartboost.s3.amazonaws.com/helium/creatives/creative-300x250.png"

        var cgSize: CGSize {
            switch self {
            case .banner: return IABStandardAdSize
            case .leaderboard: return IABLeaderboardAdSize
            case .mediumRectangle: return IABMediumAdSize
            }
        }
    }
    
    /// Attempt to load a banner ad.
    /// - Parameters:
    ///   - adm: The ad markup.
    func load(adm: String?) {
        if #available(iOS 12.0, *) {
            os_log(.debug, log: log, "Loading a Reference banner ad with ad markup: %{public}s", adm ?? "nil")
        }

        let bannerAd = WKWebView()
        addSubview(bannerAd)
        bannerAd.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        bannerAd.load(URLRequest(url: URL(string: size.rawValue)!))
        
        // Create another view and place it on top the webview so it recognizes tap events
        let tapAreaOverlay = UIView(frame: bounds)
        addSubview(tapAreaOverlay)
        tapAreaOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tapAreaOverlay.addGestureRecognizer(createSingleTap())
        
        /// For simplicity, simulate an impression event after 1s
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000)) { [self] in
            delegate?.onAdImpression()
        }
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
            if #available(iOS 12.0, *) {
                os_log(.error, log: log, "Failed to perform clickthrough action due to invalid destination URL.")
            }
            return
        }
        
        /// Present the VC after a small delay due to known restrictions by Apple.
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
            let viewController = UIApplication.shared.keyWindow?.rootViewController
            let browser = SFSafariViewController(url: url)
            viewController?.present(browser, animated: true)
        }
        
        /// For simplicity, simulate a click event after 1s.
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000)) {
            self.delegate?.onAdClicked()
        }
    }
}

protocol ReferenceBannerAdDelegate: AnyObject {
    func onAdImpression()
    func onAdClicked()
}
