//
//  MPFacebookRouter.m
//  MoPubSDK
//
//  Copyright (c) 2016 MoPub. All rights reserved.
//

#import "MoPub.h"
#import "MPFacebookRouter.h"
#import "FacebookInstanceMediationSettings.h"
#import "MPInstanceProvider+Facebook.h"
#import "MPRewardedVideoError.h"
#import "MPRewardedVideo.h"

@interface MPFacebookRouter ()

@property (nonatomic, assign) BOOL isAdPlaying;

@property (nonatomic, strong) NSMutableDictionary* loadingAds;
@property (nonatomic, strong) NSMutableDictionary* delegatePerLoadingAd;
@property (nonatomic, strong) NSMutableDictionary* rewardCurrencyPerLoadingAd;
@property (nonatomic, strong) NSMutableDictionary* rewardAmountPerLoadingAd;

@property (nonatomic, assign) FBRewardedVideoAd* displayedAd;
@property (nonatomic, assign) id<MPFacebookRouterDelegate> delegateForDisplayedAd;
@property (nonatomic, assign) NSString* rewardCurrencyForDisplayedAd;
@property (nonatomic, assign) NSNumber* rewardAmountForDisplayedAd;


@property (nonatomic, assign) BOOL isAdClosed;
@property (nonatomic, assign) BOOL isRewardCallbackCalled;


@end

@implementation MPFacebookRouter

+ (MPFacebookRouter *)sharedRouter
{
    return [MPFacebookInstanceProvider sharedMPFacebookRouterFrom:[MPInstanceProvider sharedProvider]];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _displayedAd = NULL;
        _loadingAds = [[NSMutableDictionary alloc] init];
        _delegatePerLoadingAd = [[NSMutableDictionary alloc] init];
        _rewardCurrencyPerLoadingAd = [[NSMutableDictionary alloc] init];
        _rewardAmountPerLoadingAd = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_delegate release];
    [_loadingAds release];
    [_delegatePerLoadingAd release];
    [_rewardCurrencyPerLoadingAd release];
    [_rewardAmountPerLoadingAd release];
    [super dealloc];
}

- (void)requestRewardedVideoAdWithZoneId:(NSString *)zoneId customerId:(NSString *)customerId settings:(FacebookInstanceMediationSettings *)settings delegate:(id<MPFacebookRouterDelegate>)delegate;
{
    if (!self.isAdPlaying) {
        
        self.delegate = delegate;
        
        static dispatch_once_t facebookInitToken;
        dispatch_once(&facebookInitToken, ^{
            if([[MoPub sharedInstance] m_enableDebugging])
            {
                //set the current device as test device for FAN ads
                [FBAdSettings addTestDevice:[FBAdSettings testDeviceHash]];
            }
        });
        
        NSString* userId = NULL;
        if (customerId.length >0) {
            userId = customerId;
        } else if (settings.userIdentifier.length > 0) {
            userId = settings.userIdentifier;
        }
        
        NSString* currency = @"";
        if(settings.rewardCurrencyName.length > 0){
            currency = settings.rewardCurrencyName;
        }
        
        NSInteger amount = 0;
        if(settings.rewardAmount > 0){
            amount = settings.rewardAmount;
        }
        
        [self.rewardCurrencyPerLoadingAd removeObjectForKey:zoneId];
        [self.rewardAmountPerLoadingAd removeObjectForKey:zoneId];
        
        FBRewardedVideoAd* loadingAd = [self.loadingAds objectForKey:zoneId];
        if(loadingAd)
        {
            if(loadingAd.isAdValid)
            {
                [delegate facebookFetchCompleted];
                return;
            }
            else
            {
                loadingAd = NULL;
            }
        }
        loadingAd = [[FBRewardedVideoAd alloc] initWithPlacementID:zoneId withUserID:userId withCurrency:currency withAmount:amount];
        [self.loadingAds setObject:loadingAd forKey:zoneId];
        [self.delegatePerLoadingAd removeObjectForKey:zoneId];
        [self.delegatePerLoadingAd setObject:delegate forKey:zoneId];
        [self.rewardCurrencyPerLoadingAd setObject:currency forKey:zoneId];
        [self.rewardAmountPerLoadingAd setObject:[NSNumber numberWithInteger:amount] forKey:zoneId];
        loadingAd.delegate = self;
        [loadingAd loadAd];
        
        // MoPub timeout will handle the case for an ad failing to load.
    } else {
        NSError *error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorUnknown userInfo:nil];
        [delegate facebookDidFailWithError:error];
    }
}

