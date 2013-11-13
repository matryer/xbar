//
//  PluginManager.m
//  BitBar
//
//  Created by Mat Ryer on 11/12/13.
//  Copyright (c) 2013 Bit Bar. All rights reserved.
//

#import "PluginManager.h"
#import "Plugin.h"
#import "Settings.h"
#import "LaunchAtLoginController.h"

@implementation PluginManager

- (id) initWithPluginPath:(NSString *)path {
  if (self = [super init]) {
    
    self.path = [path stringByStandardizingPath];
  
    
  }
  return self;
}

- (void) showSystemStatusItem {
  
  [self.statusBar removeStatusItem:self.defaultStatusItem];
  
  // make default menu item
  self.defaultStatusItem = [self.statusBar statusItemWithLength:NSVariableStatusItemLength];
  [self.defaultStatusItem setTitle:[[NSProcessInfo processInfo] processName]];
  self.defaultStatusItem.menu = [[NSMenu alloc] init];
  [self.defaultStatusItem.menu setDelegate:self];

  [self addHelperItemsToMenu:self.defaultStatusItem.menu];
  
}

- (void) addHelperItemsToMenu:(NSMenu*)menu {
  
  NSMenu *targetMenu;
  
  if (menu.itemArray.count > 0) {
    
    NSMenu *moreMenu = [[NSMenu alloc] initWithTitle:@"Settings"];
    NSMenuItem *moreItem = [[NSMenuItem alloc] initWithTitle:@"Settings" action:nil keyEquivalent:@""];
    moreItem.submenu = moreMenu;
    [menu addItem:moreItem];
    targetMenu = moreMenu;

  } else {
    
    targetMenu = menu;

  }
  
  // add edit action
  NSMenuItem *prefsMenuItem = [[NSMenuItem alloc] initWithTitle:@"Change plugin directory…" action:@selector(clearPathAndReset) keyEquivalent:@""];
  [prefsMenuItem setTarget:self];
  [targetMenu addItem:prefsMenuItem];
  
  // add reset
  NSMenuItem *refreshMenuItem = [[NSMenuItem alloc] initWithTitle:@"Refresh" action:@selector(reset) keyEquivalent:@""];
  [refreshMenuItem setTarget:self];
  [targetMenu addItem:refreshMenuItem];
  
  [targetMenu addItem:[NSMenuItem separatorItem]];
  
  // open at login
  LaunchAtLoginController *lc = [[LaunchAtLoginController alloc] init];
  NSMenuItem *openAtLoginMenuItem = [[NSMenuItem alloc] initWithTitle:@"Open at login" action:@selector(toggleOpenAtLogin:) keyEquivalent:@""];
  [openAtLoginMenuItem setTarget:self];
  [openAtLoginMenuItem setState:lc.launchAtLogin];
  [targetMenu addItem:openAtLoginMenuItem];
  
}

- (void) toggleOpenAtLogin:(id)sender {
  
  LaunchAtLoginController *lc = [[LaunchAtLoginController alloc] init];
  [lc setLaunchAtLogin:!lc.launchAtLogin];
  [self reset];
  
}

- (NSArray *) pluginFiles {
  
  BOOL dirIsOK = YES;
  
  if (self.path == nil) {
    dirIsOK = NO;
  }
  
  if (dirIsOK) {
    
    BOOL isDir;
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.path isDirectory:&isDir]) {
      dirIsOK = NO;
    }
    
    if (!isDir) {
      dirIsOK = NO;
    }
    
  }
  
  if (dirIsOK) {
    
    // get the listing
    NSError *error;
    NSArray *dirFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.path error:&error];
    
    // handle error if there is one
    if (error != nil) {
      dirIsOK = NO;
    }

    // filter the files
    NSArray *shFiles = [dirFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT self BEGINSWITH '.'"]];
    return shFiles;
  
  }
  
  if (!dirIsOK) {
    
    if ([self beginSelectingPluginsDir] == YES) {
      return nil;
    }
    
  }
  
  return nil;
  
}

- (BOOL) beginSelectingPluginsDir {
  
  NSOpenPanel* openDlg = [NSOpenPanel openPanel];
  [openDlg setCanChooseDirectories:YES];
  [openDlg setCanChooseFiles:NO];
  [openDlg setCanCreateDirectories:YES];
  [openDlg setPrompt:@"Use as Plugins Directory"];
  [openDlg setTitle:@"Select BitBar Plugins Directory"];
  
  if ([openDlg runModal] == NSOKButton) {
    
    self.path = [openDlg.directoryURL path];
    [Settings setPluginsDirectory:self.path];
    return YES;
    
  } else {
    
    self.path = [Settings pluginsDirectory];
    
  }
  
  return NO;
  
}

- (void) reset {
  
  // remove all status items
  Plugin *plugin;
  for (plugin in _plugins) {
    [self.statusBar removeStatusItem:plugin.statusItem];
  }
  
  _plugins = nil;
  [self.statusBar removeStatusItem:self.defaultStatusItem];
  [self setupAllPlugins];
  
}

- (void) clearPathAndReset {
  self.path = nil;
  [self reset];
}

- (NSArray *)plugins {
  
  if (_plugins == nil) {
    
    NSArray *pluginFiles = self.pluginFiles;
    NSMutableArray *plugins = [[NSMutableArray alloc] initWithCapacity:[pluginFiles count]];
    NSString *file;
    for (file in self.pluginFiles) {
     
      // setup this plugin
      Plugin *plugin = [[Plugin alloc] initWithManager:self];
      
      [plugin setPath:[self.path stringByAppendingPathComponent:file]];
      [plugin setName:file];
      
      [plugins addObject:plugin];
      
    }
    
    _plugins = [NSArray arrayWithArray:plugins];
  
  }
  
  return _plugins;
  
}

- (NSStatusBar *)statusBar {
  
  if (_statusBar == nil) {
    _statusBar = [NSStatusBar systemStatusBar];
  }
  
  return _statusBar;
  
}

- (void) setupAllPlugins {
  
  NSInteger visiblePlugins = 0;
  Plugin *plugin;
  for (plugin in self.plugins) {
    
    [plugin refresh];
    if (plugin.pluginIsVisible) {
      visiblePlugins++;
    }
    
  }
  
  if (visiblePlugins == 0) {
    [self showSystemStatusItem];
  }
  
}

#pragma mark - NSMenuDelegate

- (void)menuWillOpen:(NSMenu *)menu {
  [self.defaultStatusItem setHighlightMode:YES];
}

- (void)menuDidClose:(NSMenu *)menu {
  [self.defaultStatusItem setHighlightMode:NO];
}

@end
