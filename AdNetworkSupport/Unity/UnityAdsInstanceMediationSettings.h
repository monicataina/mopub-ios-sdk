//
//  UnityAdsInstanceMediationSettings.h
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#include "AdsManager_internal_config.h"
#ifdef ADS_MANAGER_USE_UNITY_VIA_MOPUB

#import <Foundation/Foundation.h>

#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#else
    #import "MPMediationSettingsProtocol.h"
#endif

/*
 * `UnityInstanceMediationSettings` allows the application to provide per-instance properties
 * to configure aspects of Unity ads. See `MPMediationSettingsProtocol` to see how mediation settings
 * are used.
 */
@interface UnityAdsInstanceMediationSettings : NSObject <MPMediationSettingsProtocol>

/*
 * An NSString that's used as an identifier for a specific user, and is passed along to Unity
 * when the rewarded video ad is played.
 */
@property (nonatomic, copy) NSString *userIdentifier;

//by default is NO. If it set to YES, you will get Unity test ads
@property (nonatomic) BOOL useTestDevice;

@end
#endif //ADS_MANAGER_USE_UNITY_VIA_MOPUB
