//
//  MPInstanceProvider+Facebook.m
//  MoPubSDK
//
//  Copyright (c) 2016 MoPub. All rights reserved.
//

#import "MPInstanceProvider+Facebook.h"
#import "MPFacebookRouter.h"

@implementation MPFacebookInstanceProvider

+ (MPFacebookRouter *)sharedMPFacebookRouterFrom:(MPInstanceProvider *)provider
{
    return [provider singletonForClass:[MPFacebookRouter class]
                              provider:^id{
                                  return [[MPFacebookRouter alloc] init];
                              }];
}

@end
