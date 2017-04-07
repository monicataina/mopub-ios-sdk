//
//  FacebookRewardedVideoCustomEvent.h
//  MoPubSDK
//
//  Copyright (c) 2016 MoPub. All rights reserved.
//

#import "FacebookRewardedVideoCustomEvent.h"
#ifdef ADS_MANAGER_USE_FACEBOOK_VIA_MOPUB

#import "MPRewardedVideoReward.h"
#import "MPRewardedVideoError.h"
#import "MPLogging.h"
#import "MoPub.h"
#import "FacebookInstanceMediationSettings.h"
#import "FacebookGlobalMediationSettings.h"
#include <FBAudienceNetwork/FBAudienceNetwork.h>

static NSString *const kFacebookAdsOptionZoneIdKey = @"zoneId";
static NSString *const kFacebookAdsOptionPlacementIdKey = @"placementId";

@interface FacebookRewardedVideoCustomEvent () <FBRewardedVideoAdDelegate>

@property (nonatomic, assign) NSString *zoneId;

@property (nonatomic, retain) FBRewardedVideoAd *loadingAd;
@property (nonatomic, strong) NSString* rewardCurrencyForLoadingAd;
@property (nonatomic, strong) NSNumber* rewardAmountForLoadingAd;

@property (nonatomic, retain) FBRewardedVideoAd *displayedAd;
@property (nonatomic, assign) NSString* rewardCurrencyForDisplayedAd;
@property (nonatomic, assign) NSNumber* rewardAmountForDisplayedAd;

@property (nonatomic, assign) BOOL isAdClosed;
@property (nonatomic, assign) BOOL isRewardCallbackCalled;
@end

static int sFacebookIdentifier = -1;

@implementation FacebookRewardedVideoCustomEvent

- (void)requestRewardedVideoWithCustomEventInfo:(NSDictionary *)info
{
    FacebookGlobalMediationSettings *globalSettings = [[MoPub sharedInstance] globalMediationSettingsForClass:[FacebookGlobalMediationSettings class]];
    
    if(globalSettings.isCOPPA)
    {
        MPLogInfo(@"FAN ads are disabled because user is under 13 yo (COPPA)");
        NSError *error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorNoAdsAvailable userInfo:nil];
        [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
        return;
    }
    
    self.zoneId = [info objectForKey:kFacebookAdsOptionZoneIdKey];
    if (self.zoneId == nil) {
        self.zoneId = [info objectForKey:kFacebookAdsOptionPlacementIdKey];
    }
    if (self.zoneId == nil) {
        MPLogInfo(@"Custom event class data did not contain placementId.");
        NSError *error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorInvalidCustomEvent userInfo:@{NSLocalizedDescriptionKey: @"Custom event class data did not contain placementId.", NSLocalizedRecoverySuggestionErrorKey: @"Update your MoPub custom event class data to contain a valid FAN Ads placementId."}];
        [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
        return;
    }
    
    FacebookInstanceMediationSettings *settings = [self.delegate instanceMediationSettingsForClass:[FacebookInstanceMediationSettings class]];
   // NSString *customerId = [self.delegate customerIdForRewardedVideoCustomEvent:self];
    
    static dispatch_once_t facebookInitToken;
    dispatch_once(&facebookInitToken, ^{
        if(globalSettings.useTestDevice == YES)
        {
            //set the current device as test device for FAN ads
            [FBAdSettings addTestDevice:[FBAdSettings testDeviceHash]];
        }
    #ifdef FB_AD_SDK_VERSION
        MPLogInfo(@"FAN SDK version: %@",FB_AD_SDK_VERSION);
    #endif //FB_AD_SDK_VERSION
    });

    NSString* userId = NULL;
  //  if (customerId.length >0) {
  //      userId = customerId;
  /*  } else*/ if (settings.userIdentifier.length > 0) {
        userId = settings.userIdentifier;
    }
    
    self.rewardCurrencyForLoadingAd = kMPRewardedVideoRewardCurrencyTypeUnspecified;
    if(settings.rewardCurrencyName.length > 0){
        self.rewardCurrencyForLoadingAd = settings.rewardCurrencyName;
    }
    
    self.rewardAmountForLoadingAd = @(kMPRewardedVideoRewardCurrencyAmountUnspecified);
    if(settings.rewardAmount > 0){
        self.rewardAmountForLoadingAd = [NSNumber numberWithInteger:settings.rewardAmount];
    }

    if(self.loadingAd)
    {
        self.loadingAd = NULL;
    }
    self.loadingAd = [[FBRewardedVideoAd new] initWithPlacementID:self.zoneId withUserID:userId withCurrency:self.rewardCurrencyForLoadingAd withAmount:[self.rewardAmountForLoadingAd intValue]];
    self.loadingAd.delegate = self;
    [self.loadingAd loadAd];
}

