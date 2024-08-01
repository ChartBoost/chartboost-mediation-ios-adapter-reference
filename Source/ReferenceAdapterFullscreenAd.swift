// Copyright 2022-2024 Chartboost, Inc.
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file.

import ChartboostMediationSDK
import Foundation

/// INTERNAL. FOR DEMO AND TESTING PURPOSES ONLY. DO NOT USE DIRECTLY.
///
/// The Chartboost Mediation Reference adapter fullscreen ad.
final class ReferenceAdapterFullscreenAd: ReferenceAdapterAd, PartnerFullscreenAd {
    /// The ReferenceSDK ad instance.
    var ad: ReferenceFullscreenAd?

    /// Loads an ad.
    /// - parameter viewController: The view controller on which the ad will be presented on. Needed on load for some banners.
    /// - parameter completion: Closure to be performed once the ad has been loaded.
    func load(with viewController: UIViewController?, completion: @escaping (Error?) -> Void) {
        log(.loadStarted)

        // Construct a fullscreen ad object as well as the partner ad to be persisted for subsequent ad operations.
        let ad = ReferenceFullscreenAd(
            placement: request.partnerPlacement,
            adFormat: request.format == PartnerAdFormats.interstitial ? .interstitial : .rewarded
        )
        ad.delegate = self

        // Keep the Reference ad alive
        self.ad = ad

        // Load the Reference fullscreen ad.
        ad.load(adm: request.adm)

        // For simplicity, the current implementation always assumes successes.
        log(.loadSucceeded)
        completion(nil)
    }

    /// Shows a loaded ad.
    /// Chartboost Mediation SDK will always call this method from the main thread.
    /// - parameter viewController: The view controller on which the ad will be presented on.
    /// - parameter completion: Closure to be performed once the ad has been shown.
    func show(with viewController: UIViewController, completion: @escaping (Error?) -> Void) {
        log(.showStarted)

        guard let ad else {
            let error = error(.showFailureAdNotReady)
            log(.showFailed(error))
            completion(error)
            return
        }

        ad.show()
    }
}

extension ReferenceAdapterFullscreenAd: ReferenceFullscreenAdDelegate {
    func onAdShowSuccess() {
        log(.showSucceeded)
        showCompletion?(nil) ?? log(.showResultIgnored)
        showCompletion = nil
    }

    func onAdShowFailed(_ referenceError: Error?) {
        let error = referenceError ?? self.error(.showFailureUnknown)
        log(.showFailed(error))
        showCompletion?(error) ?? log(.showResultIgnored)
        showCompletion = nil
    }

    func onAdImpression() {
        log(.didTrackImpression)
        delegate?.didTrackImpression(self) ?? log(.delegateUnavailable)
    }

    func onAdClicked() {
        log(.didClick(error: nil))
        delegate?.didClick(self) ?? log(.delegateUnavailable)
    }

    func onAdRewarded() {
        log(.didReward)
        delegate?.didReward(self) ?? log(.delegateUnavailable)
    }

    func onAdDismissed() {
        log(.didDismiss(error: nil))
        delegate?.didDismiss(self, error: nil) ?? log(.delegateUnavailable)
    }
}
