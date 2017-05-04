//
//  MPVungleRouter.h
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#include "AdsManager_internal_config.h"
#ifdef ADS_MANAGER_USE_VUNGLE_VIA_MOPUB

#import <Foundation/Foundation.h>
#import <VungleSDK/VungleSDK.h>

@protocol MPVungleRouterDelegate;
@class VungleInstanceMediationSettings;

@interface MPVungleRouter : NSObject <VungleSDKDelegate>

@property (nonatomic, strong) id<MPVungleRouterDelegate> m_showDelegate;
@property (nonatomic, strong) NSMutableArray* m_loadDelegates;

+ (void)setAppId:(NSString *)appId;

+ (MPVungleRouter *)sharedRouter;

- (void)requestInterstitialAdWithCustomEventInfo:(NSDictionary *)info delegate:(id<MPVungleRouterDelegate>)delegate;
- (void)requestRewardedVideoAdWithCustomEventInfo:(NSDictionary *)info delegate:(id<MPVungleRouterDelegate>)delegate;
- (BOOL)isAdAvailable;
- (void)presentInterstitialAdFromViewController:(UIViewController *)viewController withDelegate:(id<MPVungleRouterDelegate>)delegate;
- (void)presentRewardedVideoAdFromViewController:(UIViewController *)viewController customerId:(NSString *)customerId settings:(VungleInstanceMediationSettings *)settings delegate:(id<MPVungleRouterDelegate>)delegate;
- (void)clearDelegate:(id<MPVungleRouterDelegate>)delegate;

- (void) vungleAdDidFailToLoad;
- (void) vungleAdDidLoad;
@end

@protocol MPVungleRouterDelegate <NSObject>

- (void)vungleAdDidLoad;
- (void)vungleAdWillAppear;
- (void)vungleAdWillDisappear;
- (void)vungleAdWasTapped;
- (void)vungleAdDidFailToPlay:(NSError *)error;
- (void)vungleAdDidFailToLoad:(NSError *)error;

@optional

- (void)vungleAdShouldRewardUser;

@end
#endif //ADS_MANAGER_USE_VUNGLE_VIA_MOPUB
