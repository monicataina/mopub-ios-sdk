//
//  MPInstanceProvider+Unity.h
//  MoPubSDK
//
//  Copyright (c) 2016 MoPub. All rights reserved.
//

#include "AdsManager_internal_config.h"
#ifdef ADS_MANAGER_USE_UNITY_VIA_MOPUB

#import "MPInstanceProvider.h"

@class MPUnityRouter;

@interface MPInstanceProvider (Unity)

- (MPUnityRouter *)sharedMPUnityRouter;

@end
#endif //ADS_MANAGER_USE_UNITY_VIA_MOPUB
