//
//  UnityAdsInstanceMediationSettings.h
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#include "AdsManager_internal_config.h"
#ifdef ADS_MANAGER_USE_FACEBOOK_VIA_MOPUB

#import <Foundation/Foundation.h>

#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#else
    #import "MPMediationSettingsProtocol.h"
#endif

/*
 * `FacebookGlobalMediationSettings` allows the application to provide constant global properties
 * to configure aspects of FAN ads. See `MPMediationSettingsProtocol` to see how mediation settings
 * are used.
 */
@interface FacebookGlobalMediationSettings : NSObject <MPMediationSettingsProtocol>

//by default is NO. If it set to YES, you won't get FAN ads.
@property (nonatomic) BOOL isCOPPA;

//by default is NO. If it set to YES, you will get FAN test ads
@property (nonatomic) BOOL useTestDevice;

@end
#endif //ADS_MANAGER_USE_FACEBOOK_VIA_MOPUB
