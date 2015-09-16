//
//  AppDelegate.m
//  BitBar
//
//  Created by Mat Ryer on 11/12/13.
//  Copyright (c) 2013 Bit Bar. All rights reserved.
//

#import "PluginManager.h"
#import "Settings.h"
#import "LaunchAtLoginController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property PluginManager *pluginManager;

@end

@implementation AppDelegate


- (void) startApp {
  
  if (DEFS.isFirstTimeAppRun) {
    LaunchAtLoginController *launcher = LaunchAtLoginController.new;
    if (!launcher.launchAtLogin) [launcher setLaunchAtLogin:YES];
  }
  
  // make a plugin manager
  [_pluginManager = [PluginManager.alloc initWithPluginPath:DEFS.pluginsDirectory]
                                                                  setupAllPlugins];
}

- (NSArray*) otherCopies { return [NSRunningApplication runningApplicationsWithBundleIdentifier:NSBundle.mainBundle.bundleIdentifier]; }

- (void) deduplicateRunningInstances {

  if (self.otherCopies.count <= 1) return;
  NSModalResponse runm = [[NSAlert alertWithMessageText:[NSString stringWithFormat:@"Another copy of %@ is already running.", NSBundle.mainBundle.infoDictionary[(NSString *)kCFBundleNameKey]]
                   defaultButton:@"Quit" alternateButton:@"Kill others" otherButton:nil informativeTextWithFormat:@"Quit, or kill the other copy(ies)?"] runModal];

  runm == 1 ? [NSApp terminate:nil] : ({

  for ( NSRunningApplication *app in self.otherCopies)
    if (app.processIdentifier != NSProcessInfo.processInfo.processIdentifier)
      [app terminate];

  });
}


- (void)applicationWillFinishLaunching:(NSNotification *)n {

  [self deduplicateRunningInstances];

}

- (void)applicationDidFinishLaunching:(NSNotification *)n {

  // enable usage of Safari's WebInspector to debug HTML Plugins
  [NSUserDefaults.standardUserDefaults setBool:YES forKey:@"WebKitDeveloperExtras"];
  [self startApp];
}

@end

int main(int argc, const char * argv[]) { return NSApplicationMain(argc, argv); }
