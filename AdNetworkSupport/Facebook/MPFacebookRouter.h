//
//  MPFacebookRouter.h
//  MoPubSDK
//
//  Copyright (c) 2016 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <FBAudienceNetwork/FBAudienceNetwork.h>

@protocol MPFacebookRouterDelegate;
@class FacebookInstanceMediationSettings;

@interface MPFacebookRouter : NSObject <FBRewardedVideoAdDelegate>

@property (nonatomic, strong) id<MPFacebookRouterDelegate> delegate;

+ (MPFacebookRouter *)sharedRouter;

- (void)requestRewardedVideoAdWithZoneId:(NSString *)zoneId customerId:(NSString *)customerId settings:(FacebookInstanceMediationSettings *)settings delegate:(id<MPFacebookRouterDelegate>)delegate;
- (BOOL)isAdAvailableForZoneId:(NSString *)zoneId;
- (void)presentRewardedVideoAdFromViewController:(UIViewController *)viewController customerId:(NSString *)customerId zoneId:(NSString *)zoneId settings:(FacebookInstanceMediationSettings *)settings delegate:(id<MPFacebookRouterDelegate>)delegate;
- (void)clearDelegate:(id<MPFacebookRouterDelegate>)delegate;

@end

@protocol MPFacebookRouterDelegate <NSObject>

- (void)facebookVideoCompleted:(NSString *)rewardItemKey rewardAmount:(NSNumber *)rewardAmount;
- (void)facebookVideoAdServerSuccess:(NSString *)rewardItemKey rewardAmount:(NSNumber *)rewardAmount;
- (void)facebookVideoAdServerFailed:(NSString *)rewardItemKey rewardAmount:(NSNumber *)rewardAmount;
- (void)facebookDidClick;
- (void)facebookWillShow;
- (void)facebookDidShow;
- (void)facebookWillHide;
- (void)facebookDidHide;
//- (void)facebookWillLeaveApplication;
- (void)facebookFetchCompleted;
- (void)facebookDidFailWithError:(NSError *)error;

@end
