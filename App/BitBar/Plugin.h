//
//  Plugin.h
//  BitBar
//
//  Created by Mat Ryer on 11/12/13.
//  Copyright (c) 2013 Bit Bar. All rights reserved.
//

@import AppKit;
@class PluginManager;

@interface Plugin : NSObject <NSMenuDelegate>

@property (nonatomic)      NSInteger currentLine, cycleLinesIntervalSeconds;
@property (nonatomic)           BOOL lastCommandWasError, pluginIsVisible, menuIsOpen;
@property (readonly)            BOOL isMultiline;
@property (readonly)        NSString *lastUpdatedString;
@property (nonatomic, copy) NSString *path, *name, *content, *allContent, *errorContent;
@property (nonatomic)        NSArray *allContentLines;
@property (nonatomic)        NSArray *titleLines;
@property (nonatomic)       NSNumber *refreshIntervalSeconds;
@property (nonatomic)     NSMenuItem *lastUpdatedMenuItem;
@property (nonatomic)         NSDate *lastUpdated;
@property (readonly)   PluginManager *manager;

// UI
@property (nonatomic) NSStatusItem *statusItem;

- initWithManager:(PluginManager*)manager;


- (NSMenuItem*) buildMenuItemWithParams:(NSDictionary *)params;
- (void) rebuildMenuForStatusItem:(NSStatusItem*)statusItem;
- (void) addAdditionalMenuItems:(NSMenu *)menu;
- (void) addDefaultMenuItems:(NSMenu *)menu;

- (void)performRefreshNow:(NSMenuItem *)menuItem;
- (BOOL) refresh;
- (void) cycleLines;
- (void) contentHasChanged;
- (BOOL) isFontValid:(NSString *)fontName;

// actions
- (void)changePluginsDirectorySelected:(id)sender;

@end
