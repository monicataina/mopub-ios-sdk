//
//  MPLogProvider.m
//  MoPub
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "MPLogProvider.h"

@interface MPLogProvider ()

@property (nonatomic, strong) NSMutableArray *loggers;
/*
 * A boolean that's used to enable/disable the verbose logging. default is YES (enabled)
 */
@property (nonatomic) BOOL m_enableDebugging;

@end

@interface MPSystemLogger : NSObject <MPLogger>
@end

@implementation MPLogProvider

#pragma mark - Singleton instance

+ (MPLogProvider *)sharedLogProvider
{
    static dispatch_once_t once;
    static MPLogProvider *sharedLogProvider;
    dispatch_once(&once, ^{
        sharedLogProvider = [[self alloc] init];
    });

    return sharedLogProvider;
}

#pragma mark - Object Lifecycle

- (id)init
{
    self = [super init];
    if (self) {
        _loggers = [NSMutableArray array];
        _m_enableDebugging = YES;
        [self addLogger:[[MPSystemLogger alloc] init]];
    }
    return self;
}

#pragma mark - Set logging mode
- (void)setDebugMode:(BOOL)enableDebugging
{
    self.m_enableDebugging = enableDebugging;
}

#pragma mark - Loggers

- (void)addLogger:(id<MPLogger>)logger
{
    [self.loggers addObject:logger];
}

- (void)removeLogger:(id<MPLogger>)logger
{
    [self.loggers removeObject:logger];
}

#pragma mark - Logging

- (void)logMessage:(NSString *)message atLogLevel:(MPLogLevel)logLevel
{
    if(self.m_enableDebugging == YES)
    {
        [self.loggers enumerateObjectsUsingBlock:^(id<MPLogger> logger, NSUInteger idx, BOOL *stop) {
            if ([logger logLevel] <= logLevel) {
                [logger logMessage:message];
            }
        }];
    }
}

@end

@implementation MPSystemLogger

- (void)logMessage:(NSString *)message
{
    NSLog(@"%@", message);
}

- (MPLogLevel)logLevel
{
    return MPLogGetLevel();
}

@end
