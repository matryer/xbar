//
//  BitBarController.m
//  BitBar
//
//  Created by Mat Ryer on 11/13/13.
//  Copyright (c) 2013 Bit Bar. All rights reserved.
//

#import "BitBarController.h"
#import "PluginManager.h"
#import "Settings.h"

@implementation BitBarController

- (void) startApp {
  
  NSLog(@"pluginsDirectory: %@", [Settings pluginsDirectory]);
  
  // make a plugin manager
  self.pluginManager = [[PluginManager alloc] initWithPluginPath:[Settings pluginsDirectory]];
  
  if ([self.pluginManager.plugins count] == 0) {
    NSLog(@"No plugins");
  } else {
    [self.pluginManager setupAllPlugins];
  }
  
}

@end
