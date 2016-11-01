//
//  MPInstanceProvider+Unity.h
//  MoPubSDK
//
//  Copyright (c) 2016 MoPub. All rights reserved.
//

#import "MPInstanceProvider.h"

@class MPUnityRouter;

//use a MoPub's class instead of a category so that I can force to initialize it even without -ObjC flag
@interface MPUnityInstanceProvider : NSObject

+ (MPUnityRouter *)sharedMPUnityRouterFrom:(MPInstanceProvider *)provider;

@end
