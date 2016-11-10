//
//  UnityAdsInstanceMediationSettings.h
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#else
    #import "MPMediationSettingsProtocol.h"
#endif

/*
 * `FacebookInstanceMediationSettings` allows the application to provide per-instance properties
 * to configure aspects of FAN ads. See `MPMediationSettingsProtocol` to see how mediation settings
 * are used.
 */
@interface FacebookInstanceMediationSettings : NSObject <MPMediationSettingsProtocol>

/*
 * An NSString that's used as an identifier for a specific user, and is passed along to Unity
 * when the rewarded video ad is played.
 */
@property (nonatomic, copy) NSString *userIdentifier;


@property (nonatomic, copy) NSString *rewardCurrencyName;
@property (nonatomic) NSInteger rewardAmount;

@end
