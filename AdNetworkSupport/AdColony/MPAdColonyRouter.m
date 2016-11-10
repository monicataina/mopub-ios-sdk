//
//  MPAdColonyRouter.m
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//


#import "MPAdColonyRouter.h"
#import "MPLogging.h"
#import "MPInstanceProvider+AdColony.h"
#import "MPRewardedVideoReward.h"

@interface MPAdColonyRouter ()

@property (nonatomic, strong) NSMutableDictionary *events;
@property (nonatomic, strong) NSMutableArray *globalCustomEvents;

@property (nonatomic, strong) NSMutableDictionary *zones;
@end

@implementation MPAdColonyRouter

+ (MPAdColonyRouter *)sharedRouter
{
    return [MPAdColonyInstanceProvider sharedMPAdColonyRouterFrom:[MPInstanceProvider sharedProvider]];
}

- (id)init
{
    self = [super init];
    if(self != nil)
    {
        _events = [NSMutableDictionary dictionary];
        _globalCustomEvents = [NSMutableArray array];
        _zones = [NSMutableDictionary dictionary];
    }
    return self;
}
- (void) requestVideoAdWithZoneId:(NSString*)zoneId showPrePopup:(BOOL)showPrePopup showPostPopup:(BOOL)showPostPopup
{
    AdColonyInterstitial* ad = [self.zones objectForKey:zoneId];
    
    if(ad != nil && ad.expired == NO)
    {
        //ad is already loaded and it's available
        [self onAdLoaded:zoneId];
    }
    else
    {
        AdColonyAdOptions* adOptions = [[AdColonyAdOptions alloc] init];
        adOptions.showPrePopup = showPrePopup;
        adOptions.showPostPopup = showPostPopup;
        
        [AdColony requestInterstitialInZone:zoneId
                                    options:adOptions
                                    success:^(AdColonyInterstitial* ad) {
                                        //AdColony ad loaded
                                        ad.open = ^{
                                            //AdColony ad opened
                                            [self onAdStartedInZone:zoneId];
                                        };
                                        ad.close = ^{
                                            //AdColony ad closed
                                            [self.zones removeObjectForKey:zoneId];
                                            
                                            //on finished
                                            [self onAdAttemptFinished:YES inZone:zoneId];
                                        };
                                        ad.expire = ^{
                                            //AdColony ad expired
                                            [self onAdExpired:zoneId];
                                        };
                                        [self.zones setObject:ad forKey:zoneId];
                                        [self onAdLoaded:zoneId];
                                    }
                                    failure:^(AdColonyAdRequestError* error) {
                                        [self.zones removeObjectForKey:zoneId];
                                        [self onAdDidFailToLoad:zoneId withError:error];
                                    }
         ];
    }
}

- (BOOL) hasAdAvailableForZone:(NSString*)zoneId
{
    AdColonyZone* zone = [AdColony zoneForID:zoneId];
    if(zone != nil && zone.enabled)
    {
        AdColonyInterstitial* ad = [self.zones objectForKey:zoneId];
        if(ad != nil && ad.expired == NO)
        {
            return YES;
        }
    }
    return NO;
}

- (void) showAdForZone:(NSString*)zoneId withViewController:(UIViewController *)viewController
{
    AdColonyInterstitial* ad = [self.zones objectForKey:zoneId];
    [ad showWithPresentingViewController:viewController];
}

- (void)setCustomEvent:(id<MPAdColonyRouterDelegate>)customEvent forZoneId:(NSString *)zoneId
{
    [self.events setObject:customEvent forKey:zoneId];
}

- (void)removeCustomEvent:(id<MPAdColonyRouterDelegate>)customEvent forZoneId:(NSString *)zoneId
{
    if([[self.events objectForKey:zoneId] isEqual:customEvent])
    {
        [self.events removeObjectForKey:zoneId];
    }
}

- (void)addGlobalCustomEvent:(id<MPAdColonyRouterDelegate>)customEvent
{
    if([self.globalCustomEvents containsObject:customEvent] == NO)
    {
        [self.globalCustomEvents addObject:customEvent];
    }
}

- (void)removeGlobalCustomEvent:(id<MPAdColonyRouterDelegate>)customEvent
{
    if([self.globalCustomEvents containsObject:customEvent] == YES)
    {
        [self.globalCustomEvents removeObject:customEvent];
    }
}

- (void)onConfigured
{
    self.isWaitingForInit = NO;
    for(id<MPAdColonyRouterDelegate> event in [[MPAdColonyRouter sharedRouter] globalCustomEvents])
    {
        if ([event respondsToSelector:@selector(configured)]) {
            [event configured];
        }
    }
}

#pragma mark - AdColonyDelegate

- (void)onAdStartedInZone:(NSString *)zoneID;
{
    id<MPAdColonyRouterDelegate> event = [self.events objectForKey:zoneID];
    [event onAdStartedInZone:zoneID];
}
- (void)onAdAttemptFinished:(BOOL)shown inZone:(NSString *)zoneID
{
    id<MPAdColonyRouterDelegate> event = [self.events objectForKey:zoneID];
    [event onAdAttemptFinished:YES inZone:zoneID];
}

- (void)onAdDidFailToLoad:(NSString *)zoneID withError:(NSError *)error
{
    id<MPAdColonyRouterDelegate> event = [self.events objectForKey:zoneID];
    [event zoneDidFailToLoad:error];
}

- (void)onAdLoaded:(NSString *)zoneID
{
    id<MPAdColonyRouterDelegate> event = [self.events objectForKey:zoneID];
    [event zoneDidLoad];
}
- (void)onAdExpired:(NSString *)zoneID
{
    id<MPAdColonyRouterDelegate> event = [self.events objectForKey:zoneID];
    if(event.zoneAvailable)
    {
    	[event zoneDidExpire];
    }
}

@end
