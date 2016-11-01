//
//  NSURL+MPAdditions.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "NSURL+MPAdditions.h"

static NSString * const kTelephoneScheme = @"tel";
static NSString * const kTelephonePromptScheme = @"telprompt";

// Share Constants
static NSString * const kMoPubShareScheme = @"mopubshare";
static NSString * const kMoPubShareTweetHost = @"tweet";

// Commands Constants
static NSString * const kMoPubURLScheme = @"mopub";
static NSString * const kMoPubCloseHost = @"close";
static NSString * const kMoPubFinishLoadHost = @"finishLoad";
static NSString * const kMoPubFailLoadHost = @"failLoad";
static NSString * const kMoPubPrecacheCompleteHost = @"precacheComplete";
static NSString * const kMoPubRewardedVideoEndedHost = @"rewardedVideoEnded";

@implementation MPAdditions_NSURL

+ (NSString *)mp_queryParameterForKey:(NSString *)key forURL:(NSURL *)url
{
    NSArray *queryElements = [url.query componentsSeparatedByString:@"&"];
    for (NSString *element in queryElements) {
        NSArray *keyAndValue = [element componentsSeparatedByString:@"="];
        if (keyAndValue.count >= 2 &&
            [[keyAndValue objectAtIndex:0] isEqualToString:key] &&
            [[keyAndValue objectAtIndex:1] length] > 0) {
            return [[keyAndValue objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
    }
    return nil;
}

+ (NSArray *)mp_queryParametersForKey:(NSString *)key forURL:(NSURL *)url
{
    NSMutableArray *matchingParameters = [NSMutableArray array];
    NSArray *queryElements = [url.query componentsSeparatedByString:@"&"];
    for (NSString *element in queryElements) {
        NSArray *keyAndValue = [element componentsSeparatedByString:@"="];
        if (keyAndValue.count >= 2 &&
            [[keyAndValue objectAtIndex:0] isEqualToString:key] &&
            [[keyAndValue objectAtIndex:1] length] > 0) {
            [matchingParameters addObject:[[keyAndValue objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    return [NSArray arrayWithArray:matchingParameters];
}

+ (NSDictionary *)mp_queryAsDictionaryForURL:(NSURL *)url
{
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionary];
    NSArray *queryElements = [url.query componentsSeparatedByString:@"&"];
    for (NSString *element in queryElements) {
        NSArray *keyVal = [element componentsSeparatedByString:@"="];
        if (keyVal.count >= 2) {
            NSString *key = [keyVal objectAtIndex:0];
            NSString *value = [keyVal objectAtIndex:1];
            [queryDict setObject:[value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                          forKey:key];
        }
    }
    return queryDict;
}

+ (BOOL)mp_hasTelephoneSchemeForURL:(NSURL *)url
{
    return [[[url scheme] lowercaseString] isEqualToString:kTelephoneScheme];
}

+ (BOOL)mp_hasTelephonePromptSchemeForURL:(NSURL *)url
{
    return [[[url scheme] lowercaseString] isEqualToString:kTelephonePromptScheme];
}

+ (BOOL)mp_isSafeForLoadingWithoutUserActionForURL:(NSURL *)url
{
    return [[url scheme].lowercaseString isEqualToString:@"http"] ||
        [[url scheme].lowercaseString isEqualToString:@"https"] ||
        [[url scheme].lowercaseString isEqualToString:@"about"];
}

+ (BOOL)mp_isMoPubSchemeForURL:(NSURL *)url
{
    return [[url scheme] isEqualToString:kMoPubURLScheme];
}

+ (MPMoPubShareHostCommand)mp_MoPubShareHostCommandForURL:(NSURL *)url
{
    NSString *host = [url host];
    if (![self mp_isMoPubShareSchemeForURL:url]) {
        return MPMoPubShareHostCommandUnrecognized;
    } else if ([host isEqualToString:kMoPubShareTweetHost]) {
        return MPMoPubShareHostCommandTweet;
    } else {
        return MPMoPubShareHostCommandUnrecognized;
    }
}

+ (MPMoPubHostCommand)mp_mopubHostCommandForURL:(NSURL *)url
{
    NSString *host = [url host];
    if (![self mp_isMoPubSchemeForURL:url]) {
        return MPMoPubHostCommandUnrecognized;
    } else if ([host isEqualToString:kMoPubCloseHost]) {
        return MPMoPubHostCommandClose;
    } else if ([host isEqualToString:kMoPubFinishLoadHost]) {
        return MPMoPubHostCommandFinishLoad;
    } else if ([host isEqualToString:kMoPubFailLoadHost]) {
        return MPMoPubHostCommandFailLoad;
    } else if ([host isEqualToString:kMoPubPrecacheCompleteHost]) {
        return MPMoPubHostCommandPrecacheComplete;
    } else if ([host isEqualToString:kMoPubRewardedVideoEndedHost]) {
        return MPMoPubHostCommandRewardedVideoEnded;
    } else {
        return MPMoPubHostCommandUnrecognized;
    }
}

+ (BOOL)mp_isMoPubShareSchemeForURL:(NSURL *)url
{
    return [[url scheme] isEqualToString:kMoPubShareScheme];
}

@end
