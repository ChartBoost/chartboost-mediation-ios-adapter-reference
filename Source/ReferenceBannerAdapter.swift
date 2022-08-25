//
//  ReferenceBannerAdapter.swift
//  ReferenceAdapter
//
//  Created by Vu Chau on 8/22/22.
//

import Foundation
import HeliumSdk

/// Reference adapter's banner-specific API implementations
class ReferenceBannerAdapter {
    /// An instance of the Helium logging mechanism.
    static var logger = HeliumLogger(logsPrefix: "[Reference]")
        
    /// Attempt to load a banner ad.
    /// - Parameters:
    ///   - request: The relevant data associated with the current ad load call.
    ///   - partnerAdDelegate: Delegate for ad lifecycle notification purposes.
    ///   - viewController: The ViewController for ad presentation purposes.
    ///   - completion: Handler to notify Helium of task completion.
    static func loadBannerAd(request: AdLoadRequest, partnerAdDelegate: PartnerAdDelegate, viewController: UIViewController?, completion: @escaping (Result<PartnerAd, Error>) -> Void) {
        /// Construct a Reference banner ad object as well as the partner ad to be persisted for subsequent ad operations.
        let ad = ReferenceBannerAd(placement: request.partnerPlacement, size: getReferenceBannerAdSize(size: request.size), viewController: viewController)
        let partnerAd = PartnerAd(ad: ad, details: [:], request: request)
        
        /// Load the Reference banner ad with the given ad markup, if any, and subscribe to impression and click callbacks in order to notify Helium.
        ad.load(adm: request.adm)
        ad.onAdImpression = { () -> Void in
            partnerAdDelegate.didTrackImpression(partnerAd)
        }
        ad.onAdClicked = { () -> Void in
            partnerAdDelegate.didClick(partnerAd)
        }
        
        /// For simplicity, the current implementation always assumes successes.
        completion(.success(partnerAd))
    }
        
    /// Attempt to destroy the current banner ad.
    /// - Parameters:
    ///   - partnerAd: The PartnerAd instance containing the ad to be invalidated.
    ///   - completion: Handler to notify Helium of task completion.
    static func destroyBannerAd(partnerAd: PartnerAd, completion: @escaping (Result<PartnerAd, Error>) -> Void) {
        if let bannerAd = partnerAd.ad {
            if let ad = bannerAd as? ReferenceBannerAd {
                ad.destroy()
                completion(.success(partnerAd))
            } else {
                logger.log("Failed to invalidate the Reference banner ad. Ad is not a ReferenceBannerAd.")
                /// TODO: Use a Helium error. Pending https://github.com/ChartBoost/ios-helium-sdk/pull/673.
                completion(.failure(ReferenceError.tempError))
            }
        } else {
            logger.log("Failed to invalidate the Reference banner ad. Ad instance is null.")
            /// TODO: Use a Helium error. Pending https://github.com/ChartBoost/ios-helium-sdk/pull/673.
            completion(.failure(ReferenceError.tempError))
        }
    }
    
    /// Map Helium's banner sizes to the Reference SDK's supported sizes.
    /// - Parameter size: The Helium's banner size.
    /// - Returns: The corresponding Reference banner size.
    static func getReferenceBannerAdSize(size: CGSize?) -> ReferenceBannerAd.Size {
        let height = size?.height ?? 50
        
        switch height {
        case 50..<89:
            return ReferenceBannerAd.Size.banner
        case 90..<249:
            return ReferenceBannerAd.Size.leaderboard
        case _ where height >= 250:
            return ReferenceBannerAd.Size.mediumRectangle
        default:
            return ReferenceBannerAd.Size.banner
        }
    }
}
