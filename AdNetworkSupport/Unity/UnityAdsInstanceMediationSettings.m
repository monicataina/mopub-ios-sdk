//
//  UnityAdsInstanceMediationSettings.m
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import "UnityAdsInstanceMediationSettings.h"

#ifdef ADS_MANAGER_USE_UNITY_VIA_MOPUB

@implementation UnityAdsInstanceMediationSettings

- (id)init {
    if (self = [super init]) {
        _useTestDevice = NO;
    }
    return self;
}

@end
#endif //ADS_MANAGER_USE_UNITY_VIA_MOPUB
