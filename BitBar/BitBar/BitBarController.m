//
//  BitBarController.m
//  BitBar
//
//  Created by Mat Ryer on 11/13/13.
//  Copyright (c) 2013 Bit Bar. All rights reserved.
//

#import "BitBarController.h"
#import "PluginManager.h"

@implementation BitBarController

- (void) startApp {
  
  // make a plugin manager
  self.pluginManager = [[PluginManager alloc] initWithPluginPath:@"~/Work/bitbar/BitBar/BitBarTests/TestPlugins"];
  
  if ([self.pluginManager.plugins count] == 0) {
    NSLog(@"No plugins");
  } else {
    [self.pluginManager setupAllPlugins];
  }
  
}

@end
