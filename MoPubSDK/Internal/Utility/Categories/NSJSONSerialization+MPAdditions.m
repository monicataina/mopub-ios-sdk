//
//  NSJSONSerialization+MPAdditions.m
//  MoPub
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "NSJSONSerialization+MPAdditions.h"

@implementation MPAdditions_NSJSONSerialization

+ (id)mp_JSONObjectWithData:(NSData *)data options:(NSJSONReadingOptions)opt clearNullObjects:(BOOL)clearNulls error:(NSError **)error
{
    if (clearNulls) {
        opt |= NSJSONReadingMutableContainers;
    }

    id JSONObject = [NSJSONSerialization JSONObjectWithData:data options:opt error:error];

    if (error || !clearNulls) {
        return JSONObject;
    }
    
    if([JSONObject isKindOfClass:[NSMutableArray class]])
    {
        [self removeNullObjectsFromArray:JSONObject];
    }
    else if([JSONObject isKindOfClass:[NSMutableDictionary class]])
    {
        [self removeNullObjectsFromDictionary:JSONObject];
    }
    return JSONObject;
}
+(void)load
{
    
}

+ (void)removeNullObjectsFromDictionary:(NSMutableDictionary *)dictionary
{
    // First, filter out directly stored nulls
    NSMutableArray *nullKeys = [NSMutableArray array];
    NSMutableArray *arrayKeys = [NSMutableArray array];
    NSMutableArray *dictionaryKeys = [NSMutableArray array];
    
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isEqual:[NSNull null]]) {
            [nullKeys addObject:key];
        } else if ([obj isKindOfClass:[NSDictionary  class]]) {
            [dictionaryKeys addObject:key];
        } else if ([obj isKindOfClass:[NSArray class]]) {
            [arrayKeys addObject:key];
        }
    }];
    
    // Remove all the nulls
    [dictionary removeObjectsForKeys:nullKeys];
    
    // Cascade down the dictionaries
    for (id dictionaryKey in dictionaryKeys) {
        [self removeNullObjectsFromDictionary:[dictionary objectForKey:dictionaryKey]];
    }
    
    // Recursively remove nulls from arrays
    for (id arrayKey in arrayKeys) {
        [self removeNullObjectsFromArray:[dictionary objectForKey:arrayKey]];
    }

}

+ (void)removeNullObjectsFromArray:(NSMutableArray *)array
{
    [array removeObjectIdenticalTo:[NSNull null]];
    
    for (id object in array) {
        if([object isKindOfClass:[NSMutableArray class]])
        {
           [self removeNullObjectsFromArray:object];
        }
        else if([object isKindOfClass:[NSMutableDictionary class]])
        {
            [self removeNullObjectsFromDictionary:object];
        }
    }
}

@end
