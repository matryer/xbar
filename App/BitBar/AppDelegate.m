//
//  AppDelegate.m
//  BitBar
//
//  Created by Mat Ryer on 11/12/13.
//  Copyright (c) 2013 Bit Bar. All rights reserved.
//

#import "NSUserDefaults+Settings.h"
#import "LaunchAtLoginController.h"
#import "PluginManager.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property PluginManager *pluginManager;

@end

@implementation AppDelegate

- (NSArray*) otherCopies { return [NSRunningApplication runningApplicationsWithBundleIdentifier:NSBundle.mainBundle.bundleIdentifier]; }

- (void)applicationWillFinishLaunching:(NSNotification *)n {

  if (self.otherCopies.count <= 1) return;
  NSModalResponse runm = [[NSAlert alertWithMessageText:[NSString stringWithFormat:@"Another copy of %@ is already running.", NSBundle.mainBundle.infoDictionary[(NSString *)kCFBundleNameKey]]
                   defaultButton:@"Quit" alternateButton:@"Kill others" otherButton:nil informativeTextWithFormat:@"Quit, or kill the other copy(ies)?"] runModal];

  runm == 1 ? [NSApp terminate:nil] : ({

  for ( NSRunningApplication *app in self.otherCopies)
    if (app.processIdentifier != NSProcessInfo.processInfo.processIdentifier)
      [app terminate];

  });
}

- (void) applicationDidFinishLaunching:(NSNotification*)n {

  // enable usage of Safari's WebInspector to debug HTML Plugins
  [NSUserDefaults.standardUserDefaults setBool:YES forKey:@"WebKitDeveloperExtras"];

  if (DEFS.isFirstTimeAppRun) {
    LaunchAtLoginController *launcher = LaunchAtLoginController.new;
    if (!launcher.launchAtLogin) [launcher setLaunchAtLogin:YES];
    DEFS.isFirstTimeAppRun = NO;
  }
  
  // make a plugin manager
  [_pluginManager = [PluginManager.alloc initWithPluginPath:DEFS.pluginsDirectory]
                                                                  setupAllPlugins];
}

@end

int main(int argc, const char * argv[]) { return NSApplicationMain(argc, argv); }
