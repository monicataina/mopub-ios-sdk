//
//  MPAdColonyRouter.h
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AdColony/AdColony.h>

#import "MPRewardedVideoReward.h"

@protocol MPAdColonyRouterDelegate;

/*
 * Maps all Ad Colony zone IDs for both interstitials and rewarded video to their
 * corresponding custom event objects.
 */
@interface MPAdColonyRouter : NSObject

@property (nonatomic, assign) BOOL isWaitingForInit;

+ (MPAdColonyRouter *)sharedRouter;

- (void) requestVideoAdWithZoneId:(NSString*)zoneId showPrePopup:(BOOL)showPrePopup showPostPopup:(BOOL)showPostPopup;

- (BOOL) hasAdAvailableForZone:(NSString*)zoneId;

- (void) showAdForZone:(NSString*)zoneId withViewController:(UIViewController *)viewController;

/*
 * Associates a custom event with a zone ID.
 *
 * By calling this method, all Ad Colony events associated with zoneID will be routed
 * to customEvent via the `MPAdColonyRouterDelegate` methods.
 *
 * @param customEvent The custom event object associated with zoneID.
 * @param zoneId The zone ID associated with the Ad Colony ad we're working on.
 */
- (void)setCustomEvent:(id<MPAdColonyRouterDelegate>)customEvent forZoneId:(NSString *)zoneID;

/*
 * Disassociates a custom event for a zone ID.
 *
 * By calling this method, the router will stop sending methods to the custom event
 * corresponding to zoneID.
 *
 * @param customEvent The custom event that is currently associated with zoneId.
 * @param zoneId The zone ID associated with the Ad Colony ad we're working on.
 */
- (void)removeCustomEvent:(id<MPAdColonyRouterDelegate>)customEvent forZoneId:(NSString *)zoneId;

/*
 * Adds a custom event for global events like onConfigured
 *
 * By calling this method, all Ad Colony events associated will be routed
 * to customEvent via the `MPAdColonyRouterDelegate` static methods.
 *
 * @param customEvent The custom event object .
 */
- (void)addGlobalCustomEvent:(id<MPAdColonyRouterDelegate>)customEvent;

/*
 * Removes a custom event.
 *
 * By calling this method, the router will stop sending methods to the specified custom event
 *
 * @param customEvent The custom event that won't be notified by MPAdColonyRouterDelegate.
 */
- (void)removeGlobalCustomEvent:(id<MPAdColonyRouterDelegate>)customEvent;

/*
 * Notifies the registered delegates (registered via addGlobalCustomEvent: method)
 * that the AdColony SDK finished to configure
 *
 */
- (void)onConfigured;

- (void)onAdDidFailToLoad:(NSString *)zoneID withError:(NSError *)error;

@end

/*
 * Ad Colony custom events should implement this protocol to receive relevant Ad Colony
 * ad events.
 */
@protocol MPAdColonyRouterDelegate <NSObject>

@required

/*
 * The object implementing `MPAdColonyRouterDelegate` must implement this method to tell the
 * router if its zone is currently available.
 */
- (BOOL)zoneAvailable;

/*
 * This method is called when an Ad Colony ad successfully loads for its zone ID.
 */
- (void)zoneDidLoad;

/*
 * This method is called when an Ad Colony ad expires for its zone ID.
 */
- (void)zoneDidExpire;


- (void)zoneDidFailToLoad:(NSError *)error;

- (void)onAdAttemptFinished:(BOOL)shown inZone:(NSString *)zoneID;

- (void)onAdStartedInZone:(NSString *)zoneID;


@optional

/*
 * This method is called when the application user should be rewarded for watching a rewarded
 * video.
 */
- (void)shouldRewardUserWithReward:(MPRewardedVideoReward *)reward;

/*
 * This method is called when Ad Colony was successfully configured.
 */
+ (void)configured;

@end
