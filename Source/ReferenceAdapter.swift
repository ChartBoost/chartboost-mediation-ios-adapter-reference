// Copyright 2022-2023 Chartboost, Inc.
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file.

import ChartboostMediationSDK
import Foundation
import UIKit

/// INTERNAL. FOR DEMO AND TESTING PURPOSES ONLY. DO NOT USE DIRECTLY.
///
/// An adapter that is used for reference purposes. It is designed to showcase and test the mediation contract of the Chartboost Mediation SDK.
/// Implementations of the Chartboost Mediation mediation interface may roughly model their own design after this class, but do NOT call this adapter directly.
final class ReferenceAdapter: PartnerAdapter {
    
    /// The version of the partner SDK.
    let partnerSDKVersion = ReferenceSdk.getVersion()
    
    /// The version of the adapter.
    /// It should have either 5 or 6 digits separated by periods, where the first digit is Chartboost Mediation SDK's major version, the last digit is the adapter's build version, and intermediate digits are the partner SDK's version.
    /// Format: `<Chartboost Mediation major version>.<Partner major version>.<Partner minor version>.<Partner patch version>.<Partner build version>.<Adapter build version>` where `.<Partner build version>` is optional.
    let adapterVersion = "4.2.0.0.0"
    
    /// The partner's unique identifier.
    let partnerIdentifier = "reference"
    
    /// The human-friendly partner name.
    let partnerDisplayName = "Reference"
    
    /// The designated initializer for the adapter.
    /// Chartboost Mediation SDK will use this constructor to create instances of conforming types.
    /// - parameter storage: An object that exposes storage managed by the Chartboost Mediation SDK to the adapter.
    /// It includes a list of created `PartnerAd` instances. You may ignore this parameter if you don't need it.
    init(storage: PartnerAdapterStorage) {
        // Perform any initialization tasks that are needed prior to setUp() here.
        // You may keep a reference to `storage` and use it later to gather some information from previously created ads.
    }
    
    /// Does any setup needed before beginning to load ads.
    /// - parameter configuration: Configuration data for the adapter to set up.
    /// - parameter completion: Closure to be performed by the adapter when it's done setting up. It should include an error indicating the cause for failure or `nil` if the operation finished successfully.
    func setUp(with configuration: PartnerConfiguration, completion: @escaping (Error?) -> Void) {
        // Implement this method to initialize the partner SDK so that it's ready to request and display ads.
        // For simplicity, the current implementation always assumes successes.
        
        log(.setUpStarted)
        
        ReferenceSdk.setUp {
            self.log(.setUpSucceded)
            completion(nil)
        }
    }
    
    /// Fetches bidding tokens needed for the partner to participate in an auction.
    /// - parameter request: Information about the ad load request.
    /// - parameter completion: Closure to be performed with the fetched info.
    func fetchBidderInformation(request: PreBidRequest, completion: @escaping ([String : String]?) -> Void) {
        // Implement this method to compute and return a bid token for the bid request.
        
        log(.fetchBidderInfoStarted(request))
        
        let token = ReferenceSdk.getBidToken()
        
        log(.fetchBidderInfoSucceeded(request))
        completion(["token": token])
    }
    
    /// Indicates if GDPR applies or not and the user's GDPR consent status.
    /// - parameter applies: `true` if GDPR applies, `false` if not, `nil` if the publisher has not provided this information.
    /// - parameter status: One of the `GDPRConsentStatus` values depending on the user's preference.
    func setGDPR(applies: Bool?, status: GDPRConsentStatus) {
        // Implement this method to notify your partner SDK of the GDPR consent status as determined by the Chartboost Mediation SDK.
        // The current implementation merely logs the GDPR consent status.
        
        guard applies == true else { return }
        
        let consentString = status == .granted ? "YES" : "NO"
        ReferenceSdk.consentsToTracking(consentString)
        // Log the transformed value
        log(.privacyUpdated(setting: "consentsToTracking", value: consentString))
    }
    
    /// Indicates the CCPA status both as a boolean and as an IAB US privacy string.
    /// - parameter hasGivenConsent: A boolean indicating if the user has given consent.
    /// - parameter privacyString: An IAB-compliant string indicating the CCPA status.
    func setCCPA(hasGivenConsent: Bool, privacyString: String) {
        // Implement this method to notify your partner SDK of the CCPA privacy String as supplied by the Chartboost Mediation SDK.
        // The current implementation merely logs the CCPA consent status.
        
        let consent = hasGivenConsent ? "1" : nil
        ReferenceSdk.ccpaConsent(consent)
        // Log the transformed value
        log(.privacyUpdated(setting: "ccpaConsent", value: consent))
    }
    
    /// Indicates if the user is subject to COPPA or not.
    /// - parameter isChildDirected: `true` if the user is subject to COPPA, `false` otherwise.
    func setCOPPA(isChildDirected: Bool) {
        // Implement this method to notify your partner SDK of the COPPA subjectivity as determined by the Chartboost Mediation SDK.
        // The current implementation merely logs the COPPA subjectivity.
        
        ReferenceSdk.coppaExempt(!isChildDirected)
        log(.privacyUpdated(setting: "coppaExempt", value: !isChildDirected))
    }
    
    /// Creates a new ad object in charge of communicating with a single partner SDK ad instance.
    /// Chartboost Mediation SDK calls this method to create a new ad for each new load request. Ad instances are never reused.
    /// Chartboost Mediation SDK takes care of storing and disposing of ad instances so you don't need to.
    /// `invalidate()` is called on ads before disposing of them in case partners need to perform any custom logic before the object gets destroyed.
    /// If, for some reason, a new ad cannot be provided, an error should be thrown.
    /// - parameter request: Information about the ad load request.
    /// - parameter delegate: The delegate that will receive ad life-cycle notifications.
    func makeAd(request: PartnerAdLoadRequest, delegate: PartnerAdDelegate) throws -> PartnerAd {
        // Here you must create a PartnerAd object and return it or throw an error.
        // You'll have to define your custom type that conforms to PartnerAd. Depending on how you organize your code you may have one single PartnerAdapter type, or multiple ones depending on ad format.
        
        switch request.format {
        case .interstitial, .rewarded:
            return ReferenceAdapterFullscreenAd(adapter: self, request: request, delegate: delegate)
        case .banner:
            return ReferenceAdapterBannerAd(adapter: self, request: request, delegate: delegate)
        @unknown default:
            throw error(.loadFailureUnsupportedAdFormat)
        }
    }
}
