//
//  PluginManager.m
//  BitBar
//
//  Created by Mat Ryer on 11/12/13.
//  Copyright (c) 2013 Bit Bar. All rights reserved.
//

#import "PluginManager.h"
#import "Plugin.h"
#import "ExecutablePlugin.h"
#import "HTMLPlugin.h"
#import "Settings.h"
#import "LaunchAtLoginController.h"

@implementation PluginManager

- (id) initWithPluginPath:(NSString *)path {
  if (self = [super init]) {
    
    self.path = [path stringByStandardizingPath];
  
  }
  return self;
}

- (void) showSystemStatusItemWithMessage:(NSString*)message {
  
  [self.statusBar removeStatusItem:self.defaultStatusItem];
  
  // make default menu item
  self.defaultStatusItem = [self.statusBar statusItemWithLength:NSVariableStatusItemLength];
  [self.defaultStatusItem setTitle:[[NSProcessInfo processInfo] processName]];
  self.defaultStatusItem.menu = [[NSMenu alloc] init];
  [self.defaultStatusItem.menu setDelegate:self];
  
  if (message.length > 0) {
    NSMenuItem *messageMenuItem = [[NSMenuItem alloc] initWithTitle:message action:nil keyEquivalent:@""];
    [self.defaultStatusItem.menu addItem:messageMenuItem];
    [self.defaultStatusItem.menu addItem:[NSMenuItem separatorItem]];
  }

  [self addHelperItemsToMenu:self.defaultStatusItem.menu asSubMenu:NO];
  
}

- (void) addHelperItemsToMenu:(NSMenu*)menu asSubMenu:(BOOL)submenu {
  
  NSMenu *targetMenu;
  
  if (submenu) {
    
    NSMenu *moreMenu = [[NSMenu alloc] initWithTitle:@"Preferences"];
    NSMenuItem *moreItem = [[NSMenuItem alloc] initWithTitle:@"Preferences" action:nil keyEquivalent:@""];
    moreItem.submenu = moreMenu;
    [menu addItem:moreItem];
    targetMenu = moreMenu;

  } else {
    
    targetMenu = menu;

  }
  
  // add reset
  NSMenuItem *refreshMenuItem = [[NSMenuItem alloc] initWithTitle:@"Reset " action:@selector(reset) keyEquivalent:@"r"];
  [refreshMenuItem setTarget:self];
  [targetMenu addItem:refreshMenuItem];
  
  [targetMenu addItem:[NSMenuItem separatorItem]];
  
  // add edit action
  NSMenuItem *prefsMenuItem = [[NSMenuItem alloc] initWithTitle:@"Change Plugin Folder…" action:@selector(changePluginDirectory) keyEquivalent:@""];
  [prefsMenuItem setTarget:self];
  [targetMenu addItem:prefsMenuItem];
  
  // add edit action
  NSMenuItem *openPluginFolderMenuItem = [[NSMenuItem alloc] initWithTitle:@"Open Plugin Folder…" action:@selector(openPluginFolder) keyEquivalent:@""];
  [openPluginFolderMenuItem setTarget:self];
  [targetMenu addItem:openPluginFolderMenuItem];

  // add browser item
  NSMenuItem *openPluginBrowserMenuItem = [[NSMenuItem alloc] initWithTitle:@"Find More Plugins…" action:@selector(openPluginsBrowser) keyEquivalent:@""];
  [openPluginBrowserMenuItem setTarget:self];
  [targetMenu addItem:openPluginBrowserMenuItem];

  [targetMenu addItem:[NSMenuItem separatorItem]];
  
  // open at login
  LaunchAtLoginController *lc = [[LaunchAtLoginController alloc] init];
  NSMenuItem *openAtLoginMenuItem = [[NSMenuItem alloc] initWithTitle:@"Open at Login" action:@selector(toggleOpenAtLogin:) keyEquivalent:@""];
  [openAtLoginMenuItem setTarget:self];
  [openAtLoginMenuItem setState:lc.launchAtLogin];
  [targetMenu addItem:openAtLoginMenuItem];
  
  [targetMenu addItem:[NSMenuItem separatorItem]];
  
  NSString *versionString = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
  
  NSMenuItem *versionMenuitem = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"v%@", versionString] action:nil keyEquivalent:@""];
  [targetMenu addItem:versionMenuitem];
  
  // add troubleshooting item
  NSMenuItem *openHelpMenuItem = [[NSMenuItem alloc] initWithTitle:@"User Guide…" action:@selector(openTroubleshootingPage) keyEquivalent:@"g"];
  [openHelpMenuItem setTarget:self];
  [targetMenu addItem:openHelpMenuItem];
  
  // add troubleshooting item
  NSMenuItem *reportIssueMenuItem = [[NSMenuItem alloc] initWithTitle:@"Report an Issue…" action:@selector(openReportIssuesPage) keyEquivalent:@"i"];
  [reportIssueMenuItem setTarget:self];
  [targetMenu addItem:reportIssueMenuItem];
  
  // quit menu
  NSMenuItem *quitMenuItem = [[NSMenuItem alloc] initWithTitle:@"Quit" action:@selector(quit) keyEquivalent:@"q"];
  [quitMenuItem setTarget:self];
  [targetMenu addItem:quitMenuItem];
  
}

