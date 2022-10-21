//
//  ReferenceAdapterBannerAd.swift
//  ReferenceAdapter
//
//  Created by Vu Chau on 8/22/22.
//

import Foundation
import HeliumSdk

/// INTERNAL. FOR DEMO AND TESTING PURPOSES ONLY. DO NOT USE DIRECTLY.
///
/// The Helium Reference adapter banner ad.
final class ReferenceAdapterBannerAd: ReferenceAdapterAd, PartnerAd {
    
    /// The partner ad view to display inline. E.g. a banner view.
    /// Should be nil for full-screen ads.
    var inlineView: UIView?
    
    /// Loads an ad.
    /// - parameter viewController: The view controller on which the ad will be presented on. Needed on load for some banners.
    /// - parameter completion: Closure to be performed once the ad has been loaded.
    func load(with viewController: UIViewController?, completion: @escaping (Result<PartnerEventDetails, Error>) -> Void) {
        log(.loadStarted)
        
        // ReferenceBannerAd inherits from UIView so we must perform this in the UI thread
        DispatchQueue.main.async { [self] in
            // Construct a Reference banner ad object as well as the partner ad to be persisted for subsequent ad operations.
            let ad = ReferenceBannerAd(
                placement: request.partnerPlacement,
                size: getReferenceBannerAdSize(size: request.size),
                viewController: viewController
            )
            ad.delegate = self
            
            // Set the inlineView so Helium SDK can lay out the ReferenceBannerAd properly
            self.inlineView = ad
            
            // Load the Reference banner ad with the given ad markup, if any, and subscribe to impression and click callbacks in order to notify Helium.
            ad.load(adm: request.adm)
            
            // For simplicity, the current implementation always assumes successes.
            completion(.success([:]))
        }
    }
    
    /// Shows a loaded ad.
    /// It will never get called for banner ads. You may leave the implementation blank for that ad format.
    /// - parameter viewController: The view controller on which the ad will be presented on.
    /// - parameter completion: Closure to be performed once the ad has been shown.
    func show(with viewController: UIViewController, completion: @escaping (Result<PartnerEventDetails, Error>) -> Void) {
        // no-op
    }
    
    /// Map Helium's banner sizes to the Reference SDK's supported sizes.
    /// - Parameter size: The Helium's banner size.
    /// - Returns: The corresponding Reference banner size.
    func getReferenceBannerAdSize(size: CGSize?) -> ReferenceBannerAd.Size {
        let height = size?.height ?? 50
        
        switch height {
        case 50..<89:
            return ReferenceBannerAd.Size.banner
        case 90..<249:
            return ReferenceBannerAd.Size.leaderboard
        case 250...:
            return ReferenceBannerAd.Size.mediumRectangle
        default:
            return ReferenceBannerAd.Size.banner
        }
    }
}

extension ReferenceAdapterBannerAd: ReferenceBannerAdDelegate {
    
    func onAdImpression() {
        log(.didTrackImpression)
        delegate?.didTrackImpression(self, details: [:])
    }
    
    func onAdClicked() {
        log(.didClick(error: nil))
        delegate?.didClick(self, details: [:])
    }
}
