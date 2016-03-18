//
//  PluginManager+Test.m
//  BitBar
//
//  Created by Kent Karlsson on 3/11/16.
//  Copyright © 2016 Bit Bar. All rights reserved.
//

#import "PluginManager+Test.h"

// This class is just here so that we can get the path to the test bundle
@interface BBTestClass : NSObject
+ (NSString*)pluginPath;
@end
@implementation BBTestClass
+ (NSString*)pluginPath {
  return [[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:@"TestPlugins"];
}
@end

@implementation PluginManager (Test)

+ (NSString*)pluginPath {
  return [BBTestClass pluginPath];
}

+ (PluginManager*)testManager {
  id delegate = [NSApplication sharedApplication].delegate;
  return [delegate valueForKey:@"pluginManager"];
}

@end
