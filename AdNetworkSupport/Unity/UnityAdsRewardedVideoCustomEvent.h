//
//  UnityAdsRewardedVideoCustomEvent.h
//  MoPubSDK
//
//  Copyright (c) 2016 MoPub. All rights reserved.
//

#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#else
    #import "MPRewardedVideoCustomEvent.h"
#endif

/*
 * unCertified with version 2.0.5 of the Unity SDK.
 */

@interface UnityAdsRewardedVideoCustomEvent : MPRewardedVideoCustomEvent

+(void)setCustomEventIdentifier:(int)identifier;

@end
