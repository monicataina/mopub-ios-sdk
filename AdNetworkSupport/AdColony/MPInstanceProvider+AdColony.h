//
//  MPInstanceProvider+AdColony.h
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import "MPInstanceProvider.h"

/*
 * An extension of MPInstanceProvider to create the MPAdColonyRouter.
 */
@class MPAdColonyRouter;

//use a MoPub's class instead of a category so that I can force to initialize it even without -ObjC flag
@interface MPAdColonyInstanceProvider : NSObject 

+ (MPAdColonyRouter *)sharedMPAdColonyRouterFrom:(MPInstanceProvider *)provider;

@end
