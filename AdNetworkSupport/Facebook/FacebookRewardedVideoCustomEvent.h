//
//  FacebookRewardedVideoCustomEvent.h
//  MoPubSDK
//
//  Copyright (c) 2016 MoPub. All rights reserved.
//

#include "AdsManager_internal_config.h"
#ifdef ADS_MANAGER_USE_FACEBOOK_VIA_MOPUB

#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#else
    #import "MPRewardedVideoCustomEvent.h"
#endif

/*
 * UnCertified with version 4.15.1-rewarded of the Facebook SDK.
 */

@interface FacebookRewardedVideoCustomEvent : MPRewardedVideoCustomEvent

+(void)setCustomEventIdentifier:(int)identifier;

@end
#endif //ADS_MANAGER_USE_FACEBOOK_VIA_MOPUB