- (BOOL)hasAdAvailable
{
    FacebookGlobalMediationSettings *globalSettings = [[MoPub sharedInstance] globalMediationSettingsForClass:[FacebookGlobalMediationSettings class]];
    if(globalSettings.isCOPPA)
    {
        MPLogInfo(@"FAN ads are disabled because user is under 13 yo (COPPA)");
        return NO;
    }
    
    if(!self.loadingAd)
    {
        return NO;
    }
    return [self.loadingAd isAdValid];
}

- (void)presentRewardedVideoFromViewController:(UIViewController *)viewController
{
    if ([self hasAdAvailable]) {
        FacebookInstanceMediationSettings *settings = [self.delegate instanceMediationSettingsForClass:[FacebookInstanceMediationSettings class]];
        NSString *customerId = [self.delegate customerIdForRewardedVideoCustomEvent:self];
        
        self.displayedAd = self.loadingAd;
        self.loadingAd = NULL;
        self.rewardAmountForDisplayedAd = self.rewardAmountForLoadingAd;
        self.rewardCurrencyForDisplayedAd = self.rewardCurrencyForLoadingAd;
        self.isAdClosed = NO;
        self.isRewardCallbackCalled = NO;
        
        [self.displayedAd showAdFromRootViewController:viewController];
    } else {
        MPLogInfo(@"Failed to show Facebook rewarded video: Facebook now claims that there is no available video ad.");
        NSError *error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorNoAdsAvailable userInfo:nil];
        [self.delegate rewardedVideoDidFailToPlayForCustomEvent:self error:error];
    }
}

+ (void)setCustomEventIdentifier:(int)identifier
{
    sFacebookIdentifier = identifier;
}

+ (int)getCustomEventIdentifier
{
    return sFacebookIdentifier;
}

#pragma mark - FBRewardedVideoAdDelegate

/*!
 @method
 
 @abstract
 Sent after the FBRewardedVideoAd object has finished playing the video successfully.
 Reward the user on this callback.
 
 @param rewardedVideoAd An FBRewardedVideoAd object sending the message.
 */
- (void)rewardedVideoAdComplete:(FBRewardedVideoAd *)rewardedVideoAd
{
    if(rewardedVideoAd)
    {
        MPLogInfo(@"FAN rewardedVideoAdComplete for %@",rewardedVideoAd.placementID);
    }
    
    self.isRewardCallbackCalled = YES;
    if(self.displayedAd && self.displayedAd == rewardedVideoAd)
    {
        MPRewardedVideoReward *reward = [[MPRewardedVideoReward alloc] initWithCurrencyType:self.rewardCurrencyForDisplayedAd amount:self.rewardAmountForDisplayedAd];
        
        if(self.isAdClosed == YES)
        {
            self.isAdClosed = NO;
            self.isRewardCallbackCalled = NO;
            self.displayedAd = NULL;
        }
        [self.delegate rewardedVideoShouldRewardUserForCustomEvent:self reward:reward];
    }
    else
    {
        //add this code for FAN bug : this callback is called by all loaded ads. It should be called only by the displayed ad
        if(self.loadingAd == rewardedVideoAd)
        {
            //set other as expired so that MoPub will load them again on the next loadAd call
            [self.delegate rewardedVideoDidExpireForCustomEvent:self];
        }
    }
}

/*!
 @method
 
 @abstract
 Sent if server call to publisher's reward endpoint returned HTTP status code 200.
 
 @param rewardedVideoAd An FBRewardedVideoAd object sending the message.
 */
