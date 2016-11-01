//
//  NSJSONSerialization+MPAdditions.h
//  MoPub
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MPAdditions_NSJSONSerialization : NSJSONSerialization

+ (id)mp_JSONObjectWithData:(NSData *)data options:(NSJSONReadingOptions)opt clearNullObjects:(BOOL)clearNulls error:(NSError **)error;

+ (void)removeNullObjectsFromDictionary:(NSMutableDictionary *)dictionary;
+ (void)removeNullObjectsFromArray:(NSMutableArray *)array;


@end
