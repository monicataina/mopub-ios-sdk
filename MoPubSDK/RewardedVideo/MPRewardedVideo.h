//
//  MPRewardedVideo.h
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class MPRewardedVideoReward;
@class CLLocation;
@protocol MPRewardedVideoDelegate;

/**
 * `MPRewardedVideo` allows you to load and play rewarded video ads. All ad events are
 * reported, with an ad unit ID, to the delegate allowing the application to respond to the events
 * for the corresponding ad.
 *
 * **Important**: You must call `[initializeRewardedVideoWithGlobalMediationSettings:delegate:][MoPub initializeRewardedVideoWithGlobalMediationSettings:delegate:]`
 * to initialize the rewarded video system.
 */
@interface MPRewardedVideo : NSObject

/**
 * Loads a rewarded video ad for the given ad unit ID.
 *
 * The mediation settings array should contain ad network specific objects for networks that may be loaded for the given ad unit ID.
 * You should set the properties on these objects to determine how the underlying ad network should behave. You only need to supply
 * objects for the networks you wish to configure. If you do not want your network to behave differently from its default behavior, do
 * not pass in an mediation settings object for that network.
 *
 * @param adUnitID The ad unit ID that ads should be loaded from.
 * @param mediationSettings An array of mediation settings objects that map to networks that may show ads for the ad unit ID. This array
 * @param delegate The delegate that will receive all events related to rewarded video.
 * should only contain objects for networks you wish to configure. This can be nil.
 */
+ (void)loadRewardedVideoAdWithAdUnitID:(NSString *)adUnitID withMediationSettings:(NSArray *)mediationSettings  delegate:(id<MPRewardedVideoDelegate>)delegate;

/**
 * Loads a rewarded video ad for the given ad unit ID.
 *
 * The mediation settings array should contain ad network specific objects for networks that may be loaded for the given ad unit ID.
 * You should set the properties on these objects to determine how the underlying ad network should behave. You only need to supply
 * objects for the networks you wish to configure. If you do not want your network to behave differently from its default behavior, do
 * not pass in an mediation settings object for that network.
 *
 * @param adUnitID The ad unit ID that ads should be loaded from.
 * @param keywords A string representing a set of keywords that should be passed to the MoPub ad server to receive
 * more relevant advertising.
 * @param location Latitude/Longitude that are passed to the MoPub ad server
 * @param mediationSettings An array of mediation settings objects that map to networks that may show ads for the ad unit ID. This array
 * should only contain objects for networks you wish to configure. This can be nil.
 * @param delegate The delegate that will receive all events related to rewarded video.
 */
+ (void)loadRewardedVideoAdWithAdUnitID:(NSString *)adUnitID keywords:(NSString *)keywords location:(CLLocation *)location mediationSettings:(NSArray *)mediationSettings delegate:(id<MPRewardedVideoDelegate>)delegate;

/**
 * Loads a rewarded video ad for the given ad unit ID.
 *
 * The mediation settings array should contain ad network specific objects for networks that may be loaded for the given ad unit ID.
 * You should set the properties on these objects to determine how the underlying ad network should behave. You only need to supply
 * objects for the networks you wish to configure. If you do not want your network to behave differently from its default behavior, do
 * not pass in an mediation settings object for that network.
 *
 * @param adUnitID The ad unit ID that ads should be loaded from.
 * @param keywords A string representing a set of keywords that should be passed to the MoPub ad server to receive
 * more relevant advertising.
 * @param location Latitude/Longitude that are passed to the MoPub ad server
 * @param customerId This is the ID given to the user by the publisher to identify them in their app
 * @param mediationSettings An array of mediation settings objects that map to networks that may show ads for the ad unit ID. This array
 * should only contain objects for networks you wish to configure. This can be nil.
 * @param delegate The delegate that will receive all events related to rewarded video.
 */
+ (void)loadRewardedVideoAdWithAdUnitID:(NSString *)adUnitID keywords:(NSString *)keywords location:(CLLocation *)location customerId:(NSString *)customerId mediationSettings:(NSArray *)mediationSettings delegate:(id<MPRewardedVideoDelegate>)delegate;

/**
 * Returns whether or not an ad is available for the given ad unit ID.
 *
 * @param adUnitID The ad unit ID associated with the ad you want to retrieve the availability for.
 */
+ (BOOL)hasAdAvailableForAdUnitID:(NSString *)adUnitID;

/**
 * Plays a rewarded video ad.
 *
 * @param adUnitID The ad unit ID associated with the video ad you wish to play.
 * @param viewController The view controller that will present the rewarded video ad.
 *
 * @warning **Important**: You should not attempt to play the rewarded video unless `+hasAdAvailableForAdUnitID:` indicates that an
 * ad is available for playing or you have received the `[-rewardedVideoAdDidLoadForAdUnitID:]([MPRewardedVideoDelegate rewardedVideoAdDidLoadForAdUnitID:])`
 * message.
 */
+ (void)presentRewardedVideoAdForAdUnitID:(NSString *)adUnitID fromViewController:(UIViewController *)viewController;

@end

@protocol MPRewardedVideoDelegate <NSObject>

