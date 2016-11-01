//
//  MPInstanceProvider+Unity.m
//  MoPubSDK
//
//  Copyright (c) 2016 MoPub. All rights reserved.
//

#import "MPInstanceProvider+Unity.h"
#import "MPUnityRouter.h"

@implementation MPUnityInstanceProvider

+ (MPUnityRouter *)sharedMPUnityRouterFrom:(MPInstanceProvider *)provider
{
    return [provider singletonForClass:[MPUnityRouter class]
                          provider:^id{
                              return [[MPUnityRouter alloc] init];
                          }];
}

@end
