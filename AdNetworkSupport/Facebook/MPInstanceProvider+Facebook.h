//
//  MPInstanceProvider+Facebook.h
//  MoPubSDK
//
//  Copyright (c) 2016 MoPub. All rights reserved.
//

#import "MPInstanceProvider.h"

@class MPFacebookRouter;

@interface MPFacebookInstanceProvider : NSObject

+ (MPFacebookRouter *)sharedMPFacebookRouterFrom:(MPInstanceProvider *)provider;

@end
