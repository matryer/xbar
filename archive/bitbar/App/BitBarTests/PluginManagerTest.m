//
//  PluginManagerTest.m
//  BitBar
//
//  Created by Mat Ryer on 11/12/13.
//  Copyright (c) 2013 Bit Bar. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PluginManager+Test.h"
#import "Plugin.h"

@interface PluginManagerTest : XCTestCase

@end

@implementation PluginManagerTest

- (void)testInit
{
  
  PluginManager *manager = [PluginManager testManager];
  XCTAssert([manager.path isEqualToString:[PluginManager pluginPath]]);
  XCTAssertNotNil(manager.path);
}

- (void)testPluginFiles {
  
  PluginManager *manager = [PluginManager testManager];

  NSArray *pluginFiles = manager.plugins;
  XCTAssertEqual((NSUInteger)3, [pluginFiles count], @"pluginFiles count");
  
}

- (void)testPlugins {
  
  PluginManager *manager = [PluginManager testManager];

  NSArray *plugins = manager.plugins;
  
  XCTAssertEqual((NSUInteger)3, [plugins count], @"plugins count");
  Plugin *one = [plugins objectAtIndex:0];
  
  XCTAssertNotNil(one, @"one shouldn't be nil");
  XCTAssertEqual(manager, one.manager, @"manager");
  XCTAssert([one.name isEqualToString:@"one.10s.sh"], @"name");
  XCTAssert([one.path isEqualToString:[[PluginManager pluginPath] stringByAppendingPathComponent:@"one.10s.sh"]], @"path");
  
}

- (void)testStatusBar {
  
  PluginManager *manager = [PluginManager testManager];

  NSStatusBar *statusBar = manager.statusBar;
  XCTAssertNotNil(statusBar, @"statusBar");
  XCTAssertEqual([NSStatusBar systemStatusBar], statusBar, @"statusBar should default to system one");
 
  // set on explicitly
  NSStatusBar *newBar = NSStatusBar.new;
  manager.statusBar = newBar;
  XCTAssertEqual(newBar, manager.statusBar);
  
}

@end
