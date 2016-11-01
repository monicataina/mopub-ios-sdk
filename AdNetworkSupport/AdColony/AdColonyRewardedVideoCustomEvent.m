//
//  AdColonyRewardedVideoCustomEvent.m
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import <AdColony/AdColony.h>

#import "AdColonyRewardedVideoCustomEvent.h"
#import "AdColonyInstanceMediationSettings.h"
#import "AdColonyCustomEvent.h"
#import "MoPub.h"
#import "MPAdColonyRouter.h"
#import "MPInstanceProvider+AdColony.h"
#import "MPLogging.h"
#import "MPRewardedVideoReward.h"

@interface AdColonyRewardedVideoCustomEvent () <MPAdColonyRouterDelegate>

@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *zoneId;
@property (nonatomic, assign) BOOL zoneAvailable;

@end

static int sAdColonyIdentifier = -1;

@implementation AdColonyRewardedVideoCustomEvent

+(void)initialize
{
    //force loading this class without -ObjC flag
    [MPAdColonyInstanceProvider initialize];
}

- (void)requestRewardedVideoWithCustomEventInfo:(NSDictionary *)info
{
    self.appId = [info objectForKey:@"appId"];
    NSArray *allZoneIds = [info objectForKey:@"allZoneIds"];
    NSString *zoneId = [info objectForKey:@"zoneId"];

    NSString *customerId = [self.delegate customerIdForRewardedVideoCustomEvent:self];

    if(self.appId != nil)
    {
        [[MPAdColonyRouter sharedRouter] addGlobalCustomEvent:self];
    }
    self.zoneId = zoneId;
    self.zoneAvailable = NO;
    
    if(self.zoneId != nil && self.appId != nil) {
        [[MPAdColonyRouter sharedRouter] setCustomEvent:self forZoneId:self.zoneId];
    }
    
    BOOL configureIsCalled = [AdColonyCustomEvent initializeAdColonyCustomEventWithAppId:self.appId allZoneIds:allZoneIds customerId:customerId forZoneId:zoneId];

    if(!configureIsCalled)
    {
        // Set the customID again since the above init call can only run once. We want to set the customID
        // if the caller gives us a customer id.
        if (customerId.length > 0) {
            AdColonyAppOptions* options = [AdColony getAppOptions];
            if(options != nil)
            {
                if(options.userID == nil || [options.userID compare:customerId] != NSOrderedSame)
                {
                    options.userID = customerId;
                    [AdColony setAppOptions:options];
                }
            }
            else
            {
                //this case should not happen because the an app option is created in init call
            }
        }
        
        [self requestRewardedVideoWithCurrentZoneId];
    }
//    if([self hasAdAvailable]) {
//        MPLogInfo(@"AdColony zone %@ available", self.zoneId);
//        [self zoneDidLoad];
//    }
}
- (void)requestRewardedVideoWithCurrentZoneId
{
    if(self.zoneId != nil && self.appId != nil)
    {
        if(![MPAdColonyRouter sharedRouter].isWaitingForInit)
        {
            AdColonyInstanceMediationSettings *settings = [self.delegate instanceMediationSettingsForClass:[AdColonyInstanceMediationSettings class]];
            BOOL showPrePopup = (settings) ? settings.showPrePopup : NO;
            BOOL showPostPopup = (settings) ? settings.showPostPopup : NO;
            [[MPAdColonyRouter sharedRouter] requestVideoAdWithZoneId:self.zoneId showPrePopup:showPrePopup showPostPopup:showPostPopup];
        }
    }
}

- (BOOL)hasAdAvailable
{
    return [[MPAdColonyRouter sharedRouter] hasAdAvailableForZone:self.zoneId];
}

- (void)presentRewardedVideoFromViewController:(UIViewController *)viewController
{
    if ([self hasAdAvailable]) {
        MPLogInfo(@"AdColony zone %@ attempting to start", self.zoneId);
        
        //set reward callback
        AdColonyZone* zone = [AdColony zoneForID:self.zoneId];
        if(zone != nil && zone.enabled)
        {
            /* Set the zone's reward handler block */
            zone.reward = ^(BOOL success, NSString* currencyName, int amount) {
                MPRewardedVideoReward *reward = [[MPRewardedVideoReward alloc] initWithCurrencyType:currencyName amount:@(amount)];
                [self shouldRewardUserWithReward:reward];
            };
        }
        
        [[MPAdColonyRouter sharedRouter] showAdForZone:self.zoneId withViewController:viewController];

        [self.delegate rewardedVideoWillAppearForCustomEvent:self];
    } else {
        MPLogInfo(@"Failed to show AdColony rewarded video: AdColony now claims zone %@ is not available", self.zoneId);
        NSError *error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorNoAdsAvailable userInfo:nil];
        [self.delegate rewardedVideoDidFailToPlayForCustomEvent:self error:error];
    }
}

- (void)handleAdPlayedForCustomEventNetwork
{
    // If we no longer have an ad available, report back up to the application that this ad expired.
    // We receive this message only when this custom event has reported its ad has loaded and another ad unit
    // has played a video for the same ad network.
    if (![self hasAdAvailable]) {
        [self.delegate rewardedVideoDidExpireForCustomEvent:self];
    }
}

- (void)handleCustomEventInvalidated
{
    [[MPAdColonyRouter sharedRouter] removeCustomEvent:self forZoneId:self.zoneId];
}

+ (void)setCustomEventIdentifier:(int)identifier
{
    sAdColonyIdentifier = identifier;
}

+ (int)getCustomEventIdentifier
{
    return sAdColonyIdentifier;
}

#pragma mark - MPAdColonyRouterDelegate

- (void)configured
{
    [self requestRewardedVideoWithCurrentZoneId];
}

- (void)onAdStartedInZone:(NSString *)zoneID
{
    MPLogInfo(@"AdColony zone %@ started", zoneID);
    [self.delegate rewardedVideoDidAppearForCustomEvent:self];
}

- (void)onAdAttemptFinished:(BOOL)shown inZone:(NSString *)zoneID
{
    MPLogInfo(@"AdColony zone %@ finished", zoneID);
    [self.delegate rewardedVideoWillDisappearForCustomEvent:self];
    [self.delegate rewardedVideoDidDisappearForCustomEvent:self];
}

- (void)zoneDidLoad
{
    self.zoneAvailable = YES;
    [self.delegate rewardedVideoDidLoadAdForCustomEvent:self];
}
- (void)zoneDidFailToLoad:(NSError *)error
{
    self.zoneId = nil;
    [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
}

- (void)zoneDidExpire
{
    self.zoneAvailable = NO;
    [self.delegate rewardedVideoDidExpireForCustomEvent:self];
}

- (void)shouldRewardUserWithReward:(MPRewardedVideoReward *)reward
{
    [self.delegate rewardedVideoShouldRewardUserForCustomEvent:self reward:reward];
}

@end