@optional

/**
 * This method is called after an ad loads successfully.
 *
 * @param adUnitID The ad unit ID of the ad associated with the event.
 * @param customClassID The ID from the `MPRewardedVideoCustomEvent` subclass which triggered this event.
 */
- (void)rewardedVideoAdDidLoadForAdUnitID:(NSString *)adUnitID forCustomClassID:(int)customClassID;

/**
 * This method is called after an ad fails to load.
 *
 * @param adUnitID The ad unit ID of the ad associated with the event.
 * @param customClassID The ID from the `MPRewardedVideoCustomEvent` subclass which triggered this event.
 * @param error An error indicating why the ad failed to load.
 */
- (void)rewardedVideoAdDidFailToLoadForAdUnitID:(NSString *)adUnitID forCustomClassID:(int)customClassID error:(NSError *)error;

/**
 * This method is called when a previously loaded rewarded video is no longer eligible for presentation.
 *
 * @param adUnitID The ad unit ID of the ad associated with the event.
 * @param customClassID The ID from the `MPRewardedVideoCustomEvent` subclass which triggered this event.
 */
- (void)rewardedVideoAdDidExpireForAdUnitID:(NSString *)adUnitID forCustomClassID:(int)customClassID;

/**
 * This method is called when an attempt to play a rewarded video fails.
 *
 * @param adUnitID The ad unit ID of the ad associated with the event.
 * @param customClassID The ID from the `MPRewardedVideoCustomEvent` subclass which triggered this event.
 * @param error An error describing why the video couldn't play.
 */
- (void)rewardedVideoAdDidFailToPlayForAdUnitID:(NSString *)adUnitID forCustomClassID:(int)customClassID error:(NSError *)error;

/**
 * This method is called when a rewarded video ad is about to appear.
 *
 * @param adUnitID The ad unit ID of the ad associated with the event.
 * @param customClassID The ID from the `MPRewardedVideoCustomEvent` subclass which triggered this event.
 */
- (void)rewardedVideoAdWillAppearForAdUnitID:(NSString *)adUnitID forCustomClassID:(int)customClassID;

/**
 * This method is called when a rewarded video ad has appeared.
 *
 * @param adUnitID The ad unit ID of the ad associated with the event.
 * @param customClassID The ID from the `MPRewardedVideoCustomEvent` subclass which triggered this event.
 */
- (void)rewardedVideoAdDidAppearForAdUnitID:(NSString *)adUnitID forCustomClassID:(int)customClassID;

/**
 * This method is called when a rewarded video ad will be dismissed.
 *
 * @param adUnitID The ad unit ID of the ad associated with the event.
 * @param customClassID The ID from the `MPRewardedVideoCustomEvent` subclass which triggered this event.
 */
- (void)rewardedVideoAdWillDisappearForAdUnitID:(NSString *)adUnitID forCustomClassID:(int)customClassID;

/**
 * This method is called when a rewarded video ad has been dismissed.
 *
 * @param adUnitID The ad unit ID of the ad associated with the event.
 * @param customClassID The ID from the `MPRewardedVideoCustomEvent` subclass which triggered this event.
 */
- (void)rewardedVideoAdDidDisappearForAdUnitID:(NSString *)adUnitID forCustomClassID:(int)customClassID;

/**
 * This method is called when the user taps on the ad.
 *
 * @param adUnitID The ad unit ID of the ad associated with the event.
 * @param customClassID The ID from the `MPRewardedVideoCustomEvent` subclass which triggered this event.
 */
- (void)rewardedVideoAdDidReceiveTapEventForAdUnitID:(NSString *)adUnitID forCustomClassID:(int)customClassID;

/**
 * This method is called when a rewarded video ad will cause the user to leave the application.
 *
 * @param adUnitID The ad unit ID of the ad associated with the event.
 * @param customClassID The ID from the `MPRewardedVideoCustomEvent` subclass which triggered this event.
 */
- (void)rewardedVideoAdWillLeaveApplicationForAdUnitID:(NSString *)adUnitID forCustomClassID:(int)customClassID;

/**
 * This method is called when the user should be rewarded for watching a rewarded video ad.
 *
 * @param adUnitID The ad unit ID of the ad associated with the event.
 * @param customClassID The ID from the `MPRewardedVideoCustomEvent` subclass which triggered this event.
 * @param reward The object that contains all the information regarding how much you should reward the user.
 */
- (void)rewardedVideoAdShouldRewardForAdUnitID:(NSString *)adUnitID forCustomClassID:(int)customClassID reward:(MPRewardedVideoReward *)reward;

/**
 * This method is called when the user could not be rewarded for watching a rewarded video ad.
 *
 * @param adUnitID The ad unit ID of the ad associated with the event.
 * @param customClassID The ID from the `MPRewardedVideoCustomEvent` subclass which triggered this event.
 * @param reward The object that contains all the information regarding how much you should reward the user.
 */
- (void)rewardedVideoAdFailedToRewardForAdUnitID:(NSString *)adUnitID forCustomClassID:(int)customClassID reward:(MPRewardedVideoReward *)reward;

@end
