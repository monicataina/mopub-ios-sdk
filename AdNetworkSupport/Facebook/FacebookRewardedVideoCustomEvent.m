//
//  FacebookRewardedVideoCustomEvent.h
//  MoPubSDK
//
//  Copyright (c) 2016 MoPub. All rights reserved.
//

#import "FacebookRewardedVideoCustomEvent.h"
#import "MPFacebookRouter.h"
#import "MPRewardedVideoReward.h"
#import "MPRewardedVideoError.h"
#import "MPLogging.h"
#import "FacebookInstanceMediationSettings.h"
#import "MPInstanceProvider+Facebook.h"

static NSString *const kFacebookAdsOptionZoneIdKey = @"zoneId";

@interface FacebookRewardedVideoCustomEvent () <MPFacebookRouterDelegate>

@property (nonatomic, copy) NSString *zoneId;

@end

static int sFacebookIdentifier = -1;

@implementation FacebookRewardedVideoCustomEvent

+(void)initialize
{
    //force loading this class without -ObjC flag
    [MPFacebookInstanceProvider initialize];
}

- (void)dealloc
{
    [[MPFacebookRouter sharedRouter] clearDelegate:self];
    [super dealloc];
}

- (void)requestRewardedVideoWithCustomEventInfo:(NSDictionary *)info
{
    self.zoneId = [info objectForKey:kFacebookAdsOptionZoneIdKey];
    
    FacebookInstanceMediationSettings *settings = [self.delegate instanceMediationSettingsForClass:[FacebookInstanceMediationSettings class]];
    NSString *customerId = [self.delegate customerIdForRewardedVideoCustomEvent:self];
    
    [[MPFacebookRouter sharedRouter] requestRewardedVideoAdWithZoneId:self.zoneId customerId:customerId settings:settings delegate:self];
}

- (BOOL)hasAdAvailable
{
    return [[MPFacebookRouter sharedRouter] isAdAvailableForZoneId:self.zoneId];
}

- (void)presentRewardedVideoFromViewController:(UIViewController *)viewController
{
    if ([self hasAdAvailable]) {
        FacebookInstanceMediationSettings *settings = [self.delegate instanceMediationSettingsForClass:[FacebookInstanceMediationSettings class]];
        NSString *customerId = [self.delegate customerIdForRewardedVideoCustomEvent:self];
        
        [[MPFacebookRouter sharedRouter] presentRewardedVideoAdFromViewController:viewController customerId:customerId zoneId:self.zoneId settings:settings delegate:self];
    } else {
        MPLogInfo(@"Failed to show Facebook rewarded video: Facebook now claims that there is no available video ad.");
        NSError *error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorNoAdsAvailable userInfo:nil];
        [self.delegate rewardedVideoDidFailToPlayForCustomEvent:self error:error];
    }
}

- (void)handleCustomEventInvalidated
{
    [[MPFacebookRouter sharedRouter] clearDelegate:self];
}

- (void)handleAdPlayedForCustomEventNetwork
{
    // If we no longer have an ad available, report back up to the application that this ad expired.
    // We receive this message only when this ad has reported an ad has loaded and another ad unit
    // has played a video for the same ad network.
    if (![self hasAdAvailable]) {
        [self.delegate rewardedVideoDidExpireForCustomEvent:self];
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

#pragma mark - MPFacebookRouterDelegate

- (void)facebookVideoCompleted:(NSString *)rewardItemKey rewardAmount:(NSNumber *)rewardAmount
{
}
- (void)facebookVideoAdServerSuccess:(NSString *)rewardItemKey rewardAmount:(NSNumber *)rewardAmount
{
    NSString *currencyType = kMPRewardedVideoRewardCurrencyTypeUnspecified;
    if (rewardItemKey) {
        currencyType = rewardItemKey;
    }
    NSNumber *amount = @(kMPRewardedVideoRewardCurrencyAmountUnspecified);
    if(rewardAmount)
    {
        amount = rewardAmount;
    }
    MPRewardedVideoReward *reward = [[MPRewardedVideoReward alloc] initWithCurrencyType:currencyType amount:amount];
    [self.delegate rewardedVideoShouldRewardUserForCustomEvent:self reward:reward];
}
- (void)facebookVideoAdServerFailed:(NSString *)rewardItemKey rewardAmount:(NSNumber *)rewardAmount
{
    NSString *currencyType = kMPRewardedVideoRewardCurrencyTypeUnspecified;
    if (rewardItemKey) {
        currencyType = rewardItemKey;
    }
    NSNumber *amount = @(kMPRewardedVideoRewardCurrencyAmountUnspecified);
    if(rewardAmount)
    {
        amount = rewardAmount;
    }
    MPRewardedVideoReward *reward = [[MPRewardedVideoReward alloc] initWithCurrencyType:currencyType amount:amount];
    [self.delegate rewardedVideoFailedToRewardUserForCustomEvent:self reward:reward];
}

- (void)facebookWillShow
{
    [self.delegate rewardedVideoWillAppearForCustomEvent:self];
}

- (void)facebookDidShow
{
    [self.delegate rewardedVideoDidAppearForCustomEvent:self];
}

- (void)facebookWillHide
{
    [self.delegate rewardedVideoWillDisappearForCustomEvent:self];
}

- (void)facebookDidHide
{
    [self.delegate rewardedVideoDidDisappearForCustomEvent:self];
}

- (void)facebookWillLeaveApplication
{
    [self.delegate rewardedVideoWillLeaveApplicationForCustomEvent:self];
}

- (void)facebookFetchCompleted
{
    [self.delegate rewardedVideoDidLoadAdForCustomEvent:self];
}

- (void)facebookDidClick
{
    [self.delegate rewardedVideoDidReceiveTapEventForCustomEvent:self];
}

- (void)facebookDidFailWithError:(NSError *)error
{
    [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
}

@end
