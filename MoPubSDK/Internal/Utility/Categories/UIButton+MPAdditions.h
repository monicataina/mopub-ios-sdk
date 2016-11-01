//
//  UIButton+MPAdditions.h
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIControl+MPAdditions.h"

@interface MPAdditions_UIButton : UIButton

@property (nonatomic) MPAdditions_UIControl *mpUIControl;
@property (nonatomic) UIEdgeInsets mp_TouchAreaInsets;

- (UIEdgeInsets)mp_TouchAreaInsets;
- (void)setMp_TouchAreaInsets:(UIEdgeInsets)touchAreaInsets;
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event;

@end
