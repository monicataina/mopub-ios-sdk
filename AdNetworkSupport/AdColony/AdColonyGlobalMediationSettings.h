//
//  AdColonyGlobalMediationSettings.h
//  MoPubSDK
//
//  Copyright (c) 2016 MoPub. All rights reserved.
//

#include "AdsManager_internal_config.h"
#ifdef ADS_MANAGER_USE_ADCOLONY_VIA_MOPUB

#import <Foundation/Foundation.h>

#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#else
    #import "MPMediationSettingsProtocol.h"
#endif

#import <AdColony/AdColony.h>

/*
 * `AdColonyGlobalMediationSettings` allows the application to provide constant global properties
 * to configure aspects of AdColony. See `MPMediationSettingsProtocol` to see how mediation settings
 * are used. This only apply to AdColonyRewardedVideoCustomEvents.
 */
@interface AdColonyGlobalMediationSettings : NSObject <MPMediationSettingsProtocol>

/*
 * Sets the customId to utilize server-side mode for AdColony V4VC.
 */
@property (nonatomic, copy) NSString *customId;

@end
#endif //ADS_MANAGER_USE_ADCOLONY_VIA_MOPUB
