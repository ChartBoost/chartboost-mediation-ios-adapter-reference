//
//  ReferenceAdapter.swift
//  ReferenceAdapter
//
//  Created by Vu Chau on 8/22/22.
//

import Foundation
import HeliumSdk

/// INTERNAL. FOR DEMO AND TESTING PURPOSES ONLY. DO NOT USE DIRECTLY.
///
/// An adapter that is used for reference purposes. It is designed to showcase and test the mediation contract of the Helium SDK.
/// Implementations of the Helium mediation interface may roughly model their own design after this class, but do NOT call this adapter directly.
final class ReferenceAdapter: PartnerAdapter {
    init() {
        logger = HeliumLogger(logsPrefix: "[Reference]")
    }
    
    /// An instance of the Helium logging mechanism.
    var logger: HeliumLogger?
    
    /// Get the version of the partner SDK.
    var partnerSDKVersion = ReferenceSdk.getVersion()
    
    /// Get the version of the mediation adapter. To determine the version, use the following scheme to indicate compatibility:
    /// [Helium SDK Major Version].[Partner SDK Major Version].[Partner SDK Minor Version].[Partner SDK Patch Version].[Adapter Version]
    ///
    /// For example, if this adapter is compatible with Helium SDK 4.x.y and partner SDK 1.0.0, and this is its initial release, then its version should be 4.1.0.0.0.
    lazy var adapterVersion = "4.\(partnerSDKVersion).0"
    
    /// Get the internal name of the partner.
    var partnerIdentifier = "reference"
    
    /// Get the external/official name of the partner.
    var partnerDisplayName = "Reference"
    
    /// Override this method to initialize the partner SDK so that it's ready to request and display ads.
    /// For simplicity, the current implementation always assumes successes.
    /// - Parameters:
    ///   - configuration: The necessary initialization data provided by Helium.
    ///   - completion: Handler to notify Helium of task completion.
    func setUp(with configuration: PartnerConfiguration, completion: @escaping (Error?) -> Void) {
        ReferenceSdk.setUp {
            completion(nil)
        }
    }
    
    /// Override this method to compute and return a bid token for the bid request.
    /// - Parameters:
    ///   - request: The necessary data associated with the current bid request.
    ///   - completion: Handler to notify Helium of task completion.
    func fetchBidderInformation(request: PreBidRequest, completion: @escaping ([String : String]) -> Void) {
        completion(["token": ReferenceSdk.getBidToken()])
    }
    
    /// Override this method to notify your partner SDK of GDPR applicability as determined by the Helium SDK.
    /// The current implementation merely logs the GDPR applicability.
    /// - Parameter applies: true if GDPR applies, false otherwise.
    func setGDPRApplies(_ applies: Bool) {
        logger?.log("The Reference adapter has been notified that GDPR \(applies ? "applies" : "does not apply").")
    }
    
    /// Override this method to notify your partner SDK of the GDPR consent status as determined by the Helium SDK.
    /// The current implementation merely logs the GDPR consent status.
    /// - Parameter status: The user's current GDPR consent status.
    func setGDPRConsentStatus(_ status: GDPRConsentStatus) {
        logger?.log("The Reference adapter has been notified that the user's GDPR consent status is \(status).")
    }
    
    /// Override this method to notify your partner SDK of the COPPA subjectivity as determined by the Helium SDK.
    /// The current implementation merely logs the COPPA subjectivity.
    /// - Parameter isSubject: True if the user is subject to COPPA, false otherwise.
    func setUserSubjectToCOPPA(_ isSubject: Bool) {
        logger?.log("The Reference adapter has been notified that the user is \(isSubject ? "subject" : "not subject") to COPPA.")
    }
    
    /// Override this method to notify your partner SDK of the CCPA privacy String as supplied by the Helium SDK.
    /// The current implementation merely logs the CCPA consent status.
    /// - Parameters:
    ///   - hasGivenConsent: True if the user has given CCPA consent, false otherwise.
    ///   - privacyString: The CCPA privacy String.
    func setCCPAConsent(hasGivenConsent: Bool, privacyString: String?) {
        logger?.log("The Reference adapter has been notified that the user has \(hasGivenConsent ? "given" : "not given") CCPA consent.")
    }
    
    /// Override this method to make an ad request to the partner SDK for the given ad format.
    /// - Parameters:
    ///   - request: The relevant data associated with the current ad load call.
    ///   - partnerAdDelegate: Delegate for ad lifecycle notification purposes.
    ///   - viewController: The ViewController for ad presentation purposes.
    ///   - completion: Handler to notify Helium of task completion.
    func load(request: AdLoadRequest, partnerAdDelegate: PartnerAdDelegate, viewController: UIViewController?, completion: @escaping (Result<PartnerAd, Error>) -> Void) {
        switch request.format {
        case .banner:
            ReferenceBannerAdapter.loadBannerAd(request: request, partnerAdDelegate: partnerAdDelegate, viewController: viewController as? ViewController, completion: { result in
                completion(result)
            })
        case .interstitial, .rewarded:
            ReferenceFullscreenAdapter.loadFullscreenAd(request: request, partnerAdDelegate: partnerAdDelegate, completion: { result in
                completion(result)
            })
        }
    }
    
    /// Override this method to show the currently loaded ad.
    /// - Parameters:
    ///   - partnerAd: The PartnerAd instance containing the ad to be shown.
    ///   - viewController: The ViewController for ad presentation purposes.
    ///   - completion: Handler to notify Helium of task completion.
    func show(_ partnerAd: PartnerAd, viewController: UIViewController, completion: @escaping (Result<PartnerAd, Error>) -> Void) {
        switch partnerAd.request.format {
            /// Banner does not have a separate show mechanism
        case .banner: completion(.success(partnerAd))
        case .interstitial, .rewarded:
            ReferenceFullscreenAdapter.showFullscreenAd(partnerAd: partnerAd, completion: { result in
                completion(result)
            })
        }
    }
    
    /// Override this method to discard current ad objects and release resources.
    /// - Parameters:
    ///   - partnerAd: The PartnerAd instance containing the ad to be invalidated.
    ///   - completion: Handler to notify Helium of task completion.
    func invalidate(_ partnerAd: PartnerAd, completion: @escaping (Result<PartnerAd, Error>) -> Void) {
        switch partnerAd.request.format {
        case .banner:
            ReferenceBannerAdapter.destroyBannerAd(partnerAd: partnerAd) { result in
                completion(result)
            }
        case .interstitial, .rewarded:
            ReferenceFullscreenAdapter.destroyFullscreenAd(partnerAd: partnerAd) { result in
                completion(result)
            }
        }
    }
}
