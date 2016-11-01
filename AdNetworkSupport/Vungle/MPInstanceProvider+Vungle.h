//
//  MPInstanceProvider+Vungle.h
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import "MPInstanceProvider.h"

@class MPVungleRouter;

//use a MoPub's class instead of a category so that I can force to initialize it even without -ObjC flag
@interface MPVungleInstanceProvider : NSObject

+ (MPVungleRouter *)sharedMPVungleRouterFrom:(MPInstanceProvider *)provider;

@end
