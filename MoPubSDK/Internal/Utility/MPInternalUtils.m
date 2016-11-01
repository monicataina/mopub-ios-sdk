//
//  MPInternalUtils.m
//  MoPubSDK
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "MPInternalUtils.h"

@implementation MPInternalUtils

+ (void)mp_safeSetObject:(id)obj forKey:(id<NSCopying>)key forDictionary:(NSMutableDictionary*)dictionary
{
    if (obj != nil) {
        [dictionary setObject:obj forKey:key];
    }
}

+ (void)mp_safeSetObject:(id)obj forKey:(id<NSCopying>)key withDefault:(id)defaultObj forDictionary:(NSMutableDictionary*)dictionary
{
    if (obj != nil) {
        [dictionary setObject:obj forKey:key];
    } else {
        [dictionary setObject:defaultObj forKey:key];
    }
}

@end
