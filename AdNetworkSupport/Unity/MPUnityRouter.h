//
//  MPUnityRouter.h
//  MoPubSDK
//
//  Copyright (c) 2016 MoPub. All rights reserved.
//

#include "AdsManager_internal_config.h"
#ifdef ADS_MANAGER_USE_UNITY_VIA_MOPUB

#import <Foundation/Foundation.h>
#import <UnityAds/UnityAds.h>
#import <UnityAds/UnityAdsExtended.h>

@protocol MPUnityRouterDelegate;
@class UnityAdsInstanceMediationSettings;

@interface MPUnityRouter : NSObject <UnityAdsExtendedDelegate>

@property (nonatomic, strong) NSMutableArray* m_delegates;

+ (MPUnityRouter *)sharedRouter;

- (void)requestVideoAdWithGameId:(NSString *)gameId placementId:(NSString *)placementId settings:(UnityAdsInstanceMediationSettings *)settings delegate:(id<MPUnityRouterDelegate>)delegate;
- (BOOL)isAdAvailableForPlacementId:(NSString *)placementId;
- (void)presentVideoAdFromViewController:(UIViewController *)viewController customerId:(NSString *)customerId placementId:(NSString *)placementId settings:(UnityAdsInstanceMediationSettings *)settings delegate:(id<MPUnityRouterDelegate>)delegate;
- (void)clearDelegate:(id<MPUnityRouterDelegate>)delegate;

@end

@protocol MPUnityRouterDelegate <NSObject>

- (void)unityAdsReady:(NSString *)placementId;
- (void)unityAdsDidError:(UnityAdsError)error withMessage:(NSString *)message;
- (void)unityAdsDidStart:(NSString *)placementId;
- (void)unityAdsDidFinish:(NSString *)placementId withFinishState:(UnityAdsFinishState)state;
- (void)unityAdsDidClick:(NSString *)placementId;

- (void)unityAdsDidFailWithError:(NSError *)error;

@end
#endif //ADS_MANAGER_USE_UNITY_VIA_MOPUB
