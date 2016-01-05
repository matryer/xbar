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
#import "NSUserDefaults+Settings.h"
#import "LaunchAtLoginController.h"

@implementation PluginManager

- initWithPluginPath:(NSString*)path {

  return self = super.init ? _path = path.stringByStandardizingPath, self : nil;
}

- (void) showSystemStatusItemWithMessage:(NSString*)message {
  
  [self.statusBar removeStatusItem:self.defaultStatusItem];
  
  // make default menu item
  self.defaultStatusItem = [self.statusBar statusItemWithLength:NSVariableStatusItemLength];
  [self.defaultStatusItem setTitle:NSProcessInfo.processInfo.processName];
  [(self.defaultStatusItem.menu = NSMenu.new) setDelegate:self];
  
  if (message.length) {
    NSMenuItem *messageMenuItem = [NSMenuItem.alloc initWithTitle:message action:nil keyEquivalent:@""];
    [self.defaultStatusItem.menu addItem:messageMenuItem];
    [self.defaultStatusItem.menu addItem:NSMenuItem.separatorItem];
  }

  [self addHelperItemsToMenu:self.defaultStatusItem.menu asSubMenu:NO];
  
}

#define ADD_MENU(TITLE,SELECTOR,SHORTCUT,TARGET) ({ \
  NSMenuItem *item = [NSMenuItem.alloc initWithTitle:TITLE action:NSStringFromSelector(@selector(SELECTOR)) ? @selector(SELECTOR) : NULL keyEquivalent:SHORTCUT?:@""];\
  if (TARGET) [item setTarget:TARGET]; \
  [targetMenu addItem:item]; item; })


- (void) addHelperItemsToMenu:(NSMenu*)menu asSubMenu:(BOOL)submenu {
  
  NSMenu *targetMenu;
  
  if (submenu) {
    
    NSMenu *moreMenu = [NSMenu.alloc initWithTitle:@"Preferences"];

    NSMenuItem *moreItem = [NSMenuItem.alloc initWithTitle:@"Preferences" action:nil keyEquivalent:@""];
    moreItem.submenu = moreMenu;
    [menu addItem:moreItem];
    targetMenu = moreMenu;

  } else targetMenu = menu;
  
  // add reset, aka refreshMenuItem
  ADD_MENU(@"Reset ", reset, @"r", self);

  [targetMenu addItem:NSMenuItem.separatorItem];
  
  // add edit action, aka prefsMenuItem
  ADD_MENU(@"Change Plugin Folder…", changePluginDirectory,@"",self);
  
  // add edit action, aka openPluginFolderMenuItem
  ADD_MENU(@"Open Plugin Folder…",openPluginFolder, nil, self);

  // add browser item, aka openPluginBrowserMenuItem
  ADD_MENU(@"Find More Plugins…", openPluginsBrowser, nil, self);

  [targetMenu addItem:NSMenuItem.separatorItem];
  
  // open at login, aka openAtLoginMenuItem
  LaunchAtLoginController *lc = LaunchAtLoginController.new;

  [ADD_MENU(@"Open at Login", toggleOpenAtLogin:, nil, self) setState:lc.launchAtLogin];
  
  [targetMenu addItem:NSMenuItem.separatorItem];
  
  NSString *versionString = [NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleVersion"];
  
  NSMenuItem *versionMenuitem = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"v%@", versionString] action:nil keyEquivalent:@""];
  [targetMenu addItem:versionMenuitem];

  // add troubleshooting item
  ADD_MENU(@"User Guide…", openTroubleshootingPage,@"g",self);
  
  // add troubleshooting item
  ADD_MENU(@"Report an Issue…",openReportIssuesPage,@"i",self);
  
  // quit menu
  ADD_MENU(@"Quit",quit, @"q",self);
}

- (void) quit {
  [NSApp terminate:[NSApplication sharedApplication]];
}
#define WSPACE NSWorkspace.sharedWorkspace

- (void) openReportIssuesPage {
  [WSPACE openURL:[NSURL URLWithString:@"https://github.com/stretchr/bitbar/issues"]];
}

- (void) openPluginsBrowser {
    [WSPACE openURL:[NSURL URLWithString:@"https://github.com/stretchr/bitbar/tree/master/Plugins"]];
}

- (void) openTroubleshootingPage {
  [WSPACE openURL:[NSURL URLWithString:@"https://github.com/stretchr/bitbar/wiki/User-Guide"]];
}

- (void) openPluginFolder {
  [WSPACE openURL:[NSURL fileURLWithPath:self.path]];
}

- (void) toggleOpenAtLogin:(id)sender {
  
  LaunchAtLoginController *lc = LaunchAtLoginController.new;
  [lc setLaunchAtLogin:!lc.launchAtLogin];

  [(NSMenuItem*)sender setState:lc.launchAtLogin];
  
}

