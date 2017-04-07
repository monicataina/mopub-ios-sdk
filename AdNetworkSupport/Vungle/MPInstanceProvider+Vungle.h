//
//  MPInstanceProvider+Vungle.h
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#include "AdsManager_internal_config.h"
#ifdef ADS_MANAGER_USE_VUNGLE_VIA_MOPUB

#import "MPInstanceProvider.h"

@class MPVungleRouter;

@interface MPInstanceProvider (Vungle)

- (MPVungleRouter *)sharedMPVungleRouter;

@end
#endif //ADS_MANAGER_USE_VUNGLE_VIA_MOPUB
