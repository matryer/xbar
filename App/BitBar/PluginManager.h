//
//  PluginManager.h
//  BitBar
//
//  Created by Mat Ryer on 11/12/13.
//  Copyright (c) 2013 Bit Bar. All rights reserved.
//

@class Plugin;

@interface PluginManager : NSObject <NSMenuDelegate>

@property (nonatomic, copy) NSString *path;
@property (nonatomic)        NSArray *plugins;
@property (nonatomic)    NSStatusBar *statusBar;
@property (nonatomic)   NSStatusItem *defaultStatusItem;
@property (nonatomic)        NSTimer *timerForLastUpdated;
@property (nonatomic)   NSDictionary *environment;

- initWithPluginPath:(NSString *)path;

- (NSArray*) pluginFilesWithAsking:(BOOL)shouldAsk;

- (void) reset;
- (void) setupAllPlugins;
- (void) clearPathAndReset;
- (void) showSystemStatusItemWithMessage:(NSString*)message;
- (void) addHelperItemsToMenu:(NSMenu*)menu asSubMenu:(BOOL)submenu;

- (void) pluginDidUdpdateItself:(Plugin*)plugin;

@end
