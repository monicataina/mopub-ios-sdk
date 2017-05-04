//
//  MPUnityRouter.m
//  MoPubSDK
//
//  Copyright (c) 2016 MoPub. All rights reserved.
//

#include "AdsManager_internal_config.h"
#ifdef ADS_MANAGER_USE_UNITY_VIA_MOPUB

#import "MoPub.h"
#import "MPUnityRouter.h"
#import "UnityAdsInstanceMediationSettings.h"
#import "MPInstanceProvider+Unity.h"
#import "MPRewardedVideoError.h"
#import "MPRewardedVideo.h"

#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@interface MPUnityRouter ()

@property (nonatomic, assign) BOOL isAdPlaying;

@property (nonatomic, strong) UADSPlayerMetaData *m_playerMetaData;

@end

@implementation MPUnityRouter

+ (MPUnityRouter *)sharedRouter
{
    return [[MPInstanceProvider sharedProvider] sharedMPUnityRouter];
}

- (MPUnityRouter *)init
{
    self = [super init];
    self.m_playerMetaData = [[UADSPlayerMetaData alloc] init];
    
    self.m_delegates = [[NSMutableArray alloc] init];
    
    return self;
}

- (void)requestVideoAdWithGameId:(NSString *)gameId placementId:(NSString *)placementId settings:(UnityAdsInstanceMediationSettings *)settings delegate:(id<MPUnityRouterDelegate>)delegate;
{
    if(SYSTEM_VERSION_LESS_THAN(@"7.0"))
    {
        //unity crashes on ios less than 7, so won't try to show an ad on iOS6
        NSError *error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorUnknown userInfo:nil];
        [delegate unityAdsDidFailWithError:error];
    }
    else
    {
        if (!self.isAdPlaying) {
            [self.m_delegates addObject:delegate];

            static dispatch_once_t unityInitToken;
            dispatch_once(&unityInitToken, ^{
                UADSMediationMetaData *mediationMetaData = [[UADSMediationMetaData alloc] init];
                [mediationMetaData setName:@"MoPub"];
                [mediationMetaData setVersion:[[MoPub sharedInstance] version]];
                [mediationMetaData commit];
                if([UnityAds isInitialized])
                {
                    //update Unity
                    //note that gameId and testMode won't be updated in this case. It will use the values set when app started
                    [UnityAds setDelegate:self];
                }
                else
                {
                    //initialize Unity for the first time
                    [UnityAds initialize:gameId delegate:self testMode:settings.useTestDevice];
                }
            });

            // Need to check immediately as an ad may be cached.
            if ([self isAdAvailableForPlacementId:placementId]) {
                [delegate unityAdsReady:placementId];
            }
            // MoPub timeout will handle the case for an ad failing to load.
        } else {
            NSError *error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorUnknown userInfo:nil];
            [delegate unityAdsDidFailWithError:error];
        }
    }
}

- (BOOL)isAdAvailableForPlacementId:(NSString *)placementId
{
    return [UnityAds isReady:placementId];
}

- (void)presentVideoAdFromViewController:(UIViewController *)viewController customerId:(NSString *)customerId placementId:(NSString *)placementId settings:(UnityAdsInstanceMediationSettings *)settings delegate:(id<MPUnityRouterDelegate>)delegate
{
    if(SYSTEM_VERSION_LESS_THAN(@"7.0"))
    {
        //unity crashes on ios less than 7, so won't try to show an ad on iOS6
        NSError *error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorUnknown userInfo:nil];
        [delegate unityAdsDidFailWithError:error];
	return;
    }
    if (!self.isAdPlaying && [self isAdAvailableForPlacementId:placementId]) {
        self.isAdPlaying = YES;
        if(![self.m_delegates containsObject:delegate])
        {
            [self.m_delegates addObject:delegate];
        }
        if (settings.userIdentifier.length > 0) {
            [self.m_playerMetaData setServerId:settings.userIdentifier];
            [self.m_playerMetaData commit];
        } else if (customerId.length > 0) {
            [self.m_playerMetaData setServerId:customerId];
            [self.m_playerMetaData commit];
        } 

        [UnityAds show:viewController placementId:placementId];
    } else {
        NSError *error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorUnknown userInfo:nil];
        [delegate unityAdsDidFailWithError:error];
    }
}

- (void)clearDelegate:(id<MPUnityRouterDelegate>)delegate
{
    if([self.m_delegates containsObject:delegate])
    {
        [self.m_delegates removeObject:delegate];
    }
}

#pragma mark - UnityAdsExtendedDelegate

- (void)unityAdsReady:(NSString *)placementId
{
    NSArray* loadDelegates = [[NSMutableArray alloc] initWithArray:self.m_delegates];
    for (id<MPUnityRouterDelegate> delegate in loadDelegates) {
        if(delegate != nil)
        {
            [delegate unityAdsReady:placementId];
        }
    }
}

- (void)unityAdsDidError:(UnityAdsError)error withMessage:(NSString *)message {
    NSArray* loadDelegates = [[NSMutableArray alloc] initWithArray:self.m_delegates];
    for (id<MPUnityRouterDelegate> delegate in loadDelegates) {
        if(delegate != nil)
        {
            [delegate unityAdsDidError:error withMessage:message];
        }
    }
}

- (void)unityAdsDidStart:(NSString *)placementId {
    NSArray* loadDelegates = [[NSMutableArray alloc] initWithArray:self.m_delegates];
    for (id<MPUnityRouterDelegate> delegate in loadDelegates) {
        if(delegate != nil)
        {
            [delegate unityAdsDidStart:placementId];
        }
    }
}

- (void)unityAdsDidFinish:(NSString *)placementId withFinishState:(UnityAdsFinishState)state {
    self.isAdPlaying = NO;
    NSArray* loadDelegates = [[NSMutableArray alloc] initWithArray:self.m_delegates];
    for (id<MPUnityRouterDelegate> delegate in loadDelegates) {
        if(delegate != nil)
        {
            [delegate unityAdsDidFinish:placementId withFinishState:state];
        }
    }
}
- (void)unityAdsDidClick:(NSString *)placementId {
    NSArray* loadDelegates = [[NSMutableArray alloc] initWithArray:self.m_delegates];
    for (id<MPUnityRouterDelegate> delegate in loadDelegates) {
        if(delegate != nil)
        {
            [delegate unityAdsDidClick:placementId];
        }
    }
}

@end
#endif //ADS_MANAGER_USE_UNITY_VIA_MOPUB
