//
//  MPInstanceProvider+AdColony.m
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import "MPInstanceProvider+AdColony.h"
#import "MPAdColonyRouter.h"

@implementation MPAdColonyInstanceProvider

+ (MPAdColonyRouter *)sharedMPAdColonyRouterFrom:(MPInstanceProvider *)provider
{
    return [provider singletonForClass:[MPAdColonyRouter class]
                              provider:^id{
                                  return [[MPAdColonyRouter alloc] init];
                              }];
}

@end