- (void) quit {
  [NSApp terminate:[NSApplication sharedApplication]];
}

- (void) openReportIssuesPage {
  [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/stretchr/bitbar/issues"]];
}

- (void) openPluginsBrowser {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/stretchr/bitbar/tree/master/Plugins"]];
}

- (void) openTroubleshootingPage {
  [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/stretchr/bitbar/wiki/User-Guide"]];
}

- (void) openPluginFolder {
  [[NSWorkspace sharedWorkspace] openURL:[NSURL fileURLWithPath:self.path]];
}

- (void) toggleOpenAtLogin:(id)sender {
  
  LaunchAtLoginController *lc = [[LaunchAtLoginController alloc] init];
  [lc setLaunchAtLogin:!lc.launchAtLogin];
  
  NSMenuItem *menuItem = (NSMenuItem*)sender;
  [menuItem setState:lc.launchAtLogin];
  
}

- (NSArray *) pluginFilesWithAsking:(BOOL)shouldAsk {
  
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
    } else {

      // filter the files
      NSArray *shFiles = [dirFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT self BEGINSWITH '.'"]];
          
      return shFiles;
    }
  }
  
  if (!dirIsOK && shouldAsk) {
    
    if ([self beginSelectingPluginsDir] == YES) {
      return [self pluginFilesWithAsking:NO];;
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

- (void)changePluginDirectory {
  if ([self beginSelectingPluginsDir] == YES) {
    [self reset];
  }
}

- (NSArray *)plugins {
  
  if (_plugins == nil) {
    
    NSArray *pluginFiles = [self pluginFilesWithAsking:YES];
    NSMutableArray *plugins = [[NSMutableArray alloc] initWithCapacity:[pluginFiles count]];
    NSString *file;
    for (file in pluginFiles) {
     
      // setup this plugin
      Plugin *plugin;
      if ([@[@"html",@"htm"] containsObject:[[file pathExtension] lowercaseString]]) {
        plugin = [[HTMLPlugin alloc] initWithManager:self];
      } else {
        plugin = [[ExecutablePlugin alloc] initWithManager:self];
      }
      
      [plugin setPath:[self.path stringByAppendingPathComponent:file]];
      [plugin setName:file];
      [plugin.statusItem setTitle:@"…"];
      
      [plugins addObject:plugin];
      
    }
    
    _plugins = [NSArray arrayWithArray:plugins];
  
  }
  
  return _plugins;
  
}

- (NSDictionary *)environment {
  
  if (_environment == nil) {
    
    NSDictionary *currentEnv = [[NSProcessInfo processInfo] environment];
    NSMutableDictionary *env = [[NSMutableDictionary alloc] initWithCapacity:[currentEnv count]+1];
    for (NSString *key in currentEnv.allKeys) {
      [env setObject:[currentEnv objectForKey:key] forKey:key];
    }
    [env setObject:[NSNumber numberWithBool:YES] forKey:@"BitBar"];
    _environment = env;
    
  }
  
  return _environment;
  
}

- (void) pluginDidUdpdateItself:(Plugin*)plugin {
  [self checkForNoPlugins];
}

- (void)checkForNoPlugins {
  
  Plugin *plugin;
  NSInteger visiblePlugins = 0;
  for (plugin in self.plugins) {
    if (plugin.pluginIsVisible)
      visiblePlugins++;
  }
  
  if (visiblePlugins == 0) {
    [self showSystemStatusItemWithMessage:@"No plugins found"];
  } else {
    [self.statusBar removeStatusItem:self.defaultStatusItem];
  }
  
}

- (NSStatusBar *)statusBar {
  
  if (_statusBar == nil) {
    _statusBar = [NSStatusBar systemStatusBar];
  }
  
  return _statusBar;
  
}

- (void) setupAllPlugins {
  
  Plugin *plugin;
  NSArray *plugins = self.plugins;
  
  if ([plugins count] == 0) {
    [self checkForNoPlugins];
  } else {
    
    for (plugin in plugins) {
      [plugin refresh];
    }
    
    [self.timerForLastUpdated invalidate];
    self.timerForLastUpdated = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(updatePluginLastUpdatedValues) userInfo:nil repeats:YES];
    
  }
  
}

- (void)updatePluginLastUpdatedValues {
  
  Plugin *plugin;
  for (plugin in self.plugins) {
    if (plugin.lastUpdated != nil) {
      [plugin.lastUpdatedMenuItem setTitle:[NSString stringWithFormat:@"Updated %@", plugin.lastUpdatedString]];
    } else {
      [plugin.lastUpdatedMenuItem setTitle:@"Refreshing…"];
    }
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
