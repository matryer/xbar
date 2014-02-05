//
//  Plugin.h
//  BitBar
//
//  Created by Mat Ryer on 11/12/13.
//  Copyright (c) 2013 Bit Bar. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PluginManager;

@interface Plugin : NSObject <NSMenuDelegate>

@property (nonatomic, copy) NSString *path;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *allContent;
@property (nonatomic, assign) NSInteger currentLine;
@property (nonatomic, strong) NSArray *allContentLines;
@property (nonatomic, strong) NSArray *allContentLinesAfterBreak;
@property (nonatomic, copy) NSString *errorContent;
@property (nonatomic, assign) BOOL lastCommandWasError;
@property (nonatomic, strong) NSNumber *refreshIntervalSeconds;
@property (readonly, nonatomic, strong) PluginManager* manager;
@property (nonatomic, assign) NSInteger cycleLinesIntervalSeconds;
@property (nonatomic, assign) BOOL pluginIsVisible;
@property (nonatomic, strong) NSMenuItem *lastUpdatedMenuItem;
@property (nonatomic, strong) NSDate *lastUpdated;

@property (nonatomic, assign) BOOL menuIsOpen;

// UI
@property (nonatomic, strong) NSStatusItem *statusItem;

- (id) initWithManager:(PluginManager*)manager;
- (BOOL) isMultiline;

- (NSMenuItem *) buildMenuItemWithParams:(NSDictionary *)params;
- (void) rebuildMenuForStatusItem:(NSStatusItem*)statusItem;
- (void) addAdditionalMenuItems:(NSMenu *)menu;
- (void) addDefaultMenuItems:(NSMenu *)menu;

- (BOOL) refresh;
- (void) cycleLines;
- (void) contentHasChanged;

- (NSString *)lastUpdatedString;

// actions
- (void)changePluginsDirectorySelected:(id)sender;

@end
