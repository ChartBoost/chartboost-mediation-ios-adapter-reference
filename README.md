# Chartboost Mediation Reference Adapter

The Chartboost Mediation Reference adapter showcases the integration with mediation APIs of the Chartboost Mediation SDK, for reference and testing purposes only.

## Minimum Requirements

| Plugin | Version |
| ------ | ------ |
| Chartboost Mediation SDK | 4.0.0+ |
| Cocoapods | 1.11.3+ |
| iOS | 10.0+ |
| Xcode | 14.1+ |

## Integration

In your `Podfile`, add the following entry:
```
pod 'ChartboostMediationAdapterReference'
```

## Chartboost Mediation Custom Adapter Implementation Guide

> [!IMPORTANT]
> Chartboost Mediation does not provide official support for custom adapters. For a list of official adapters, [visit this site](https://adapters.chartboost.com).

1. Create a new class that conforms to Chartboost Mediation's `PartnerAdapter` protocol.
2. Implement `var partnerSDKVersion: String { get }` to return the version number of the partner SDK. Most adapters fetch this from the partner SDK's API so the adapter always reports the correct version even if the SDK version has changed.
3. Implement `var adapterVersion: String { get }` to return the version number of the mediation adapter. The adapter version format is `<Chartboost Mediation major version>.<Partner major version>.<Partner minor version>.<Partner patch version>.<Partner build version>.<Adapter build version>`.  
`<Partner build version>` is optional, and omitted by most partners.
For example, if this adapter is compatible with Helium SDK 4.x and partner SDK 1.2.3.[4], and this is its initial release, then `adapterVersion` is 4.1.2.3.[4].0.
4. Implement `var partnerIdentifier: String { get }` with the internal identifier that the Chartboost Mediation SDK can use to refer to the current partner. Must match the value used on the Chartboost Mediation dashboard.
5. Implement `var partnerDisplayName: String { get }` to return the partner name as it should appear in text.
6. Implement `func setGDPR(applies: Bool?, status: GDPRConsentStatus)`,  
`func setCCPA(hasGivenConsent: Bool, privacyString: String)`,  
and `func setCOPPA(isChildDirected: Bool)`,  
which receive privacy settings from Chartboost Mediation SDK and apply them to the partner SDK.  
They are always called at startup when Chartboost Mediation initializes adapters. They will also be called any time the publisher updates privacy settings on the Mediation SDK.  
These privacy methods aren't called until *after* `setUp()`, so if your SDK requires privacy settings to be passed in at init then you will need to use default values on the very first launch and store the settings received by these methods for use on subsequent startups.
Any time you update your SDK's privacy settings, use `PartnerLogEvent.privacyUpdated(setting: String, value: Any?)` to log the change.
7. Implement `init(storage: PartnerAdapterStorage)`. This is a no-op for most adapters, but if you need to prevent the same placement ID from being loaded twice then hold onto a reference to `storage`, which provides visibility into which ads from your network the Mediation SDK currently has loaded. See the implementation of `makeAd` in the reference adapter for an example of how to check this storage for duplicates.
8. Implement `func setUp( with configuration: PartnerConfiguration, completion: @escaping (Error?) -> Void )` to initialize the partner SDK and perform any necessary setup in order to request and serve ads. Call `PartnerLogEvent.setUpStarted()` before initializing your SDK. If the operation succeeds, log `PartnerLogEvent.setUpSucceded` and call `completion(nil)`. Otherwise, log `PartnerLogEvent.setUpFailed(Error)` and call `completion(Error)`.
If a call to this method times out, the Mediation SDK will consider your adapter un-initialized even if you later report a successful init.
9. Implement `func fetchBidderInformation( request: PreBidRequest, completion: @escaping ([String: String]?) -> Void )`. If you support bidding, return `completion([String: String])` of biddable token Strings. The keys used in this dictionary depend on how your network's bidder was integrated with our backend. Usually Chartboost just passes these labels through to the bidding server, so whatever your RTB spec says probably applies here i.e. if your server expects bidder information in a field called 'token', then 'token' would be used.  
As you fetch/generate the token(s), use these three `PartnerLogEvent`s to log execution:  
`.fetchBidderInfoStarted(PreBidRequest)`  
`.fetchBidderInfoSucceeded(PreBidRequest)`  
`.fetchBidderInfoFailed(PreBidRequest, error: Error)`  
If bidding is not supported by your SDK, just call `completion(nil)`.
10. Implement at least one class that wraps instances of your ads. It must conform to the `PartnerAd` protocol:  
    - `var adapter: PartnerAdapter { get }`   
    A reference to the adapter that created the ad.  
    - `var request: PartnerAdLoadRequest { get }`  
    The associated ad load request.  
    - `var delegate: PartnerAdDelegate? { get }`  
    The lifecycle events delegate.  
    - `var inlineView: UIView? { get }`  
    View for displaying banner ads. Not used for other ad types.  
    - `func load(with viewController: UIViewController?, completion: @escaping (Result<PartnerEventDetails, Error>) -> Void)`  
    Instantiate an ad from your network's SDK. If your SDK expects an ADM from a bid response to construct an ad, it will be in `request.adm`. For non-bidding ads, the placement ID will be available in `request.partnerPlacement`.
    Call the completion after loading to indicate success or failure.  
    - `func show(with viewController: UIViewController, completion: @escaping (Result<PartnerEventDetails, Error>) -> Void)`  
    Show the loaded ad and then call the show completion closure. Never used on banner ads.  
    - `func invalidate() throws`  
    Called by the SDK before disposing of an ad. There's a no-op default implementation and most adapters don't implement their own because no special cleanup is necessary for their ads.  

    Most adapters implement more than one ad type (i.e. [YourNetwork]BannerAd, [YourNetwork]InterstitialAd, etc). In that case, you can move some of the things required by `PartnerAd` into a parent class to reduce duplicated code. In this repo, you can see how `ReferenceAdapterAd` holds the `init` function and several properties that don't differ between subclasses.  
    
    Each `PartnerAd` also needs to store the `PartnerAdDelegate` that Chartboost Mediation SDK will pass to `makeAd`, and call the following delegate methods to report your ad lifecycle events:  
    - `func didTrackImpression(_ ad: PartnerAd, details: PartnerEventDetails)`  
    Call when the partner SDK registers an impression for the currently showing ad.  
    - `func didClick(_ ad: PartnerAd, details: PartnerEventDetails)`  
    Call when the partner ad has been clicked as the result of a user action.  
    - `func didReward(_ ad: PartnerAd, details: PartnerEventDetails)`  
    Call when a reward has been given for watching a video ad.  
    - `func didDismiss(_ ad: PartnerAd, details: PartnerEventDetails, error: Error?)`  
    Call when the partner ad has been dismissed as the result of a user action.  
    - `func didExpire(_ ad: PartnerAd, details: PartnerEventDetails)`  
    Call when the partner ad has expired as determined by the partner SDK.  
11. Implement `func makeAd(request: PartnerAdLoadRequest, delegate: PartnerAdDelegate) throws -> PartnerAd`, which returns your `PartnerAd`-conforming objects.
If you are writing an adapter for Chartboost Mediation 4.x, and your adapter supports Adaptive Banners or Rewarded Interstitials, you'll need to check for those within the `default` clause, to maintain backward compatibility.
```swift
default:
    if request.format.rawValue == "rewarded_interstitial" {
        return YourAdapterRewardedInterstitialAd(adapter: self, request: request, delegate: delegate)
    } else if request.format.rawValue == "adaptive_banner" {
        return YourAdapterAdapterBannerAd(adapter: self, request: request, delegate: delegate)
    } else {
        throw error(.loadFailureUnsupportedAdFormat)
    }
```
12. On the Chartboost Mediation web dashboard, add your full adapter class name so your mediation adapter and partner SDK can be initialized and interacted with for ad serving purposes.  

13. If your SDK has configuration features that publishers need access to, make them available via a class called `[YourNetwork]AdapterConfiguration` that exposes public properties or methods.

## Contributions

We are committed to a fully transparent development process and highly appreciate any contributions. Our team regularly monitors and investigates all submissions for the inclusion in our official adapter releases.

Refer to our [CONTRIBUTING](https://github.com/ChartBoost/chartboost-mediation-ios-adapter-reference/blob/main/CONTRIBUTING.md) file for more information on how to contribute.

## License

Refer to our [LICENSE](https://github.com/ChartBoost/chartboost-mediation-ios-adapter-reference/blob/main/LICENSE.md) file for more information.
