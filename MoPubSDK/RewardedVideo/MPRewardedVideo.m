//
//  MPRewardedVideo.m
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import "MPRewardedVideo.h"
#import "MPLogging.h"
#import "MPRewardedVideoAdManager.h"
#import "MPInstanceProvider.h"
#import "MPRewardedVideoError.h"
#import "MPRewardedVideoConnection.h"
#import "MPRewardedVideo+Internal.h"
#import "MPRewardedVideoCustomEvent.h"

static MPRewardedVideo *gSharedInstance = nil;

@interface MPRewardedVideo () <MPRewardedVideoAdManagerDelegate, MPRewardedVideoConnectionDelegate>

@property (nonatomic, strong) NSMutableDictionary *rewardedVideoAdManagers;
@property (nonatomic) NSMutableArray *rewardedVideoConnections;

+ (MPRewardedVideo *)sharedInstance;

@end

@implementation MPRewardedVideo

- (instancetype)init
{
    if (self = [super init]) {
        _rewardedVideoAdManagers = [[NSMutableDictionary alloc] init];
        _rewardedVideoConnections = [NSMutableArray new];
    }

    return self;
}

+ (void)loadRewardedVideoAdWithAdUnitID:(NSString *)adUnitID withMediationSettings:(NSArray *)mediationSettings  delegate:(id<MPRewardedVideoDelegate>)delegate
{
    [MPRewardedVideo loadRewardedVideoAdWithAdUnitID:adUnitID keywords:nil location:nil mediationSettings:mediationSettings delegate:delegate];
}

+ (void)loadRewardedVideoAdWithAdUnitID:(NSString *)adUnitID keywords:(NSString *)keywords location:(CLLocation *)location mediationSettings:(NSArray *)mediationSettings delegate:(id<MPRewardedVideoDelegate>)delegate
{
    [self loadRewardedVideoAdWithAdUnitID:adUnitID keywords:keywords location:location customerId:nil mediationSettings:mediationSettings delegate:delegate];
}

+ (void)loadRewardedVideoAdWithAdUnitID:(NSString *)adUnitID keywords:(NSString *)keywords location:(CLLocation *)location customerId:(NSString *)customerId mediationSettings:(NSArray *)mediationSettings delegate:(id<MPRewardedVideoDelegate>)delegate
{
    MPRewardedVideo *sharedInstance = [[self class] sharedInstance];

    if (![adUnitID length]) {
        NSError *error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorInvalidAdUnitID userInfo:nil];
        [delegate rewardedVideoAdDidFailToLoadForAdUnitID:adUnitID forCustomClassID:-1 error:error];
        return;
    }

    MPRewardedVideoAdManager *adManager = sharedInstance.rewardedVideoAdManagers[adUnitID];

    if (!adManager) {
        adManager = [[MPInstanceProvider sharedProvider] buildRewardedVideoAdManagerWithAdUnitID:adUnitID delegate:sharedInstance rewardDelegate:delegate];
        sharedInstance.rewardedVideoAdManagers[adUnitID] = adManager;
    }

    adManager.mediationSettings = mediationSettings;

    [adManager loadRewardedVideoAdWithKeywords:keywords location:location customerId:customerId];
}

+ (BOOL)hasAdAvailableForAdUnitID:(NSString *)adUnitID
{
    MPRewardedVideo *sharedInstance = [[self class] sharedInstance];
    MPRewardedVideoAdManager *adManager = sharedInstance.rewardedVideoAdManagers[adUnitID];

    return [adManager hasAdAvailable];
}