- (NSArray*) pluginFilesWithAsking:(BOOL)shouldAsk {
  
  BOOL dirIsOK = !!self.path;
  
  if (dirIsOK) {
    
    BOOL isDir;
    if (![NSFileManager.defaultManager fileExistsAtPath:self.path isDirectory:&isDir])
      dirIsOK = NO;
    
    if (!isDir) dirIsOK = NO;
  }
  
  if (dirIsOK) {
    
    // get the listing
    NSError *error;
    NSArray *dirFiles = [NSFileManager.defaultManager contentsOfDirectoryAtPath:self.path error:&error];
    
    // handle error if there is one
    if (error != nil) {
      dirIsOK = NO;
    } else {
      // filter dot files
      dirFiles = [dirFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT self BEGINSWITH '.'"]];
      // filter markdown files
      dirFiles = [dirFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT self ENDSWITH '.md'"]];
      // filter subdirectories
      dirFiles = [dirFiles filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id name, NSDictionary *bindings) {
        BOOL isDir;
        NSString * path = [self.path stringByAppendingPathComponent:name];
        return [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] && !isDir;
      }]];
      return dirFiles;
    }
  }
  
  return (!dirIsOK && shouldAsk) && self.beginSelectingPluginsDir ? [self pluginFilesWithAsking:NO] : nil;
}

- (BOOL) beginSelectingPluginsDir {
  
  NSOpenPanel* openDlg = [NSOpenPanel openPanel];
  [openDlg setCanChooseDirectories:YES];
  [openDlg setCanChooseFiles:NO];
  [openDlg setCanCreateDirectories:YES];
  [openDlg setPrompt:@"Use as Plugins Directory"];
  [openDlg setTitle:@"Select BitBar Plugins Directory"];
  
  if (openDlg.runModal == NSOKButton) {
    
    self.path = [openDlg.directoryURL path];
    [DEFS setPluginsDirectory:self.path];
    return YES;
    
  } else self.path = DEFS.pluginsDirectory;
  
  return NO;
  
}

- (void) reset {
  
  // remove all status items
  Plugin *plugin;
  for (plugin in _plugins) [self.statusBar removeStatusItem:plugin.statusItem];
  
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
  
  return _plugins = _plugins ?: ({
    
    NSArray *pluginFiles = [self pluginFilesWithAsking:YES];
    NSMutableArray *plugins = [NSMutableArray.alloc initWithCapacity:[pluginFiles count]];
    NSString *file;
    for (file in pluginFiles) {
     
      // setup this plugin
      Plugin *plugin;
      if ([@[@"html",@"htm"] containsObject:file.pathExtension.lowercaseString]) {
        plugin = [HTMLPlugin.alloc initWithManager:self];
      } else {
        plugin = [ExecutablePlugin.alloc initWithManager:self];
      }
      
      if ([[file substringToIndex:4] isEqualToString:@"off."]) {
        continue;
      }
      
      [plugin setPath:[self.path stringByAppendingPathComponent:file]];
      [plugin setName:file];
      [plugin.statusItem setTitle:@"…"];
      
      [plugins addObject:plugin];
      
    }
    
    plugins.copy;

  });
}

- (NSDictionary *)environment {
  
  return _environment = _environment ?: ({

    NSMutableDictionary *env = NSProcessInfo.processInfo.environment.mutableCopy;
    env[@"BitBar"] = @YES;
    env;
  });
  
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
  
  visiblePlugins != 0 ? [self.statusBar removeStatusItem:self.defaultStatusItem]
                      : [self showSystemStatusItemWithMessage:@"No plugins found"];
}

- (NSStatusBar *)statusBar { return _statusBar = _statusBar ?: NSStatusBar.systemStatusBar; }


- (void) setupAllPlugins {

  NSArray *plugins = self.plugins;
  
  if (!plugins.count)  [self checkForNoPlugins];

  else {
    
    for (Plugin *plugin in plugins) [plugin refresh];

    [_timerForLastUpdated invalidate];
    self.timerForLastUpdated = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(updatePluginLastUpdatedValues) userInfo:nil repeats:YES];
    
  }
}

- (void)updatePluginLastUpdatedValues {

  for (Plugin *plugin in self.plugins)
    plugin.lastUpdated  ? [plugin.lastUpdatedMenuItem setTitle:[NSString stringWithFormat:@"Updated %@", plugin.lastUpdatedString]]
                        : [plugin.lastUpdatedMenuItem setTitle:@"Refreshing…"];
}

#pragma mark - NSMenuDelegate

- (void)menuWillOpen:(NSMenu *)menu {
  [self.defaultStatusItem setHighlightMode:YES];
}

- (void)menuDidClose:(NSMenu *)menu {
  [self.defaultStatusItem setHighlightMode:NO];
}

@end
