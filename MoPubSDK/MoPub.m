//
//  MoPub.m
//  MoPub
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "MoPub.h"
#import "MPConstants.h"
#import "MPCoreInstanceProvider.h"
#import "MPGeolocationProvider.h"
#import "MPRewardedVideo.h"
#import "MPLogProvider.h"
#import "MPIdentityProvider.h"

// If Fabric headers are integrated from multiple third party frameworks, there might be naming conflict.
// Use relative path could solve the naming conflict.
#import "Internal/Fabric/FABKitProtocol.h"
#import "Internal/Fabric/Fabric+FABKits.h"

#import "UIControl+MPAdditions.h"
#import "NSHTTPURLResponse+MPAdditions.h"
#import "NSJSONSerialization+MPAdditions.h"
#import "NSURL+MPAdditions.h"
#import "UIButton+MPAdditions.h"
#import "UIActivityIndicatorView+MPAdditions.h"
#import "UIColor+MPAdditions.h"
#import "UIView+MPAdditions.h"
#import "UIWebView+MPAdditions.h"


@interface MoPub () <FABKit>

@property (nonatomic, strong) NSArray *globalMediationSettings;

@end

@implementation MoPub

+ (MoPub *)sharedInstance
{
    static MoPub *sharedInstance = nil;
    static dispatch_once_t initOnceToken;
    dispatch_once(&initOnceToken, ^{
        sharedInstance = [[MoPub alloc] init];
        
        //force loading ObjC classes
        [MPAdditions_UIControl initialize];
        [MPAdditions_NSHTTPURLResponse initialize];
        [MPAdditions_NSJSONSerialization initialize];
        [MPAdditions_NSURL initialize];
        [MPAdditions_UIButton initialize];
        [MPAdditions_UIActivityIndicatorView initialize];
        [MPAdditions_UIColor initialize];
        [MPAdditions_UIView initialize];
        [MPAdditions_UIWebView initialize];
        
        
    });
    return sharedInstance;
}

+ (NSString *)bundleIdentifier
{
    return MP_BUNDLE_IDENTIFIER;
}

+ (NSString *)kitDisplayVersion
{
    return MP_SDK_VERSION;
}

- (void)setLocationUpdatesEnabled:(BOOL)locationUpdatesEnabled
{
    [[[MPCoreInstanceProvider sharedProvider] sharedMPGeolocationProvider] setLocationUpdatesEnabled:locationUpdatesEnabled];
}

- (BOOL)locationUpdatesEnabled
{
    return [[MPCoreInstanceProvider sharedProvider] sharedMPGeolocationProvider].locationUpdatesEnabled;
}

- (void)setFrequencyCappingIdUsageEnabled:(BOOL)frequencyCappingIdUsageEnabled
{
    [MPIdentityProvider setFrequencyCappingIdUsageEnabled:frequencyCappingIdUsageEnabled];
}

- (BOOL)frequencyCappingIdUsageEnabled
{
    return [MPIdentityProvider frequencyCappingIdUsageEnabled];
}

- (void)start
{

}

// Keep -version and -bundleIdentifier methods around for Fabric backwards compatibility.
- (NSString *)version
{
    return MP_SDK_VERSION;
}

- (NSString *)bundleIdentifier
{
    return MP_BUNDLE_IDENTIFIER;
}

- (void)initializeRewardedVideoWithGlobalMediationSettings:(NSArray *)globalMediationSettings
{
    [self initializeRewardedVideoWithGlobalMediationSettings:globalMediationSettings enableDebugging:YES];
}

- (void)initializeRewardedVideoWithGlobalMediationSettings:(NSArray *)globalMediationSettings enableDebugging:(BOOL)enableDebugging
{
    [[MPLogProvider sharedLogProvider] setDebugMode:enableDebugging];
    
    // initializeWithDelegate: is a known private initialization method on MPRewardedVideo. So we forward the initialization call to that class.
    [MPRewardedVideo performSelector:@selector(initializeRewardedVideo)];
    self.globalMediationSettings = globalMediationSettings;
    self.m_enableDebugging = enableDebugging;
}

- (id<MPMediationSettingsProtocol>)globalMediationSettingsForClass:(Class)aClass
{
    NSArray *mediationSettingsCollection = self.globalMediationSettings;

    for (id<MPMediationSettingsProtocol> settings in mediationSettingsCollection) {
        if ([settings isKindOfClass:aClass]) {
            return settings;
        }
    }

    return nil;
}

@end