+ (void)presentRewardedVideoAdForAdUnitID:(NSString *)adUnitID fromViewController:(UIViewController *)viewController
{
    MPRewardedVideo *sharedInstance = [[self class] sharedInstance];
    MPRewardedVideoAdManager *adManager = sharedInstance.rewardedVideoAdManagers[adUnitID];

    if (!adManager) {
        MPLogWarn(@"The rewarded video could not be shown: "
                  @"no ads have been loaded for adUnitID: %@", adUnitID);

        return;
    }

    if (!viewController) {
        MPLogWarn(@"The rewarded video could not be shown: "
                  @"a nil view controller was passed to -presentRewardedVideoAdForAdUnitID:fromViewController:.");

        return;
    }

    if (![viewController.view.window isKeyWindow]) {
        MPLogWarn(@"Attempting to present a rewarded video ad in non-key window. The ad may not render properly.");
    }

    [adManager presentRewardedVideoAdFromViewController:viewController];
}

#pragma mark - Private

+ (MPRewardedVideo *)sharedInstance
{
    static dispatch_once_t once;

    dispatch_once(&once, ^{
        gSharedInstance = [[self alloc] init];
    });

    return gSharedInstance;
}

// This is private as we require the developer to initialize rewarded video through the MoPub object.
+ (void)initializeRewardedVideo
{
    MPRewardedVideo *sharedInstance = [[self class] sharedInstance];

    static bool isInitialized = false;
    
    // Do not allow calls to initialize twice.
    if (isInitialized) {
        MPLogWarn(@"Attempting to initialize MPRewardedVideo when it has already been initialized.");
    } else {
        isInitialized = true;
    }
}

#pragma mark - MPRewardedVideoAdManagerDelegate

- (void)rewardedVideoDidLoadForAdManager:(MPRewardedVideoAdManager *)manager
{
    if ([manager.rewardDelegate respondsToSelector:@selector(rewardedVideoAdDidLoadForAdUnitID:forCustomClassID:)]) {
        int customEventID = [manager getCustomEventIdentifier];
        [manager.rewardDelegate rewardedVideoAdDidLoadForAdUnitID:manager.adUnitID forCustomClassID:customEventID];
    }
}

- (void)rewardedVideoDidFailToLoadForAdManager:(MPRewardedVideoAdManager *)manager error:(NSError *)error
{
    if ([manager.rewardDelegate respondsToSelector:@selector(rewardedVideoAdDidFailToLoadForAdUnitID:forCustomClassID:error:)]) {
        int customEventID = [manager getCustomEventIdentifier];
        [manager.rewardDelegate rewardedVideoAdDidFailToLoadForAdUnitID:manager.adUnitID forCustomClassID:customEventID error:error];
    }
}

- (void)rewardedVideoDidExpireForAdManager:(MPRewardedVideoAdManager *)manager
{
    if ([manager.rewardDelegate respondsToSelector:@selector(rewardedVideoAdDidExpireForAdUnitID:forCustomClassID:)]) {
        int customEventID = [manager getCustomEventIdentifier];
        [manager.rewardDelegate rewardedVideoAdDidExpireForAdUnitID:manager.adUnitID forCustomClassID:customEventID];
    }
}

- (void)rewardedVideoDidFailToPlayForAdManager:(MPRewardedVideoAdManager *)manager error:(NSError *)error
{
    if ([manager.rewardDelegate respondsToSelector:@selector(rewardedVideoAdDidFailToPlayForAdUnitID:forCustomClassID:error:)]) {
        int customEventID = [manager getCustomEventIdentifier];
        [manager.rewardDelegate rewardedVideoAdDidFailToPlayForAdUnitID:manager.adUnitID forCustomClassID:customEventID error:error];
    }
}

- (void)rewardedVideoWillAppearForAdManager:(MPRewardedVideoAdManager *)manager
{
    if ([manager.rewardDelegate respondsToSelector:@selector(rewardedVideoAdWillAppearForAdUnitID:forCustomClassID:)]) {
        int customEventID = [manager getCustomEventIdentifier];
        [manager.rewardDelegate rewardedVideoAdWillAppearForAdUnitID:manager.adUnitID forCustomClassID:customEventID];
    }
}

- (void)rewardedVideoDidAppearForAdManager:(MPRewardedVideoAdManager *)manager
{
    if ([manager.rewardDelegate respondsToSelector:@selector(rewardedVideoAdDidAppearForAdUnitID:forCustomClassID:)]) {
        int customEventID = [manager getCustomEventIdentifier];
        [manager.rewardDelegate rewardedVideoAdDidAppearForAdUnitID:manager.adUnitID forCustomClassID:customEventID];
    }
}

