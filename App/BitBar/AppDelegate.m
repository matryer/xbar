//
//  AppDelegate.m
//  BitBar
//
//  Created by Mat Ryer on 11/12/13.
//  Copyright (c) 2013 Bit Bar. All rights reserved.
//

#import "AppDelegate.h"
#import "BitBarController.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  // enable usage of Safari's WebInspector to debug HTML Plugins
  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"WebKitDeveloperExtras"];
  
  self.controller = [[BitBarController alloc] init];
  [self.controller startApp];
  
}

@end
