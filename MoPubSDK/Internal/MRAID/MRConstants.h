//
//  MRConstants.h
//  MoPubSDK
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

enum {
    MRAdViewStateHidden,
    MRAdViewStateDefault,
    MRAdViewStateExpanded,
    MRAdViewStateResized
};
typedef NSUInteger MRAdViewState;

enum {
    MRAdViewPlacementTypeInline,
    MRAdViewPlacementTypeInterstitial
};
typedef NSUInteger MRAdViewPlacementType;

NSString *const kOrientationPropertyForceOrientationPortraitKey = @"portrait";
NSString *const kOrientationPropertyForceOrientationLandscapeKey = @"landscape";
NSString *const kOrientationPropertyForceOrientationNoneKey = @"none";
