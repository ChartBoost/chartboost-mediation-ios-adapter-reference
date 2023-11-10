// Copyright 2022-2023 Chartboost, Inc.
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file.

import ChartboostMediationSDK
import Foundation

/// INTERNAL. FOR DEMO AND TESTING PURPOSES ONLY. DO NOT USE DIRECTLY.
///
/// The Chartboost Mediation Reference adapter banner ad.
final class ReferenceAdapterBannerAd: ReferenceAdapterAd, PartnerAd {

    /// Flag that can optionally be set to force the adapter to return oversized banner ads for testing purposes.
    static var oversizedBannerAds = false

    /// The partner ad view to display inline. E.g. a banner view.
    /// Should be nil for full-screen ads.
    var inlineView: UIView?
    
    /// Loads an ad.
    /// - parameter viewController: The view controller on which the ad will be presented on. Needed on load for some banners.
    /// - parameter completion: Closure to be performed once the ad has been loaded.
    func load(with viewController: UIViewController?, completion: @escaping (Result<PartnerEventDetails, Error>) -> Void) {
        log(.loadStarted)

        guard let requestedSize = request.size,
              let bannerSize = getReferenceBannerAdSize(size: fixedBannerSize(for: requestedSize)) else {
            let error = error(.loadFailureInvalidBannerSize)
            log(.loadFailed(error))
            completion(.failure(error))
            return
        }

        // Construct a Reference banner ad object as well as the partner ad to be persisted for subsequent ad operations.
        let ad = ReferenceBannerAd(
            placement: request.partnerPlacement,
            size: bannerSize,
            viewController: viewController
        )
        ad.delegate = self
        
        // Set the inlineView so Chartboost Mediation SDK can lay out the ReferenceBannerAd properly
        self.inlineView = ad
        
        // Load the Reference banner ad with the given ad markup, if any, and subscribe to impression and click callbacks in order to notify Chartboost Mediation.
        ad.load(adm: request.adm)
        
        // Specify completion partner details.
        // These are optional. Here we include adaptive banner information for testing purposes.
        // If your SDK does not support adaptive banners you shouldn't have to do this.
        let partnerDetails = [
            "bannerWidth": "\(ad.size.cgSize.width + (Self.oversizedBannerAds ? 10 : 0))",
            "bannerHeight": "\(ad.size.cgSize.height + (Self.oversizedBannerAds ? 10 : 0))",
            "bannerType": "0"   // 0 = fixed size banner, 1 = adaptive banner
        ]
        // For simplicity, the current implementation always assumes success after this point.
        completion(.success(partnerDetails))
    }

    /// Shows a loaded ad.
    /// It will never get called for banner ads. You may leave the implementation blank for that ad format.
    /// - parameter viewController: The view controller on which the ad will be presented on.
    /// - parameter completion: Closure to be performed once the ad has been shown.
    func show(with viewController: UIViewController, completion: @escaping (Result<PartnerEventDetails, Error>) -> Void) {
        // no-op
    }
    
    /// Map the requested size to one of the Reference SDK's supported sizes.
    /// - Parameter size: The Chartboost Mediation's banner size.
    /// - Returns: The corresponding Reference banner size.
    private func getReferenceBannerAdSize(size: CGSize?) -> ReferenceBannerAd.Size? {
        switch size {
        case IABStandardAdSize:
            return ReferenceBannerAd.Size.banner
        case IABMediumAdSize:
            return ReferenceBannerAd.Size.leaderboard
        case IABLeaderboardAdSize:
            return ReferenceBannerAd.Size.mediumRectangle
        default:
            // Not a standard IAB size
            return nil
        }
    }

    /// Some partner SDKs support adaptive banners, which allow publishers to request an ad with custom dimensions.
    /// If our `ReferenceSdk` supported this, we could simply pass the requested dimensions to it, but since it doesn't
    /// we will see if the requested size fits within one of the standard sizes we can support.
    private func fixedBannerSize(for requestedSize: CGSize) -> CGSize? {
        let sizes = [IABLeaderboardAdSize, IABMediumAdSize, IABStandardAdSize]
        // Find the largest size that can fit in the requested size.
        for size in sizes {
            // If height is 0, the pub has requested an ad of any height, so only the width matters.
            if requestedSize.width >= size.width &&
                (size.height == 0 || requestedSize.height >= size.height) {
                return size
            }
        }
        // The requested size cannot fit any fixed size banners.
        return nil
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
