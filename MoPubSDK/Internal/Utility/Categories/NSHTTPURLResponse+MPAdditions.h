//
//  NSHTTPURLResponse+MPAdditions.h
//  MoPubSDK
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kMoPubHTTPHeaderContentType;

@interface MPAdditions_NSHTTPURLResponse : NSObject

+ (NSStringEncoding)stringEncodingFromContentType:(NSString *)contentType;// fromNSHTTPURLResponse:(NSHTTPURLResponse *)response;

@end
