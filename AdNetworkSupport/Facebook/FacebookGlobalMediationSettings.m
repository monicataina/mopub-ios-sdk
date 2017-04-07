//
//  UnityAdsInstanceMediationSettings.m
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import "FacebookGlobalMediationSettings.h"

#ifdef ADS_MANAGER_USE_FACEBOOK_VIA_MOPUB
#import "MPRewardedVideoReward.h"

@implementation FacebookGlobalMediationSettings

- (id)init {
    if (self = [super init]) {
        
        _useTestDevice = NO;
    }
    return self;
}

@end
#endif //ADS_MANAGER_USE_FACEBOOK_VIA_MOPUB
