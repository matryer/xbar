//
//  Plugin.h
//  BitBar
//
//  Created by Mat Ryer on 11/12/13.
//  Copyright (c) 2013 Bit Bar. All rights reserved.
//

@import AppKit;
@class PluginManager;

@interface Plugin : NSObject <NSMenuDelegate, NSWindowDelegate>

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
@property (nonatomic)   NSDictionary *metadata;
@property (weak, readonly)   PluginManager *manager;

// UI
@property (nonatomic) NSStatusItem *statusItem;

- initWithManager:(PluginManager*)manager;
- (void) close;

- (NSMenuItem*) buildMenuItemForLine:(NSString *)line;
- (NSMenuItem*) buildMenuItemWithParams:(NSDictionary *)params;
- (NSDictionary *)dictionaryForLine:(NSString *)line;
- (void) rebuildMenuForStatusItem:(NSStatusItem*)statusItem;
- (void) addAdditionalMenuItems:(NSMenu *)menu;
- (void) addDefaultMenuItems:(NSMenu *)menu;

- (void)performRefreshNow;
- (BOOL) refresh;
- (void) cycleLines;
- (void) contentHasChanged;

// actions
- (void)changePluginsDirectorySelected:(id)sender;


@end
