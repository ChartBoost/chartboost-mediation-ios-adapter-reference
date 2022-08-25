//
//  ReferenceFullscreenAdapter.swift
//  ReferenceAdapter
//
//  Created by Vu Chau on 8/22/22.
//

import Foundation
import HeliumSdk

/// Reference adapter's fullscreen-specific API implementations
class ReferenceFullscreenAdapter {
    /// An instance of the Helium logging mechanism.
    static var logger = HeliumLogger(logsPrefix: "[Reference]")

    /// Dictionary of PartnerAdDelegate's keyed by the Helium placement name.
    static var delegates: [String: PartnerAdDelegate] = [:]

    /// Attempt to load a fullscreen ad.
    /// - Parameters:
    ///   - request: The relevant data associated with the current ad load call.
    ///   - partnerAdDelegate: Delegate for ad lifecycle notification purposes.
    ///   - completion: Handler to notify Helium of task completion.
    static func loadFullscreenAd(request: AdLoadRequest, partnerAdDelegate: PartnerAdDelegate, completion: @escaping (Result<PartnerAd, Error>) -> Void) {
        /// Since fullscreen ads require a load-show paradigm, persist the delegate so it can be retrieved at show time.
        delegates[request.heliumPlacement] = partnerAdDelegate
        
        /// Construct a fullscreen ad object as well as the partner ad to be persisted for subsequent ad operations.
        /// Since the Reference API does not distinguish between interstitial and rewarded video, we'll randomly get one of the two for each load.
        let ad = ReferenceFullscreenAd(placement: request.partnerPlacement, adFormat: ReferenceFullscreenAd.FullscreenAdFormat.random())
        let partnerAd = PartnerAd(ad: ad, details: [:], request: request)
        
        /// Load the Reference fullscreen ad.
        ad.load(adm: request.adm)
        
        /// For simplicity, the current implementation always assumes successes.
        completion(.success(partnerAd))
    }
    
    /// Attempt to show the currently loaded fullscreen ad.
    /// - Parameters:
    ///   - partnerAd: The PartnerAd instance containing the ad to be shown.
    ///   - completion: Handler to notify Helium of task completion.
    static func showFullscreenAd(partnerAd: PartnerAd, completion: @escaping (Result<PartnerAd, Error>) -> Void) {
        let delegate = delegates[partnerAd.request.heliumPlacement]
        
        /// Retrieve the currently loaded Reference fullscreen ad to show it.
        if let fullscreenAd = partnerAd.ad {
            if let ad = fullscreenAd as? ReferenceFullscreenAd {
                ad.show()
                ad.onAdImpression = { () -> Void in
                    delegate?.didTrackImpression(partnerAd) ?? self.logger.log("Unable to notify didTrackImpression for the Reference adapter. Delegate is nil.")
                    completion(.success(partnerAd))
                }
                
                ad.onAdShowFailed = { () -> Void in
                    /// TODO: Use a Helium error. Pending https://github.com/ChartBoost/ios-helium-sdk/pull/673.
                    completion(.failure(ReferenceError.tempError))
                }
                
                ad.onAdClicked = { () -> Void in
                    delegate?.didClick(partnerAd) ?? self.logger.log("Unable to notify didClick for the Reference adapter. Delegate is nil.")
                }
                
                ad.onAdRewarded = { () -> Void in
                    delegate?.didReward(partnerAd, reward: Reward(amount: 10, label: "coins")) ?? self.logger.log("Unable to notify didReward for the Reference adapter. Delegate is nil.")
                }
                
                ad.onAdDismissed = { () -> Void in
                    delegate?.didDismiss(partnerAd, error: nil) ?? self.logger.log("Unable to notify didDismiss for the Reference adapter. Delegate is nil.")
                }
            } else {
                logger.log("Failed to show the Reference fullscreen ad. Ad is not a ReferenceFullscreenAd.")
            }
        } else {
            logger.log("Failed to show the Reference fullscreen ad. Ad instance is null.")
            /// TODO: Use a Helium error. Pending https://github.com/ChartBoost/ios-helium-sdk/pull/673.
            completion(.failure(ReferenceError.tempError))
        }
    }
        
    /// Attempt to destroy the current fullscreen ad.
    /// - Parameters:
    ///   - partnerAd: The PartnerAd instance containing the ad to be invalidated.
    ///   - completion: Handler to notify Helium of task completion.
    static func destroyFullscreenAd(partnerAd: PartnerAd, completion: @escaping (Result<PartnerAd, Error>) -> Void) {
        if let fullscreenAd = partnerAd.ad {
            if let ad = fullscreenAd as? ReferenceFullscreenAd {
                delegates.removeAll()
                ad.destroy()
                completion(.success(partnerAd))
            } else {
                logger.log("Failed to invalidate the Reference fullscreen ad. Ad is not a ReferenceFullscreenAd.")
                /// TODO: Use a Helium error. Pending https://github.com/ChartBoost/ios-helium-sdk/pull/673.
                completion(.failure(ReferenceError.tempError))
            }
        } else {
            logger.log("Failed to invalidate the Reference fullscreen ad. Ad instance is null.")
            /// TODO: Use a Helium error. Pending https://github.com/ChartBoost/ios-helium-sdk/pull/673.
            completion(.failure(ReferenceError.tempError))
        }
    }
}
