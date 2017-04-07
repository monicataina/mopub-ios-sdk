//
//  MPInstanceProvider+Unity.m
//  MoPubSDK
//
//  Copyright (c) 2016 MoPub. All rights reserved.
//

#import "MPInstanceProvider+Unity.h"

#ifdef ADS_MANAGER_USE_UNITY_VIA_MOPUB

#import "MPUnityRouter.h"

@implementation MPInstanceProvider (Unity)

- (MPUnityRouter *)sharedMPUnityRouter
{
    return [self singletonForClass:[MPUnityRouter class]
                          provider:^id{
                              return [[MPUnityRouter alloc] init];
                          }];
}

@end
#endif //ADS_MANAGER_USE_UNITY_VIA_MOPUB
