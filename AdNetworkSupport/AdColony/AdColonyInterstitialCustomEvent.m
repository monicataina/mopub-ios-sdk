//
//  AdColonyInterstitialCustomEvent.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <AdColony/AdColony.h>
#import "AdColonyInterstitialCustomEvent.h"
#import "MPAdColonyRouter.h"
#import "MPInstanceProvider+AdColony.h"
#import "MPLogging.h"
#import "AdColonyCustomEvent.h"

static NSString *gAppId = nil;
static NSString *gDefaultZoneId = nil;
static NSArray *gAllZoneIds = nil;

#define kAdColonyAppId @"YOUR_ADCOLONY_APPID"
#define kAdColonyDefaultZoneId @"YOUR_ADCOLONY_DEFAULT_ZONEID" // This zone id will be used if "zoneId" is not passed through the custom info dictionary

#define AdColonyZoneIds() [NSArray arrayWithObjects:@"YOUR_ADCOLONY_ZONEID1", @"YOUR_ADCOLONY_ZONEID2", nil]

@interface AdColonyInterstitialCustomEvent () <MPAdColonyRouterDelegate>

@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *zoneId;
@property (nonatomic, assign) BOOL zoneAvailable;

@end

@implementation AdColonyInterstitialCustomEvent

@synthesize zoneId = _zoneId;

+ (void)setAppId:(NSString *)appId
{
    MPLogWarn(@"+setAppId for class AdColonyInterstitialCustomEvent is deprecated. Use the appId parameter when configuring your network in the MoPub website.");
    gAppId = [appId copy];
}

+ (void)setDefaultZoneId:(NSString *)defaultZoneId
{
    MPLogWarn(@"+setDefaultZoneId for class AdColonyInterstitialCustomEvent is deprecated. Use the zoneId parameter when configuring your network in the MoPub website.");
    gDefaultZoneId = [defaultZoneId copy];
}

+ (void)setAllZoneIds:(NSArray *)zoneIds
{
    MPLogWarn(@"+setAllZoneIds for class AdColonyInterstitialCustomEvent is deprecated. Use the allZoneIds parameter when configuring your network in the MoPub website.");
    gAllZoneIds = zoneIds;
}

#pragma mark - MPInterstitialCustomEvent Subclass Methods

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
{
    self.appId = [info objectForKey:@"appId"];
    if(self.appId == nil)
    {
        self.appId = gAppId;

        if ([self.appId length] == 0) {
            MPLogWarn(@"Setting kAdColonyAppId in AdColonyInterstitialCustomEvent.m is deprecated. Use the appId parameter when configuring your network in the MoPub website.");
            self.appId = kAdColonyAppId;
        }
    }

    NSArray *allZoneIds = [info objectForKey:@"allZoneIds"];
    if(allZoneIds.count == 0)
    {
        allZoneIds = gAllZoneIds;

        if ([allZoneIds count] == 0) {
            MPLogWarn(@"Setting AdColonyZoneIds in AdColonyInterstitialCustomEvent.m is deprecated. Use the allZoneIds parameter when configuring your network in the MoPub website.");
            allZoneIds = AdColonyZoneIds();
        }
    }

    if(self.appId != nil)
    {
        [[MPAdColonyRouter sharedRouter] addGlobalCustomEvent:self];
    }
    
    NSString *zoneId = [info objectForKey:@"zoneId"];
    if(zoneId == nil)
    {
        zoneId = gDefaultZoneId;
        
        if ([zoneId length] == 0) {
            MPLogWarn(@"Setting kAdColonyDefaultZoneId in AdColonyInterstitialCustomEvent.m is deprecated. Use the zondId parameter when configuring your network in the MoPub website.");
            zoneId = kAdColonyDefaultZoneId;
        }
    }
    
    BOOL configureIsCalled = [AdColonyCustomEvent initializeAdColonyCustomEventWithAppId:self.appId allZoneIds:allZoneIds customerId:nil forZoneId:zoneId];

    self.zoneId = zoneId;
    self.zoneAvailable = NO;

    // let AdColony inform us when the zone becomes available
    
    //load ad only if this time configure SDK wasn't called, 
    //otherwise wait for configure to finish, then try to load the ad
    if(!configureIsCalled)
    {
        [self requestRewardedVideoWithCurrentZoneId];
    }
}
- (void)requestRewardedVideoWithCurrentZoneId
{
    if(self.zoneId != nil && self.appId != nil) {
        [[MPAdColonyRouter sharedRouter] setCustomEvent:self forZoneId:self.zoneId];
        if(![MPAdColonyRouter sharedRouter].isWaitingForInit)
        {
            [[MPAdColonyRouter sharedRouter] requestVideoAdWithZoneId:self.zoneId showPrePopup:NO showPostPopup:NO];
        }
    }
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController
{
    if ([[MPAdColonyRouter sharedRouter] hasAdAvailableForZone:self.zoneId]) {
        MPLogInfo(@"AdColony zone %@ attempting to start", self.zoneId);
        
        [[MPAdColonyRouter sharedRouter] showAdForZone:self.zoneId withViewController:rootViewController];
        
        [self.delegate interstitialCustomEventWillAppear:self];
    } else {
        MPLogInfo(@"Failed to show AdColony video interstitial: AdColony now claims zone %@ is not available", self.zoneId);
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:nil];
    }
}

- (void)invalidate
{
    [[MPAdColonyRouter sharedRouter] removeCustomEvent:self forZoneId:self.zoneId];
}

#pragma mark - MPAdColonyRouterDelegate

- (void)configured
{
    //the SDK configure was successfully done, so now the ad can be loaded
    [self requestRewardedVideoWithCurrentZoneId];
}

- (void)zoneDidLoad
{
    self.zoneAvailable = YES;
    [self.delegate interstitialCustomEvent:self didLoadAd:nil];
}

- (void)zoneDidExpire
{
    self.zoneAvailable = NO;
    [self.delegate interstitialCustomEventDidExpire:self];
}

- (void)zoneDidFailToLoad:(NSError *)error
{
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)onAdStartedInZone:(NSString *)zoneID
{
    MPLogInfo(@"AdColony zone %@ started", zoneID);
    [self.delegate interstitialCustomEventDidAppear:self];
}

- (void)onAttemptFinished:(BOOL)shown inZone:(NSString *)zoneID
{
    MPLogInfo(@"AdColony zone %@ finished", zoneID);
    [self.delegate interstitialCustomEventWillDisappear:self];
    [self.delegate interstitialCustomEventDidDisappear:self];
}

@end
