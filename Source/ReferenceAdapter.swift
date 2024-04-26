// Copyright 2022-2024 Chartboost, Inc.
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
    var partnerSDKVersion: String {
        ReferenceAdapterConfiguration.partnerSDKVersion
    }

    /// The version of the adapter.
    /// It should have either 5 or 6 digits separated by periods, where the first digit is Chartboost Mediation SDK's major version, the last digit is the adapter's build version, and intermediate digits are the partner SDK's version.
    /// Format: `<Chartboost Mediation major version>.<Partner major version>.<Partner minor version>.<Partner patch version>.<Partner build version>.<Adapter build version>` where `.<Partner build version>` is optional.
    var adapterVersion: String {
        ReferenceAdapterConfiguration.adapterVersion
    }

    /// The partner's unique identifier.
    var partnerID: String {
        ReferenceAdapterConfiguration.partnerID
    }

    /// The human-friendly partner name.
    var partnerDisplayName: String {
        ReferenceAdapterConfiguration.partnerDisplayName
    }

    /// Ad storage managed by Chartboost Mediation SDK.
    let storage: PartnerAdapterStorage

    /// The designated initializer for the adapter.
    /// Chartboost Mediation SDK will use this constructor to create instances of conforming types.
    /// - parameter storage: An object that exposes storage managed by the Chartboost Mediation SDK to the adapter.
    /// It includes a list of created `PartnerAd` instances. You may ignore this parameter if you don't need it.
    init(storage: PartnerAdapterStorage) {
        // Perform any initialization tasks that are needed prior to setUp() here.
        // You may keep a reference to `storage` and use it later to gather some information from previously created ads.
        self.storage = storage
    }
    
    /// Does any setup needed before beginning to load ads.
    /// - parameter configuration: Configuration data for the adapter to set up.
    /// - parameter completion: Closure to be performed by the adapter when it's done setting up. It should include an error indicating the cause for failure or `nil` if the operation finished successfully.
    func setUp(with configuration: PartnerConfiguration, completion: @escaping (Result<PartnerDetails, Error>) -> Void) {
        // Implement this method to initialize the partner SDK so that it's ready to request and display ads.
        // For simplicity, the current implementation always assumes successes.
        
        log(.setUpStarted)

        // Apply initial consents
        setConsents(configuration.consents, modifiedKeys: Set(configuration.consents.keys))
        setIsUserUnderage(configuration.isUserUnderage)

        ReferenceSdk.setUp {
            self.log(.setUpSucceded)
            completion(.success([:]))
        }
    }
    
    /// Fetches bidding tokens needed for the partner to participate in an auction.
    /// - parameter request: Information about the ad load request.
    /// - parameter completion: Closure to be performed with the fetched info.
    func fetchBidderInformation(request: PartnerAdPreBidRequest, completion: @escaping (Result<[String : String], Error>) -> Void) {
        // Implement this method to compute and return a bid token for the bid request.
        
        log(.fetchBidderInfoStarted(request))
        
        let token = ReferenceSdk.getBidToken()
        
        log(.fetchBidderInfoSucceeded(request))
        completion(.success(["token": token]))
    }
    
    /// Indicates that the user consent has changed.
    /// - parameter consents: The new consents value, including both modified and unmodified consents.
    /// - parameter modifiedKeys: A set containing all the keys that changed.
    func setConsents(_ consents: [ConsentKey: ConsentValue], modifiedKeys: Set<ConsentKey>) {
        // Implement this method to notify your partner SDK of the new consent info as determined by the Chartboost Mediation SDK.

        if modifiedKeys.contains(partnerID) || modifiedKeys.contains(ConsentKeys.gdprConsentGiven) {
            let consent = consents[partnerID] ?? consents[ConsentKeys.gdprConsentGiven]
            ReferenceSdk.consentsToTracking(consent)
            log(.privacyUpdated(setting: "consentsToTracking", value: consent))

        }

        if modifiedKeys.contains(ConsentKeys.ccpaOptIn) {
            let consent = consents[ConsentKeys.ccpaOptIn]
            ReferenceSdk.ccpaConsent(consent)
            log(.privacyUpdated(setting: "ccpaConsent", value: consent))
        }
    }

    /// Indicates that the user is underage signal has changed.
    /// - parameter isUserUnderage: `true` if the user is underage as determined by the publisher, `false` otherwise.
    func setIsUserUnderage(_ isUserUnderage: Bool) {
        // Implement this method to notify your partner SDK of the COPPA subjectivity as determined by the Chartboost Mediation SDK.
        // The current implementation merely logs the COPPA subjectivity.

        ReferenceSdk.coppaExempt(!isUserUnderage)
        log(.privacyUpdated(setting: "coppaExempt", value: !isUserUnderage))
    }
    
    /// Creates a new banner ad object in charge of communicating with a single partner SDK ad instance.
    /// Chartboost Mediation SDK calls this method to create a new ad for each new load request. Ad instances are never reused.
    /// Chartboost Mediation SDK takes care of storing and disposing of ad instances so you don't need to.
    /// ``PartnerAd/invalidate()`` is called on ads before disposing of them in case partners need to perform any custom logic before the
    /// object gets destroyed.
    /// If, for some reason, a new ad cannot be provided, an error should be thrown.
    /// Chartboost Mediation SDK will always call this method from the main thread.
    /// - parameter request: Information about the ad load request.
    /// - parameter delegate: The delegate that will receive ad life-cycle notifications.
    func makeBannerAd(request: PartnerAdLoadRequest, delegate: PartnerAdDelegate) throws -> PartnerBannerAd {
        // Here you must create a PartnerBannerAd object and return it or throw an error.
        // You'll have to define your custom type that conforms to PartnerAd. Depending on how you organize your code you may have one single PartnerAdapter type, or multiple ones depending on ad format.
        ReferenceAdapterBannerAd(adapter: self, request: request, delegate: delegate)
    }

    /// Creates a new ad object in charge of communicating with a single partner SDK ad instance.
    /// Chartboost Mediation SDK calls this method to create a new ad for each new load request. Ad instances are never reused.
    /// Chartboost Mediation SDK takes care of storing and disposing of ad instances so you don't need to.
    /// ``PartnerAd/invalidate()`` is called on ads before disposing of them in case partners need to perform any custom logic before the
    /// object gets destroyed.
    /// If, for some reason, a new ad cannot be provided, an error should be thrown.
    /// - parameter request: Information about the ad load request.
    /// - parameter delegate: The delegate that will receive ad life-cycle notifications.
    func makeFullscreenAd(request: PartnerAdLoadRequest, delegate: PartnerAdDelegate) throws -> PartnerFullscreenAd {
        // Here you must create a PartnerFullscreenAd object and return it or throw an error.
        // You'll have to define your custom type that conforms to PartnerAd. Depending on how you organize your code you may have one single PartnerAdapter type, or multiple ones depending on ad format.
        
        // Prevent multiple loads for the same partner placement.
        // Some partner SDKs don't allow that, and this is how you can avoid attempting to double-load a placement.
        guard !storage.ads.contains(where: { $0.request.partnerPlacement == request.partnerPlacement }) else {
            log("Failed to load ad for already loading placement \(request.partnerPlacement)")
            throw error(.loadFailureLoadInProgress)
        }

        switch request.format {
        case PartnerAdFormats.interstitial, PartnerAdFormats.rewarded, PartnerAdFormats.rewardedInterstitial:
            return ReferenceAdapterFullscreenAd(adapter: self, request: request, delegate: delegate)
        default:
            throw error(.loadFailureUnsupportedAdFormat)
        }
    }
}
