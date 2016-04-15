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

@interface PluginManager () {
  LaunchAtLoginController *_launchAtLoginController;
}
@end

@implementation PluginManager

- initWithPluginPath:(NSString*)path {
  if (self = [super init]) {
    _path = [path stringByStandardizingPath];
    _launchAtLoginController = [[LaunchAtLoginController alloc] init];
    [self performSelectorInBackground:@selector(getLatestVersion) withObject:nil];
  }
  return self;
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
  NSMenuItem *moreItem = nil;
  
  if (submenu) {
    
    NSMenu *moreMenu = [NSMenu.alloc initWithTitle:@"Preferences"];

    moreItem = [NSMenuItem.alloc initWithTitle:@"Preferences" action:nil keyEquivalent:@""];
    moreItem.submenu = moreMenu;
    [menu addItem:moreItem];
    targetMenu = moreMenu;

  } else targetMenu = menu;
  
  // add reset, aka refreshMenuItem
  ADD_MENU(@"Refresh all", reset, @"r", self);

  [targetMenu addItem:NSMenuItem.separatorItem];
  
  if (!DEFS.userConfigDisabled) {
    // add edit action, aka prefsMenuItem
    ADD_MENU(@"Change Plugin Folder…", changePluginDirectory,@"",self);
    
    // add edit action, aka openPluginFolderMenuItem
    ADD_MENU(@"Open Plugin Folder…",openPluginFolder, nil, self);
    
    // add browser item, aka openPluginBrowserMenuItem
    ADD_MENU(@"Get Plugins…", openPluginsBrowser, nil, self);
    
    [targetMenu addItem:NSMenuItem.separatorItem];
    
    // open at login, aka openAtLoginMenuItem
    [ADD_MENU(@"Open at Login", toggleOpenAtLogin:, nil, self) setState:_launchAtLoginController.launchAtLogin];
    
    [targetMenu addItem:NSMenuItem.separatorItem];
  }
  
  NSString *versionString = [NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleShortVersionString"];
  
  NSMenuItem *versionMenuitem = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"v%@", versionString] action:nil keyEquivalent:@""];
  
  if (!self.latestVersion || [self.latestVersion isEqualToString:[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey]]) {
    [targetMenu addItem:versionMenuitem];
  } else {
    NSImage *cautionImage = [NSImage imageNamed:NSImageNameCaution];
    cautionImage.size = CGSizeMake(16, 16);
    
    NSMenuItem *latestVersionMenuItem = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"Download latest (v%@)", self.latestVersion]
                                                                   action:@selector(openLatestRelease)
                                                            keyEquivalent:@""];
    latestVersionMenuItem.target = self;
    latestVersionMenuItem.offStateImage = cautionImage;
    [targetMenu addItem:latestVersionMenuItem];
    
    moreItem.offStateImage = cautionImage;
    
    versionMenuitem.title = [@"Current: " stringByAppendingString:versionMenuitem.title];
    versionMenuitem.alternate = YES;
    versionMenuitem.keyEquivalentModifierMask = NSAlternateKeyMask;
    [targetMenu addItem:versionMenuitem];
  }

//
//  // add troubleshooting item
//  ADD_MENU(@"User Guide…", openTroubleshootingPage,@"g",self);
//
//  // add troubleshooting item
//  ADD_MENU(@"Report an Issue…",openHomepage,@"i",self);
//  
  // quit menu
  ADD_MENU(@"Quit",quit, @"q",self);
}

- (void) quit {
  [NSApp terminate:[NSApplication sharedApplication]];
}
#define WSPACE NSWorkspace.sharedWorkspace

- (void) openReportIssuesPage {
  [WSPACE openURL:[NSURL URLWithString:@"https://github.com/matryer/bitbar/issues"]];
}

- (void) openPluginsBrowser {
    [WSPACE openURL:[NSURL URLWithString:@"https://getbitbar.com/"]];
}

- (void) openHomepage {
  [WSPACE openURL:[NSURL URLWithString:@"https://github.com/matryer/bitbar"]];
}

- (void) openPluginFolder {
  [WSPACE openURL:[NSURL fileURLWithPath:self.path]];
}

- (void) toggleOpenAtLogin:(id)sender {
  [_launchAtLoginController setLaunchAtLogin:!_launchAtLoginController.launchAtLogin];
}

- (void)openLatestRelease {
  [WSPACE openURL:[NSURL URLWithString:@"https://github.com/matryer/bitbar/releases"]];
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
      // filter application executable
      // filter subdirectories
      dirFiles = [dirFiles filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id name, NSDictionary *bindings) {
        BOOL isDir;
        NSString * path = [self.path stringByAppendingPathComponent:name];
        return ![path isEqualToString:[NSBundle mainBundle].executablePath] && [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] && !isDir;
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
    
    if (!openDlg.URL.isFileURL) {
      // TODO: error popup
      return NO;
    }
    
    BOOL isDir = NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath: openDlg.URL.path isDirectory: &isDir]
        && isDir) {
      // symlink bundled plugins in selected directory
      self.path = [NSBundle mainBundle].executablePath.stringByDeletingLastPathComponent;
      NSArray *pluginFiles = [self pluginFilesWithAsking:NO];
      for (NSString *file in pluginFiles)
        [[NSFileManager defaultManager] createSymbolicLinkAtPath:[openDlg.URL.path stringByAppendingPathComponent:file]
                                             withDestinationPath:[self.path stringByAppendingPathComponent:file]
                                                           error:nil];
      
      self.path = [openDlg.URL path];
      [DEFS setPluginsDirectory:self.path];
      return YES;
      
    }

    // TODO: error popup
    return NO;
    
  } else self.path = DEFS.pluginsDirectory;
  
  return NO;
  
}

