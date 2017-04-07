//
//  UnityAdsInstanceMediationSettings.m
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import "FacebookInstanceMediationSettings.h"

#ifdef ADS_MANAGER_USE_FACEBOOK_VIA_MOPUB
#import "MPRewardedVideoReward.h"

@implementation FacebookInstanceMediationSettings

- (id)init {
    if (self = [super init]) {
        _rewardCurrencyName = kMPRewardedVideoRewardCurrencyTypeUnspecified;
        _rewardAmount = kMPRewardedVideoRewardCurrencyAmountUnspecified;
    }
    return self;
}

@end
#endif //ADS_MANAGER_USE_FACEBOOK_VIA_MOPUB
