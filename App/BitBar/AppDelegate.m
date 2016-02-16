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
#import <sys/stat.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, NSURLDownloadDelegate>

@property (assign) IBOutlet NSWindow *window;

@property PluginManager *pluginManager;

// plugin download
@property NSURLDownload *download;
@property NSString *destinationPath;
@property NSString *suggestedDestinationPath;

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
  [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self
                                                         selector: @selector(receiveWakeNote:)
                                                             name: NSWorkspaceDidWakeNotification object: NULL];

  if (DEFS.isFirstTimeAppRun) {
    LaunchAtLoginController *launcher = LaunchAtLoginController.new;
    if (!launcher.launchAtLogin) [launcher setLaunchAtLogin:YES];
    DEFS.isFirstTimeAppRun = NO;
  }
  
  // make a plugin manager
  [_pluginManager = [PluginManager.alloc initWithPluginPath:DEFS.pluginsDirectory]
                                                                  setupAllPlugins];
  
  // register custom url scheme handler
  [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self
                                                     andSelector:@selector(handleGetURLEvent:withReplyEvent:)
                                                   forEventClass:kInternetEventClass
                                                      andEventID:kAEGetURL];
}

- (void) receiveWakeNote: (NSNotification*) note
{
  [[self pluginManager] reset];
}

- (void)handleGetURLEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent {
  // check if plugins directory is set
  if (!DEFS.pluginsDirectory)
    return;
  
  // extract the url from the event and handle it
  
  NSString *URLString = [event paramDescriptorForKeyword:keyDirectObject].stringValue;
  URLString = [URLString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  NSString *prefix = @"bitbar://openPlugin?";
  
  // skip urls that don't begin with our prefix
  if (![URLString hasPrefix:prefix])
    return;
  
  URLString = [URLString substringFromIndex:prefix.length];
  prefix = @"title=";
  
  NSString *title = nil;
  
  if ([URLString hasPrefix:prefix]) {
    URLString = [URLString substringFromIndex:prefix.length];
    NSArray *components = [URLString componentsSeparatedByString:@"&"];
    
    if (components.count < 2)
      return;
      
    title = components.firstObject;
    URLString = [[components subarrayWithRange:NSMakeRange(1, components.count - 1)] componentsJoinedByString:@"&"];
  }
  
  prefix = @"src=";
  
  if (![URLString hasPrefix:prefix])
    return;
  
  URLString = [URLString substringFromIndex:prefix.length];
  
  BOOL trusted = NO;
  
  // if the plugin is at our repository, only display the filename
  if ([URLString hasPrefix:@"https://github.com/matryer/bitbar-plugins/raw/master/"]) {
    trusted = YES;
  }
  
  NSAlert *alert = [[NSAlert alloc] init];
  [alert addButtonWithTitle:@"Install"];
  [alert addButtonWithTitle:@"Cancel"];
  alert.messageText = [NSString stringWithFormat:@"Download and install the plugin %@?", trusted ? (title.length > 0 ? title : URLString.lastPathComponent) : [NSString stringWithFormat:@"at %@", URLString]];

    if (trusted) {
        alert.informativeText = @"Only install plugins from trusted sources.";
    } else {
        alert.informativeText = @"CAUTION: This plugin is not from the official BitBar repository. We recommend that you only install plugins from trusted sources.";
    }

  if ([alert runModal] != NSAlertFirstButtonReturn) {
    // cancel clicked
    return;
  }
  
  [self.download cancel];
  self.destinationPath = nil;
  self.suggestedDestinationPath = nil;
  
  // NSURLSession is not available below 10.9 :(
  self.download = [[NSURLDownload alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:URLString]] delegate:self];
}

#pragma mark - NSURLDownload delegate

- (void)download:(NSURLDownload *)download decideDestinationWithSuggestedFilename:(NSString *)filename {
  self.suggestedDestinationPath = [DEFS.pluginsDirectory stringByAppendingPathComponent:filename];
  [download setDestination:self.suggestedDestinationPath allowOverwrite:NO];
}

- (void)download:(NSURLDownload *)download didCreateDestination:(NSString *)path {
  self.destinationPath = path;
}

- (void)downloadDidFinish:(NSURLDownload *)download {
  if (self.destinationPath) {
    if (self.suggestedDestinationPath && ![self.suggestedDestinationPath isEqualToString:self.destinationPath]) {
      // overwrite file at suggested destination path
      
      [[NSFileManager defaultManager] removeItemAtPath:self.suggestedDestinationPath error:nil];
      
      if ([[NSFileManager defaultManager] moveItemAtPath:self.destinationPath toPath:self.suggestedDestinationPath error:nil])
        self.destinationPath = self.suggestedDestinationPath;
    }
    
    // ensure plugin is executable
    
    // `chmod +x plugin.sh`
    struct stat st;
    stat(self.destinationPath.UTF8String, &st);
    chmod(self.destinationPath.UTF8String, (st.st_mode & ALLPERMS) | S_IXUSR | S_IXGRP | S_IXOTH);
  }
  
  // refresh
  [self.pluginManager reset];

  self.download = nil;
  self.destinationPath = nil;
  self.suggestedDestinationPath = nil;
}

- (void)download:(NSURLDownload *)download didFailWithError:(NSError *)error {
  NSAlert *alert = [[NSAlert alloc] init];
  [alert addButtonWithTitle:@"OK"];
  alert.messageText = @"Download failed";
  alert.informativeText = error.localizedDescription;
  [alert runModal];
  
  self.download = nil;
  self.destinationPath = nil;
  self.suggestedDestinationPath = nil;
}

@end

int main(int argc, const char * argv[]) { return NSApplicationMain(argc, argv); }
