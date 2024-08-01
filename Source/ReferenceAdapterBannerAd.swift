// Copyright 2022-2024 Chartboost, Inc.
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file.

import ChartboostMediationSDK
import Foundation

/// INTERNAL. FOR DEMO AND TESTING PURPOSES ONLY. DO NOT USE DIRECTLY.
///
/// The Chartboost Mediation Reference adapter banner ad.
final class ReferenceAdapterBannerAd: ReferenceAdapterAd, PartnerBannerAd {
    /// Flag that can optionally be set to force the adapter to return oversized banner ads for testing purposes.
    static var oversizedBannerAds = false

    /// The partner banner ad view to display.
    var view: UIView?

    /// The loaded partner ad banner size.
    var size: PartnerBannerSize?

    /// Loads an ad.
    /// - parameter viewController: The view controller on which the ad will be presented on. Needed on load for some banners.
    /// - parameter completion: Closure to be performed once the ad has been loaded.
    func load(with viewController: UIViewController?, completion: @escaping (Error?) -> Void) {
        log(.loadStarted)

        // Construct a Reference banner ad object as well as the partner ad to be persisted for subsequent ad operations.
        let ad = ReferenceBannerAd(
            placement: request.partnerPlacement,
            size: getReferenceBannerAdSize(from: request.bannerSize),
            viewController: viewController
        )
        ad.delegate = self

        // Set the view so Chartboost Mediation SDK can lay out the ReferenceBannerAd properly
        self.view = ad

        // Load the Reference banner ad with the given ad markup, if any, and subscribe to impression and click callbacks in order to 
        // notify Chartboost Mediation.
        ad.load(adm: request.adm)

        // Specify loaded banner size
        let loadedSize = CGSize(
            width: ad.size.cgSize.width + (Self.oversizedBannerAds ? 10 : 0),
            height: ad.size.cgSize.height + (Self.oversizedBannerAds ? 10 : 0)
        )
        size = PartnerBannerSize(size: loadedSize, type: .fixed)
        // For simplicity, the current implementation always assumes successes.
        completion(nil)
    }

    /// Map Chartboost Mediation's banner sizes to the Reference SDK's supported sizes.
    /// - Parameter size: The Chartboost Mediation's banner size.
    /// - Returns: The corresponding Reference banner size.
    func getReferenceBannerAdSize(from requestedSize: BannerSize?) -> ReferenceBannerAd.Size {
        let height = requestedSize?.size.height ?? 50

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
        delegate?.didTrackImpression(self)
    }

    func onAdClicked() {
        log(.didClick(error: nil))
        delegate?.didClick(self)
    }
}