- (void) reset {
  
  [self performSelectorInBackground:@selector(getLatestVersion) withObject:nil];
  
  // remove all status items
  for (Plugin *plugin in _plugins) {
   [self.statusBar removeStatusItem:plugin.statusItem];
   [plugin close];
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
      
    // Determine if Mac is in Dark Mode
    NSString *osxMode = [[NSUserDefaults standardUserDefaults] stringForKey:@"AppleInterfaceStyle"];
    if ([osxMode isEqualToString:@"Dark"]) {
        env[@"BitBarDarkMode"] = @YES;
    }
      
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

  }
}

- (void)getLatestVersion {
  if (DEFS.userConfigDisabled) {
    return;
  }
  
  // only refresh hourly
  if (self.lastVersionUpdate && self.lastVersionUpdate.timeIntervalSinceNow > -60 * 60) {
    return;
  }
  self.lastVersionUpdate = [NSDate date];
  
  NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://api.github.com/repos/matryer/bitbar/releases"]];
  if (data) {
    NSArray *releases = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSDictionary *latest = nil;
    
    for (NSDictionary *release in releases) {
      if ([release[@"prerelease"] isEqual:@YES]) {
        latest = release;
        break;
      }
    }
    
    if (latest[@"tag_name"]) {
      self.latestVersion = latest[@"tag_name"];
      if ([self.latestVersion hasPrefix:@"v"]) {
        self.latestVersion = [self.latestVersion substringFromIndex:1];
      }
    }
  }
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
  if ([menuItem action] == @selector(toggleOpenAtLogin:)) {
    [menuItem setState:_launchAtLoginController.launchAtLogin ? NSOnState : NSOffState];
  }

  return YES;
}

- (void)saveScreenshot:(NSString *)pluginPath destination:(NSString *)dst margin:(CGFloat)margin {
  for (Plugin *plugin in _plugins) {
    [plugin close];
    [self.statusBar removeStatusItem:plugin.statusItem];
  }
  
  Plugin *plugin;
  
  if ([@[@"html", @"htm"] containsObject:pluginPath.pathExtension.lowercaseString])
    plugin = [[HTMLPlugin alloc] initWithManager:self];
  else
    plugin = [[ExecutablePlugin alloc] initWithManager:self];
  
  plugin.path = pluginPath;
  plugin.statusItem.title = @"…";
  
  _plugins = @[plugin];
  
  // TODO: execute plugin in demo mode with arguments: <bitbar.demo>--demo</bitbar.demo>
  
  if ([plugin respondsToSelector:@selector(refreshContentByExecutingCommand)]) {
    [(ExecutablePlugin *)plugin refreshContentByExecutingCommand];
    
    plugin.lastUpdated = NSDate.new;
    
    [plugin rebuildMenuForStatusItem:plugin.statusItem];
    
    // reset the current line
    plugin.currentLine = -1;
    
    // update the status item
    [plugin cycleLines];
    
    // tell the manager this plugin has updated
    [self pluginDidUdpdateItself:plugin];
  }
  
  dispatch_async(dispatch_get_main_queue(), ^{
    NSRect screenFrame = [plugin.statusItem.button.window convertRectToScreen:plugin.statusItem.button.frame];
    screenFrame.origin.y = 0;
    screenFrame.size.width = MAX(plugin.statusItem.menu.size.width, screenFrame.size.width);
    screenFrame.size.height += plugin.statusItem.menu.size.height;
    
    if (NSMaxX(screenFrame) > CGDisplayPixelsWide(kCGDirectMainDisplay))
      screenFrame.origin.x -= screenFrame.size.width - plugin.statusItem.button.frame.size.width;
    
    if (margin)
      screenFrame = NSInsetRect(screenFrame, -margin, -margin);
    
    CGImageRef image = CGDisplayCreateImageForRect(kCGDirectMainDisplay, screenFrame);
    NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithCGImage:image];
    NSData *pngData = [rep representationUsingType:NSPNGFileType properties:@{}];
    [pngData writeToFile:dst atomically:YES];
    
    if (image)
      CGImageRelease(image);
    
    [plugin.statusItem.menu cancelTrackingWithoutAnimation];
    [self reset];
  });
  
  if (plugin.statusItem.menu)
    [plugin.statusItem.button performClick:nil];
}

#pragma mark - NSMenuDelegate

- (void)menuWillOpen:(NSMenu *)menu {
  [self.defaultStatusItem setHighlightMode:YES];
}

- (void)menuDidClose:(NSMenu *)menu {
  [self.defaultStatusItem setHighlightMode:NO];
}

@end
