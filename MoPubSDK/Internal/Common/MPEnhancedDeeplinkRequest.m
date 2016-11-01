//
//  MPEnhancedDeeplinkRequest.m
//  MoPub
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import "MPEnhancedDeeplinkRequest.h"
#import "NSURL+MPAdditions.h"

static NSString * const kRequiredHostname = @"navigate";
static NSString * const kPrimaryURLKey = @"primaryUrl";
static NSString * const kPrimaryTrackingURLKey = @"primaryTrackingUrl";
static NSString * const kFallbackURLKey = @"fallbackUrl";
static NSString * const kFallbackTrackingURLKey = @"fallbackTrackingUrl";

////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation MPEnhancedDeeplinkRequest

- (instancetype)initWithURL:(NSURL *)URL
{
    self = [super init];
    if (self) {
        if (![[[URL host] lowercaseString] isEqualToString:kRequiredHostname]) {
            return nil;
        }
        
        NSString *primaryURLString = [MPAdditions_NSURL mp_queryParameterForKey:kPrimaryURLKey forURL:URL];
        if (![primaryURLString length]) {
            return nil;
        }
        _primaryURL = [NSURL URLWithString:primaryURLString];
        _originalURL = [URL copy];

        NSMutableArray *primaryTrackingURLs = [NSMutableArray array];
        NSArray *primaryTrackingURLStrings = [MPAdditions_NSURL mp_queryParametersForKey:kPrimaryTrackingURLKey forURL:URL];
        for (NSString *URLString in primaryTrackingURLStrings) {
            [primaryTrackingURLs addObject:[NSURL URLWithString:URLString]];
        }
        _primaryTrackingURLs = [NSArray arrayWithArray:primaryTrackingURLs];

        NSString *fallbackURLString = [MPAdditions_NSURL mp_queryParameterForKey:kFallbackURLKey forURL:URL];
        _fallbackURL = [NSURL URLWithString:fallbackURLString];

        NSMutableArray *fallbackTrackingURLs = [NSMutableArray array];
        NSArray *fallbackTrackingURLStrings = [MPAdditions_NSURL mp_queryParametersForKey:kFallbackTrackingURLKey forURL:URL];
        for (NSString *URLString in fallbackTrackingURLStrings) {
            [fallbackTrackingURLs addObject:[NSURL URLWithString:URLString]];
        }
        _fallbackTrackingURLs = [NSArray arrayWithArray:fallbackTrackingURLs];
    }
    return self;
}

@end
