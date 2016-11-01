//
//  MPUnityRouter.m
//  MoPubSDK
//
//  Copyright (c) 2016 MoPub. All rights reserved.
//

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
    return [MPUnityInstanceProvider sharedMPUnityRouterFrom:[MPInstanceProvider sharedProvider]];
}

- (MPUnityRouter *)init
{
    self = [super init];
    self.m_playerMetaData = [[UADSPlayerMetaData alloc] init];
    
    return self;
}

- (void)requestVideoAdWithGameId:(NSString *)gameId placementId:(NSString *)placementId delegate:(id<MPUnityRouterDelegate>)delegate;
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
            self.delegate = delegate;

            static dispatch_once_t unityInitToken;
            dispatch_once(&unityInitToken, ^{
                UADSMediationMetaData *mediationMetaData = [[UADSMediationMetaData alloc] init];
                [mediationMetaData setName:@"MoPub"];
                [mediationMetaData setVersion:[[MoPub sharedInstance] version]];
                [mediationMetaData commit];
                
                [UnityAds setDebugMode:[[MoPub sharedInstance] m_enableDebugging]];
                
                [UnityAds initialize:gameId delegate:self];
            });

            // Need to check immediately as an ad may be cached.
            if ([self isAdAvailableForPlacementId:placementId]) {
                [self.delegate unityAdsReady:placementId];
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
    }
    else
    {
        if (!self.isAdPlaying && [self isAdAvailableForPlacementId:placementId]) {
            self.isAdPlaying = YES;

            self.delegate = delegate;
            
            if (customerId.length >0) {
                [self.m_playerMetaData setServerId:customerId];
                [self.m_playerMetaData commit];
            } else if (settings.userIdentifier.length > 0) {
                [self.m_playerMetaData setServerId:settings.userIdentifier];
                [self.m_playerMetaData commit];
            }

            [UnityAds show:viewController placementId:placementId];
        } else {
            NSError *error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorUnknown userInfo:nil];
            [delegate unityAdsDidFailWithError:error];
        }
    }
}

- (void)clearDelegate:(id<MPUnityRouterDelegate>)delegate
{
    if (self.delegate == delegate)
    {
        [self setDelegate:nil];
    }
}

#pragma mark - UnityAdsDelegate

- (void)unityAdsReady:(NSString *)placementId
{
    [self.delegate unityAdsReady:placementId];
}

- (void)unityAdsDidError:(UnityAdsError)error withMessage:(NSString *)message {
    [self.delegate unityAdsDidError:error withMessage:message];
}

- (void)unityAdsDidStart:(NSString *)placementId {
    [self.delegate unityAdsDidStart:placementId];
}

- (void)unityAdsDidFinish:(NSString *)placementId withFinishState:(UnityAdsFinishState)state {
    [self.delegate unityAdsDidFinish:placementId withFinishState:state];
    self.isAdPlaying = NO;
}

@end
