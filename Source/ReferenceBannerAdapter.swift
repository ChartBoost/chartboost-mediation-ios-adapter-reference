//
//  ReferenceBannerAdapter.swift
//  ReferenceAdapter
//
//  Created by Vu Chau on 8/22/22.
//

import Foundation
import HeliumSdk

/// Reference adapter's banner-specific API implementations
extension ReferenceAdapter {
    /// Attempt to load a banner ad.
    /// - Parameters:
    ///   - request: The relevant data associated with the current ad load call.
    ///   - partnerAdDelegate: Delegate for ad lifecycle notification purposes.
    ///   - viewController: The ViewController for ad presentation purposes.
    ///   - completion: Handler to notify Helium of task completion.
    func loadBannerAd(request: AdLoadRequest, partnerAdDelegate: PartnerAdDelegate, viewController: UIViewController?, completion: @escaping (Result<PartnerAd, Error>) -> Void) {
        /// Construct a Reference banner ad object as well as the partner ad to be persisted for subsequent ad operations.
        let ad = ReferenceBannerAd(placement: request.partnerPlacement, size: getReferenceBannerAdSize(size: request.size), viewController: viewController)
        let partnerAd = PartnerAd(ad: ad, details: [:], request: request)
        
        /// Load the Reference banner ad with the given ad markup, if any, and subscribe to impression and click callbacks in order to notify Helium.
        ad.load(adm: request.adm)
        ad.onAdImpression = {
            self.log(.didTrackImpression(partnerAd))
            partnerAdDelegate.didTrackImpression(partnerAd)
        }
        ad.onAdClicked = {
            self.log(.didClick(partnerAd, error: nil))
            partnerAdDelegate.didClick(partnerAd)
        }
        
        /// For simplicity, the current implementation always assumes successes.
        completion(.success(partnerAd))
    }
    
    /// Attempt to destroy the current banner ad.
    /// - Parameters:
    ///   - partnerAd: The PartnerAd instance containing the ad to be invalidated.
    ///   - completion: Handler to notify Helium of task completion.
    func destroyBannerAd(partnerAd: PartnerAd, completion: @escaping (Result<PartnerAd, Error>) -> Void) {
        if let ad = partnerAd.ad as? ReferenceBannerAd {
            ad.destroy()
            completion(.success(partnerAd))
        } else {
            completion(.failure(error(.noAdToInvalidate(partnerAd), description: "Ad is nil or not a ReferenceBannerAd.")))
        }
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
        case _ where height >= 250:
            return ReferenceBannerAd.Size.mediumRectangle
        default:
            return ReferenceBannerAd.Size.banner
        }
    }
}
