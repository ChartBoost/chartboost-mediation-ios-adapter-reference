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
> Chartboost Mediation will not be providing official support for any custom adapters. For official adapters that we develop and support, [visit this site](https://adapters.chartboost.com).

1. Create a new class and conform to Helium’s `PartnerAdapter` protocol.
2. Implement var `partnerSDKVersion: String { get }` with the version of the partner SDK. Most adapters derive this from the partner SDKs API so that it always reports the correct number, even when a newer version is imported.
3. Implement `var adapterVersion: String { get }` with the version of the mediation adapter. The adapter version format is `<Chartboost Mediation major version>.<Partner major version>.<Partner minor version>.<Partner patch version>.<Partner build version>.<Adapter build version>`.  
`<Partner build version>` is optional, and omitted by most partners."
For example, if this adapter is compatible with Helium SDK 4.x and partner SDK 1.2.3.x, and this is its initial release, then adapterVersion is 4.1.2.3.x.0.
4. Implement var `partnerIdentifier: String { get }` with the internal identifier that the Helium SDK can use to refer to the current partner. Must match the value used in Chartboost Mediation's backend.
5. Implement `var partnerDisplayName: String { get }` the partner name as it should appear in text.
6. Implement `func setGDPR(applies: Bool?, status: GDPRConsentStatus)`,  
`func setCCPA(hasGivenConsent: Bool, privacyString: String)`,  
and `func setCOPPA(isChildDirected: Bool)`,  
which receive privacy settings from Chartboost Mediation SDK and apply them to the partner SDK.  
They are always called at startup when Chartboost Mediation initalizes adapters. They will also be called any time the publisher updates privacy settings on the Mediation SDK.  
These privacy methods aren't called until *after* `setUp()`, so if your SDK requires privacy settings to be passed in at init then you will need to use default values on the very first launch and store the settings received by these methods for use on subsequent startups.
7. Implement `func setUp( with configuration: PartnerConfiguration, completion: @escaping (Error?) -> Void )` to initialize the partner SDK and perform any necessary setup in order to request and serve ads. If the operation succeeds, call `completion(nil)`. Otherwise, call `completion(Error)`.
If a call to this method times out, the Mediation SDK will consider your adapter un-initialized even if you later report a successful init.
8. Implement `func fetchBidderInformation( request: PreBidRequest, completion: @escaping ([String: String]?) -> Void )` to compute and call `completion([String: String])` of biddable token Strings. If network bidding is not supported by the current partner, return an empty Dictionary.
9. Implement a class that wraps instances of your ads. It must conform to the `PartnerAd` protocol:  
    a. `var adapter: PartnerAdapter { get }`, which stores the adapter that created the ad.  
    b. `var request: PartnerAdLoadRequest { get }`, the associated ad load request.  
    c. `var delegate: PartnerAdDelegate? { get }`, the lifecycle events delegate.  
    d. `var inlineView: UIView? { get }` View for displaying banner ads. Not used for other ad types.  
    e. `func load(with viewController: UIViewController?, completion: @escaping (Result<PartnerEventDetails, Error>) -> Void)`  
    Load an ad in the provided ViewController, performing the completion closure afterward.  
    f. `func show(with viewController: UIViewController, completion: @escaping (Result<PartnerEventDetails, Error>) -> Void)`  
    Shows the loaded ad and then calls the completion closure. Never used on banner ads.  
    g. `func invalidate() throws`, Called by the SDK before disposing of an ad. There's a no-op default implementation, and only some partner SDKs wil need to implement their own special cleanup.  

It also needs to store the `PartnerAdDelegate` that Chartboost Mediation SDK will pass to you, and call the following delegate methods to report your ad lifecycle events:  
    a. `func didTrackImpression(_ ad: PartnerAd, details: PartnerEventDetails)` when the partner SDK registers an impression for the currently showing ad.  
    b. `func didClick(_ ad: PartnerAd, details: PartnerEventDetails)` when the partner ad has been clicked as the result of a user action.  
    c. `func didReward(_ ad: PartnerAd, details: PartnerEventDetails)` when a reward has been given for watching a video ad.  
    d. `func didDismiss(_ ad: PartnerAd, details: PartnerEventDetails, error: Error?)` when the partner ad has been dismissed as the result of a user action.
    e. `func didExpire(_ ad: PartnerAd, details: PartnerEventDetails)` when the partner ad has expired as determined by the partner SDK.
10. Implement `func makeAd(request: PartnerAdLoadRequest, delegate: PartnerAdDelegate) throws -> PartnerAd`, which returns your `PartnerAd`-conforming objects.
11. In your `PartnerAd` ap the ad lifecycle events reported by your SDK to the appropriate `PartnerAdDelegate` methods on the 
12. Refer to the Helium SDK’s PartnerAdapter+Log.swift and PartnerAd+Log.swift for a complete list of log events to be used, and to PartnerAdapter+Error.swift and PartnerAd+Error.swift for a complete list of errors
TODO LINK
13. On the Helium web dashboard, add your full adapter class name so your mediation adapter and partner SDK can be initialized and interacted with for ad serving purposes.








An adapter must expose a class that conforms to the `PartnerAdapter` protocol. `PartnerAdapter` is [defined in the Mediation SDK documentation](https://reference.chartboost.com/mediation/ios/4.6.0/documentation/chartboostmediationsdk/), and thoroughly explained in code comments throughout the reference adapter. This README provides additional context.
<br>
<br>

### PartnerAdapter protocol
#### adapterVersion
If you're not clear on our versioning scheme after reading the code comment for `adapterVersion`, take a look at some other adapters and look at how the adapter version number includes the partner's SDK version number. One edge case to be aware of: although most partner SDKs use a three part version (1.2.3) some have a fourth number (1.2.3.4). In that case, we include it which results in an adapter version number is one section longer than usual (4.1.2.3.4.0)

#### partnerIdentifier
This must match the string used by ChartBoost's bidding server to identify your ad network.

#### partnerDisplayName
Human-friendly partner name. This string doesn't need to match how the partner name is written elsewhere, it is only used for the UI.

#### init()
This is a no-op for most adapters, but if you need to prevent the same placement ID from being loaded twice then hold onto a reference to `storage`, which provides visibility into which ads from your network the Mediation SDK currently has loaded. See the section about `makeAd()` for example code.

#### setUp()
Initialize the partner SDK. If a call to this method times out, the Mediation SDK will consider your adapter un-initialized even if you later report a successful init.

#### fetchBidderInformation()
If you are passing information back in the completion, the keys used in the dictionary depend on how your network's bidder was integrated with our backend. Usually Chartboost just passes these through to the bidding server, so whatever your RTB spec says probably applies here i.e. if your server expects bidder information in a field called 'token', then 'token' is probably the correct dictionary key to use here.

If your adapter doesn't support bidding, just pass `nil` to the completion.

#### setGDPR(), setCCPA(), setCOPPA()
Chartboost Mediation uses these to pass along publisher's privacy settings. They are always called at startup when Chartboost Mediation is initializing all the adapters. They will also be called any time the publisher updates privacy settings on the Mediation SDK.

These privacy methods aren't called until *after* `setUp`, so if your SDK requires privacy settings to be passed in at init then you will have to use default values on the very first launch and store the settings received by these methods for use on subsequent startups.

#### makeAd()
Every adapter will have a `switch` statement here that either returns a `PartnerAd` of the type specified in `request.format` or throws an error if the requested format isn't supported.

If your adapter supports Adaptive Banners or Rewarded Interstitials, you'll need to check for those within the `default` clause, to maintain backward compatibility.
```swift
default:
    // Not using the `.rewardedInterstitial` or `.adaptive_banner` cases directly to maintain backward compatibility with Chartboost Mediation 4.0
    if request.format.rawValue == "rewarded_interstitial" {
        return YourAdapterRewardedInterstitialAd(adapter: self, request: request, delegate: delegate)
    } else if request.format.rawValue == "adaptive_banner" {
        return YourAdapterAdapterBannerAd(adapter: self, request: request, delegate: delegate)
    } else {
        throw error(.loadFailureUnsupportedAdFormat)
    }
```
If the partner SDK doesn't support having more than one ad with the same placement ID loaded at the same time, you can save the `storage` that was passed into `init(storage: PartnerAdapterStorage)` and check to see what ads from your adapter the Mediation SDK is currently holding onto.
```swift
guard !storage.ads.contains(where: { $0.request.partnerPlacement == request.partnerPlacement })
        || request.format == .banner
    else {
        log("Failed to load ad for already loading placement \(request.partnerPlacement)")
        throw error(.loadFailureLoadInProgress)
    }
```
<br>
<br>

### PartnerAd protocol

Objects conforming to `PartnerAd` are used to wrap a single ad and provide an interface for managing its lifecycle. They're passed to Chartboost Mediation when it calls the `makeAd()` function on your class that conforms to `PartnerAdapter`.

#### delegate
The Mediation SDK will pass you this `PartnerDelegate` object as a parameter to `makeAd()` and you should report ad lifecycle events by calling its methods `didClick()`, `didDismiss()`, `didExpire()`, `didTrackImpression()`, and (if it's a rewarded ad) `didReward()`.

#### inlineView
Only used by banner ads, but required on all ads by the `PartnerAd` protocol. Storing other ad types in a public property isn't required. Instead, ChartBoost Mediation passes us a ViewController in the `show()` method that we use to display fullscreen ads.

#### load()
This is where you instantiate an ad from your network's SDK. If your ad uses an ADM from a bid response to construct an ad, it will be in `request.adm`. For non-bidding ads, the placement ID will be available in `request.partnerPlacement`.

For banner ads, there will not be a separate call to `show()`, so calls to `load()` should initiate a process that will end with the ad being displayable. After you know your ad has been successfully loaded, either through a callback or a delegate method, do any further manipulations of your banner ad are necessary to make it ready for display.

For all types of ad, the completion needs to be called after success or failure, otherwise Chartboost Mediation will keep waiting until eventually reaching a timeout.

#### show()
For non-banner ads, where loading and showing are separate steps, this is the method that is called when it's time for them to be displayed.

#### invalidate()
Most `PartnerAd`s don't implement this method, but if you need to do cleanup before your ad is deallocated the Mediation SDK will call this before disposing of an ad.
<br>
<br>

## Best Practices

Publishers using Chartboost Mediation SDK will not be importing the partner SDK directly - they will import this adapter and your SDK will be imported within the adapter, where the publisher's application doesn't have access to it.

If your SDK has configuration features that publishers need access to, make them available via a class called `[YourNetwork]AdapterConfiguration` that exposes public properties or methods.

Most adapters implement more than one ad type (i.e. [YourNetwork]BannerAd, [YourNetwork]InterstitialAd, etc). In that case, you can move some of the things required by `PartnerAd` into a parent class to reduce duplicated code. In this repo, you can see how `ReferenceAdapterAd` holds the `init()` function and several properties that don't differ between subclasses.

Also note that the `ReferenceAdapterFullscreenAd` subclass has an `ad` property that's necessary for holding a reference to the ad object. In `ReferenceAdapterBannerAd`, this additional property isn't necessary because `inlineView` holds the banner ad.

## Contributions

We are committed to a fully transparent development process and highly appreciate any contributions. Our team regularly monitors and investigates all submissions for the inclusion in our official adapter releases.

Refer to our [CONTRIBUTING](https://github.com/ChartBoost/chartboost-mediation-ios-adapter-reference/blob/main/CONTRIBUTING.md) file for more information on how to contribute.

## License

Refer to our [LICENSE](https://github.com/ChartBoost/chartboost-mediation-ios-adapter-reference/blob/main/LICENSE.md) file for more information.
