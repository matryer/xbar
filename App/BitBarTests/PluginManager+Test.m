//
//  PluginManager+Test.m
//  BitBar
//
//  Created by Kent Karlsson on 3/11/16.
//  Copyright © 2016 Bit Bar. All rights reserved.
//

#import "PluginManager+Test.h"

@implementation PluginManager (Test)

+ (NSString*)pluginPath {
  return [[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:@"TestPlugins"];
}

+ (PluginManager*)testManager {
  NSString* testPluginsPath = [PluginManager pluginPath];
  return [PluginManager.alloc initWithPluginPath:testPluginsPath];
}

@end
