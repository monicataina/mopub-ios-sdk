//
//  MPInstanceProvider+Vungle.m
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import "MPInstanceProvider+Vungle.h"
#import "MPVungleRouter.h"

@implementation MPVungleInstanceProvider

+ (MPVungleRouter *)sharedMPVungleRouterFrom:(MPInstanceProvider *)provider
{
    return [provider singletonForClass:[MPVungleRouter class]
                          provider:^id{
                              return [[MPVungleRouter alloc] init];
                          }];
}

@end
