//
//  HTMLPlugin.h
//  BitBar
//
//  Created by Mathias Leppich on 22/01/14.
//  Copyright (c) 2014 Bit Bar. All rights reserved.
//

#import "Plugin.h"

@class WebView;

@interface HTMLPlugin : Plugin

@property (nonatomic, strong) NSTimer *autoReloadTimer;
@property (nonatomic, strong) WebView *webView;

@property (nonatomic, readonly) NSString * reloadInterval;

@property (nonatomic, strong) NSMenu * menu;


// callable from JavaScript
- (void) resizeToFit;
- (void) resetMenu;
- (void) addMenuItem:(NSObject*)titleOrParamsDict;
- (void) addMenuItems:(NSObject*)titleOrParamsDict;
- (void) addMenuSeperatorItem;
- (void) showMenu;

@end