- (void)rewardedVideoAdServerSuccess:(FBRewardedVideoAd *)rewardedVideoAd
{
    if(rewardedVideoAd)
    {
        MPLogInfo(@"FAN rewardedVideoAdServerSuccess for %@",rewardedVideoAd.placementID);
    }
}

/*!
 @method
 
 @abstract
 Sent if server call to publisher's reward endpoint did not return HTTP status code 200
 or if the endpoint timed out.
 
 @param rewardedVideoAd An FBRewardedVideoAd object sending the message.
 */
- (void)rewardedVideoAdServerFailed:(FBRewardedVideoAd *)rewardedVideoAd
{
    if(rewardedVideoAd)
    {
        MPLogInfo(@"FAN rewardedVideoAdServerFailed for %@",rewardedVideoAd.placementID);
    }
}

/*!
 @method
 
 @abstract
 Sent immediately before the impression of an FBRewardedVideoAd object will be logged.
 
 @param rewardedVideoAd An FBRewardedVideoAd object sending the message.
 */
- (void)rewardedVideoAdWillLogImpression:(FBRewardedVideoAd *)rewardedVideoAd
{
    if(self.displayedAd && self.displayedAd == rewardedVideoAd)
    {
        [self.delegate rewardedVideoWillAppearForCustomEvent:self];
        [self.delegate rewardedVideoDidAppearForCustomEvent:self];
    }
}

/*!
 @method
 
 @abstract
 Sent after an FBRewardedVideoAd object has been dismissed from the screen, returning control
 to your application.
 
 @param rewardedVideoAd An FBRewardedVideoAd object sending the message.
 */
- (void)rewardedVideoAdDidClose:(FBRewardedVideoAd *)rewardedVideoAd
{
    self.isAdClosed = YES;
    if(self.displayedAd && self.displayedAd == rewardedVideoAd)
    {
        if(self.isRewardCallbackCalled == YES)
        {
            self.isAdClosed = NO;
            self.isRewardCallbackCalled = NO;
            self.displayedAd = NULL;
        }
        [self.delegate rewardedVideoDidDisappearForCustomEvent:self];
    }
    
}

/*!
 @method
 
 @abstract
 Sent immediately before an FBRewardedVideoAd object will be dismissed from the screen.
 
 @param rewardedVideoAd An FBRewardedVideoAd object sending the message.
 */
- (void)rewardedVideoAdWillClose:(FBRewardedVideoAd *)rewardedVideoAd
{
    if(self.displayedAd && self.displayedAd == rewardedVideoAd)
    {
        [self.delegate rewardedVideoWillDisappearForCustomEvent:self];
    }
}

/*!
 @method
 
 @abstract
 Sent when an ad has been successfully loaded.
 
 @param rewardedVideoAd An FBRewardedVideoAd object sending the message.
 */
- (void)rewardedVideoAdDidLoad:(FBRewardedVideoAd *)rewardedVideoAd
{
    if(self.loadingAd && self.loadingAd == rewardedVideoAd)
    {
        [self.delegate rewardedVideoDidLoadAdForCustomEvent:self];
    }
}

/*!
 @method
 
 @abstract
 Sent after an ad has been clicked by the person.
 
 @param rewardedVideoAd An FBRewardedVideoAd object sending the message.
 */
- (void)rewardedVideoAdDidClick:(FBRewardedVideoAd *)rewardedVideoAd
{
    if(self.displayedAd && self.displayedAd == rewardedVideoAd)
    {
        [self.delegate rewardedVideoDidReceiveTapEventForCustomEvent:self];
    }
}

/*!
 @method
 
 @abstract
 Sent after an FBRewardedVideoAd fails to load the ad.
 
 @param rewardedVideoAd An FBRewardedVideoAd object sending the message.
 @param error An error object containing details of the error.
 */
- (void)rewardedVideoAd:(FBRewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error
{
    if(self.loadingAd && self.loadingAd == rewardedVideoAd)
    {
        self.loadingAd = NULL;
        [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
    }
}

@end
#endif //ADS_MANAGER_USE_FACEBOOK_VIA_MOPUB
