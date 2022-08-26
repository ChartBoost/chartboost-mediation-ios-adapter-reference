//
//  ReferenceFullscreenAdapter.swift
//  ReferenceAdapter
//
//  Created by Vu Chau on 8/22/22.
//

import Foundation
import HeliumSdk

/// Reference adapter's fullscreen-specific API implementations
extension ReferenceAdapter {    
    /// Attempt to load a fullscreen ad.
    /// - Parameters:
    ///   - request: The relevant data associated with the current ad load call.
    ///   - partnerAdDelegate: Delegate for ad lifecycle notification purposes.
    ///   - completion: Handler to notify Helium of task completion.
    func loadFullscreenAd(request: AdLoadRequest, partnerAdDelegate: PartnerAdDelegate, completion: @escaping (Result<PartnerAd, Error>) -> Void) {
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
    func showFullscreenAd(partnerAd: PartnerAd, completion: @escaping (Result<PartnerAd, Error>) -> Void) {
        let delegate = delegates[partnerAd.request.heliumPlacement]
        
        if let ad = partnerAd.ad as? ReferenceFullscreenAd {
            ad.show()
            ad.onAdImpression = {
                self.log(.didTrackImpression(partnerAd))
                delegate?.didTrackImpression(partnerAd) ?? self.log(.custom("Unable to notify didTrackImpression for the Reference adapter. Delegate is nil."))
                completion(.success(partnerAd))
            }
            
            ad.onAdShowFailed = {
                let error = self.error(.showFailure(placement: partnerAd.request.heliumPlacement), description: "Failed to show the Reference fullscreen ad due to unknown errors.", error: nil)
                self.log(.showFailed(partnerAd, partnerError: error))
                completion(.failure(error))
            }
            
            ad.onAdClicked = {
                self.log(.didClick(partnerAd, partnerError: nil))
                delegate?.didClick(partnerAd) ?? self.log(.custom("Unable to notify didClick for the Reference adapter. Delegate is nil."))
            }
            
            ad.onAdRewarded = {
                let reward = Reward(amount: 10, label: "coins")
                self.log(.didReward(partnerAd, reward: reward))
                delegate?.didReward(partnerAd, reward: reward) ?? self.log(.custom("Unable to notify didReward for the Reference adapter. Delegate is nil."))
            }
            
            ad.onAdDismissed = {
                self.log(.didDismiss(partnerAd, partnerError: nil))
                delegate?.didDismiss(partnerAd, error: nil) ?? self.log(.custom("Unable to notify didDismiss for the Reference adapter. Delegate is nil."))
            }
        } else {
            completion(.failure(error(.showFailure(placement: partnerAd.request.heliumPlacement),
                                      description: "Failed to show the Reference fullscreen ad. Ad instance is nil or not a ReferenceFullscreenAd.",
                                      error: nil)))
        }
    }
    
    /// Attempt to destroy the current fullscreen ad.
    /// - Parameters:
    ///   - partnerAd: The PartnerAd instance containing the ad to be invalidated.
    ///   - completion: Handler to notify Helium of task completion.
    func destroyFullscreenAd(partnerAd: PartnerAd, completion: @escaping (Result<PartnerAd, Error>) -> Void) {
        if let ad = partnerAd.ad as? ReferenceFullscreenAd {
            delegates.removeAll()
            ad.destroy()
            completion(.success(partnerAd))
        } else {
            completion(.failure(error(.invalidateFailure(placement: partnerAd.request.heliumPlacement),
                                      description: "Failed to invalidate the Reference fullscreen ad. Ad instance is nil or not a ReferenceFullscreenAd.",
                                      error: nil)))
        }
    }
}
