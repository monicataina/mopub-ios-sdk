//
//  AdColonyInterstitialCustomEvent.h
//  MoPubSDK
//
//  Copyright (c) 2016 MoPub. All rights reserved.
//

#include "AdsManager_internal_config.h"
#ifdef ADS_MANAGER_USE_ADCOLONY_VIA_MOPUB

#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#else
    #import "MPInterstitialCustomEvent.h"
#endif

/*
 * Please reference the Supported Mediation Partner page at http://bit.ly/2mqsuFH for the
 * latest version and ad format certifications.
 */
@interface AdColonyInterstitialCustomEvent : MPInterstitialCustomEvent

@end
#endif //ADS_MANAGER_USE_ADCOLONY_VIA_MOPUB
