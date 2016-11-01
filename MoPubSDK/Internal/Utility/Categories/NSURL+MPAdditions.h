//
//  NSURL+MPAdditions.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    MPMoPubHostCommandUnrecognized,
    MPMoPubHostCommandClose,
    MPMoPubHostCommandFinishLoad,
    MPMoPubHostCommandFailLoad,
    MPMoPubHostCommandPrecacheComplete,
    MPMoPubHostCommandRewardedVideoEnded
} MPMoPubHostCommand;

typedef enum {
    MPMoPubShareHostCommandTweet,
    MPMoPubShareHostCommandUnrecognized
} MPMoPubShareHostCommand;

@interface MPAdditions_NSURL : NSObject

+ (NSString *)mp_queryParameterForKey:(NSString *)key forURL:(NSURL *)url;
+ (NSArray *)mp_queryParametersForKey:(NSString *)key forURL:(NSURL *)url;
+ (NSDictionary *)mp_queryAsDictionaryForURL:(NSURL *)url;
+ (BOOL)mp_hasTelephoneSchemeForURL:(NSURL *)url;
+ (BOOL)mp_hasTelephonePromptSchemeForURL:(NSURL *)url;
+ (BOOL)mp_isSafeForLoadingWithoutUserActionForURL:(NSURL *)url;
+ (BOOL)mp_isMoPubSchemeForURL:(NSURL *)url;
+ (MPMoPubHostCommand)mp_mopubHostCommandForURL:(NSURL *)url;
+ (BOOL)mp_isMoPubShareSchemeForURL:(NSURL *)url;
+ (MPMoPubShareHostCommand)mp_MoPubShareHostCommandForURL:(NSURL *)url;

@end