- (BOOL)isAdAvailableForZoneId:(NSString *)zoneId
{
    FBRewardedVideoAd* loadingAd = [self.loadingAds objectForKey:zoneId];
    if(!loadingAd)
    {
        return NO;
    }
    
    return [loadingAd isAdValid];
}

- (void)presentRewardedVideoAdFromViewController:(UIViewController *)viewController customerId:(NSString *)customerId zoneId:(NSString *)zoneId settings:(FacebookInstanceMediationSettings *)settings delegate:(id<MPFacebookRouterDelegate>)delegate
{
    if (!self.isAdPlaying && [self isAdAvailableForZoneId:zoneId]) {
        
        self.delegate = delegate;
        self.isAdPlaying = YES;

        self.isAdClosed = NO;
        self.isRewardCallbackCalled = NO;
        
        self.displayedAd = [self.loadingAds objectForKey:zoneId];
        [self.loadingAds removeObjectForKey:zoneId];
        self.delegateForDisplayedAd = [self.delegatePerLoadingAd objectForKey:zoneId];
        [self.delegatePerLoadingAd removeObjectForKey:zoneId];
        self.rewardCurrencyForDisplayedAd = [self.rewardCurrencyPerLoadingAd objectForKey:zoneId];
        [self.rewardCurrencyPerLoadingAd removeObjectForKey:zoneId];
        self.rewardAmountForDisplayedAd = [self.rewardAmountPerLoadingAd objectForKey:zoneId];
        [self.rewardAmountPerLoadingAd removeObjectForKey:zoneId];
        
        [self.displayedAd showAdFromRootViewController:viewController];
        
    } else {
        NSError *error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorUnknown userInfo:nil];
        [delegate facebookDidFailWithError:error];
    }
}

- (void)clearDelegate:(id<MPFacebookRouterDelegate>)delegate
{
    NSArray* allKeysToBeRemoved = [self.delegatePerLoadingAd allKeysForObject:delegate];
    if(allKeysToBeRemoved)
    {
        for(id key in allKeysToBeRemoved)
        {
            [self.delegatePerLoadingAd removeObjectForKey:key];
        }
    }
    
    if(self.delegateForDisplayedAd == delegate)
    {
        self.delegateForDisplayedAd = NULL;
    }
    
    if (self.delegate == delegate)
    {
        [self setDelegate:nil];
    }
}

#pragma mark - FBRewardedVideoAdDelegate
/*!
 @method
 
 @abstract
 Sent after an ad has been clicked by the person.
 
 @param rewardedVideoAd An FBRewardedVideoAd object sending the message.
 */
- (void)rewardedVideoAdDidClick:(FBRewardedVideoAd *)rewardedVideoAd
{
    if(self.displayedAd && self.delegateForDisplayedAd && self.displayedAd == rewardedVideoAd)
    {
        [self.delegateForDisplayedAd facebookDidClick];
    }
}

/*!
 @method
 
 @abstract
 Sent when an ad has been successfully loaded.
 
 @param rewardedVideoAd An FBRewardedVideoAd object sending the message.
 */
- (void)rewardedVideoAdDidLoad:(FBRewardedVideoAd *)rewardedVideoAd
{
    id<MPFacebookRouterDelegate> delegate = [self.delegatePerLoadingAd objectForKey:rewardedVideoAd.placementID];
    if(delegate)
    {
        [delegate facebookFetchCompleted];
    }
}

/*!
 @method
 
 @abstract
 Sent after an FBRewardedVideoAd object has been dismissed from the screen, returning control
 to your application.
 
 @param rewardedVideoAd An FBRewardedVideoAd object sending the message.
 */
- (void)rewardedVideoAdDidClose:(FBRewardedVideoAd *)rewardedVideoAd
{
    self.isAdClosed = YES;
    if(self.displayedAd && self.delegateForDisplayedAd && self.displayedAd == rewardedVideoAd)
    {
        [self.delegateForDisplayedAd facebookDidHide];
        if(self.isRewardCallbackCalled == YES)
        {
            self.isAdClosed = NO;
            self.isRewardCallbackCalled = NO;
            self.displayedAd = NULL;
            self.delegateForDisplayedAd = NULL;
            self.isAdPlaying = NO;
        }
    }
}

