//
//  UIWebView+MPAdditions.h
//  MoPub
//
//  Created by Andrew He on 11/6/11.
//  Copyright (c) 2011 MoPub, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UIView+MPAdditions.h"

extern NSString *const kJavaScriptDisableDialogSnippet;

@interface MPAdditions_UIWebView : NSObject

+ (void)mp_setScrollable:(BOOL)scrollable forWebView:(UIWebView *)webView;
+ (void)disableJavaScriptDialogsForWebView:(UIWebView *)webView;

@end
