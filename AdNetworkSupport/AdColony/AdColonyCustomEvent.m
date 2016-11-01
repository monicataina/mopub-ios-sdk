//
//  AdColonyCustomEvent.m
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AdColonyCustomEvent.h"
#import "AdColonyGlobalMediationSettings.h"
#import "MPAdColonyRouter.h"
#import "MoPub.h"
#import "MPRewardedVideo.h"

static AdColonyAppOptions *s_AdColonyAppOptions;
static const NSTimeInterval AdColonyInitTimeout = 2.0;

@implementation AdColonyCustomEvent

+ (BOOL)initializeAdColonyCustomEventWithAppId:(NSString *)appId allZoneIds:(NSArray *)allZoneIds customerId:(NSString *)customerId forZoneId:(NSString *)zoneId
{
    __block BOOL configureIsCalled = NO;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        
        configureIsCalled = YES;
        
        AdColonyGlobalMediationSettings *settings = [[MoPub sharedInstance] globalMediationSettingsForClass:[AdColonyGlobalMediationSettings class]];
        
        s_AdColonyAppOptions = [[AdColonyAppOptions alloc] init];
        
        // Set the AdColony customID to enable server-mode for AdColony V4VC if the application has provided a customID.
        if (customerId.length > 0) {
            s_AdColonyAppOptions.userID = customerId;
        } else if (settings && [settings.customId length]) {
            s_AdColonyAppOptions.userID = settings.customId;
        }
        
        if([[MoPub sharedInstance] m_enableDebugging] == YES)
        {
            s_AdColonyAppOptions.disableLogging = NO;
        }
        else
        {
            s_AdColonyAppOptions.disableLogging = YES;
        }
        
        [AdColony configureWithAppID:appId
                             zoneIDs:allZoneIds
                             options:s_AdColonyAppOptions
                          completion:^(NSArray<AdColonyZone*>* zones) {
                              [[MPAdColonyRouter sharedRouter] onConfigured];
                          }
         ];
        
        [MPAdColonyRouter sharedRouter].isWaitingForInit = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(AdColonyInitTimeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if ([MPAdColonyRouter sharedRouter].isWaitingForInit) {
                    [MPAdColonyRouter sharedRouter].isWaitingForInit = NO;
                    NSError *error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorTimeout userInfo:nil];
                    [[MPAdColonyRouter sharedRouter] onAdDidFailToLoad:zoneId withError:error];
                }
        });
    });
    return configureIsCalled;
}

@end