/*!
 @method
 
 @abstract
 Sent immediately before an FBRewardedVideoAd object will be dismissed from the screen.
 
 @param rewardedVideoAd An FBRewardedVideoAd object sending the message.
 */
- (void)rewardedVideoAdWillClose:(FBRewardedVideoAd *)rewardedVideoAd
{
    if(self.displayedAd && self.delegateForDisplayedAd && self.displayedAd == rewardedVideoAd)
    {
        [self.delegateForDisplayedAd facebookWillHide];
    }
}

/*!
 @method
 
 @abstract
 Sent after an FBRewardedVideoAd fails to load the ad.
 
 @param rewardedVideoAd An FBRewardedVideoAd object sending the message.
 @param error An error object containing details of the error.
 */
- (void)rewardedVideoAd:(FBRewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error
{
    id<MPFacebookRouterDelegate> delegate = [self.delegatePerLoadingAd objectForKey:rewardedVideoAd.placementID];
    if(delegate)
    {
        [delegate facebookDidFailWithError:error];
    }
}

/*!
 @method
 
 @abstract
 Sent after the FBRewardedVideoAd object has finished playing the video successfully.
 Reward the user on this callback.
 
 @param rewardedVideoAd An FBRewardedVideoAd object sending the message.
 */
- (void)rewardedVideoAdComplete:(FBRewardedVideoAd *)rewardedVideoAd
{
    if(self.displayedAd && self.delegateForDisplayedAd && self.displayedAd == rewardedVideoAd)
    {
        [self.delegateForDisplayedAd facebookVideoCompleted:self.rewardCurrencyForDisplayedAd rewardAmount:self.rewardAmountForDisplayedAd];
    }
}

/*!
 @method
 
 @abstract
 Sent immediately before the impression of an FBRewardedVideoAd object will be logged.
 
 @param rewardedVideoAd An FBRewardedVideoAd object sending the message.
 */
- (void)rewardedVideoAdWillLogImpression:(FBRewardedVideoAd *)rewardedVideoAd
{
    if(self.displayedAd && self.delegateForDisplayedAd && self.displayedAd == rewardedVideoAd)
    {
        [self.delegateForDisplayedAd facebookWillShow];
        [self.delegateForDisplayedAd facebookDidShow];
    }
}

/*!
 @method
 
 @abstract
 Sent if server call to publisher's reward endpoint returned HTTP status code 200.
 
 @param rewardedVideoAd An FBRewardedVideoAd object sending the message.
 */
- (void)rewardedVideoAdServerSuccess:(FBRewardedVideoAd *)rewardedVideoAd
{
    self.isRewardCallbackCalled = YES;
    if(self.displayedAd && self.delegateForDisplayedAd && self.displayedAd == rewardedVideoAd)
    {
        [self.delegateForDisplayedAd facebookVideoAdServerSuccess:self.rewardCurrencyForDisplayedAd rewardAmount:self.rewardAmountForDisplayedAd];
        if(self.isAdClosed == YES)
        {
            self.isAdClosed = NO;
            self.isRewardCallbackCalled = NO;
            self.displayedAd = NULL;
            self.delegateForDisplayedAd = NULL;
            self.isAdPlaying = NO;
        }
    }
}

/*!
 @method
 
 @abstract
 Sent if server call to publisher's reward endpoint did not return HTTP status code 200
 or if the endpoint timed out.
 
 @param rewardedVideoAd An FBRewardedVideoAd object sending the message.
 */
- (void)rewardedVideoAdServerFailed:(FBRewardedVideoAd *)rewardedVideoAd
{
    self.isRewardCallbackCalled = YES;
    if(self.displayedAd && self.delegateForDisplayedAd && self.displayedAd == rewardedVideoAd)
    {
        [self.delegateForDisplayedAd facebookVideoAdServerFailed:self.rewardCurrencyForDisplayedAd rewardAmount:self.rewardAmountForDisplayedAd];
        if(self.isAdClosed == YES)
        {
            self.isAdClosed = NO;
            self.isRewardCallbackCalled = NO;
            self.displayedAd = NULL;
            self.delegateForDisplayedAd = NULL;
            self.isAdPlaying = NO;
        }
    }
}

@end