- (void)rewardedVideoWillDisappearForAdManager:(MPRewardedVideoAdManager *)manager
{
    if ([manager.rewardDelegate respondsToSelector:@selector(rewardedVideoAdWillDisappearForAdUnitID:forCustomClassID:)]) {
        int customEventID = [manager getCustomEventIdentifier];
        [manager.rewardDelegate rewardedVideoAdWillDisappearForAdUnitID:manager.adUnitID forCustomClassID:customEventID];
    }
}

- (void)rewardedVideoDidDisappearForAdManager:(MPRewardedVideoAdManager *)manager
{
    if ([manager.rewardDelegate respondsToSelector:@selector(rewardedVideoAdDidDisappearForAdUnitID:forCustomClassID:)]) {
        int customEventID = [manager getCustomEventIdentifier];
        [manager.rewardDelegate rewardedVideoAdDidDisappearForAdUnitID:manager.adUnitID forCustomClassID:customEventID];
    }

    // Since multiple ad units may be attached to the same network, we should notify the custom events (which should then notify the application)
    // that their ads may not be available anymore since another ad unit might have "played" their ad. We go through and notify all ad managers
    // that are of the type of ad that is playing now.
    Class customEventClass = manager.customEventClass;

    for (id key in self.rewardedVideoAdManagers) {
        MPRewardedVideoAdManager *adManager = self.rewardedVideoAdManagers[key];

        if (adManager != manager && adManager.customEventClass == customEventClass) {
            [adManager handleAdPlayedForCustomEventNetwork];
        }
    }
}

- (void)rewardedVideoDidReceiveTapEventForAdManager:(MPRewardedVideoAdManager *)manager
{
    if ([manager.rewardDelegate respondsToSelector:@selector(rewardedVideoAdDidReceiveTapEventForAdUnitID:forCustomClassID:)]) {
        int customEventID = [manager getCustomEventIdentifier];
        [manager.rewardDelegate rewardedVideoAdDidReceiveTapEventForAdUnitID:manager.adUnitID forCustomClassID:customEventID];
    }
}

- (void)rewardedVideoWillLeaveApplicationForAdManager:(MPRewardedVideoAdManager *)manager
{
    if ([manager.rewardDelegate respondsToSelector:@selector(rewardedVideoAdWillLeaveApplicationForAdUnitID:forCustomClassID:)]) {
        int customEventID = [manager getCustomEventIdentifier];
        [manager.rewardDelegate rewardedVideoAdWillLeaveApplicationForAdUnitID:manager.adUnitID forCustomClassID:customEventID];
    }
}

- (void)rewardedVideoShouldRewardUserForAdManager:(MPRewardedVideoAdManager *)manager reward:(MPRewardedVideoReward *)reward
{
    if ([manager.rewardDelegate respondsToSelector:@selector(rewardedVideoAdShouldRewardForAdUnitID:forCustomClassID:reward:)]) {
        int customEventID = [manager getCustomEventIdentifier];
        [manager.rewardDelegate rewardedVideoAdShouldRewardForAdUnitID:manager.adUnitID forCustomClassID:customEventID reward:reward];
    }
}

#pragma mark - rewarded video server to server callback

- (void)startRewardedVideoConnectionWithUrl:(NSURL *)url
{
    MPRewardedVideoConnection *connection = [[MPRewardedVideoConnection alloc] initWithUrl:url delegate:self];
    [self.rewardedVideoConnections addObject:connection];
    [connection sendRewardedVideoCompletionRequest];
}

#pragma mark - MPRewardedVideoConnectionDelegate

- (void)rewardedVideoConnectionCompleted:(MPRewardedVideoConnection *)connection url:(NSURL *)url
{
    [self.rewardedVideoConnections removeObject:connection];
}

@end
