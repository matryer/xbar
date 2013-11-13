//
//  PluginManagerTest.m
//  BitBar
//
//  Created by Mat Ryer on 11/12/13.
//  Copyright (c) 2013 Bit Bar. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PluginManager.h"
#import "Plugin.h"

@interface PluginManagerTest : XCTestCase

@end

@implementation PluginManagerTest

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInit
{
  
  PluginManager *manager = [[PluginManager alloc] initWithPluginPath:@"~/Work/bitbar/BitBar/BitBarTests/TestPlugins"];
  XCTAssert([manager.path isEqualToString:[@"~/Work/bitbar/BitBar/BitBarTests/TestPlugins" stringByStandardizingPath]]);
  
}

- (void)testPluginFiles {
  
  PluginManager *manager = [[PluginManager alloc] initWithPluginPath:@"~/Work/bitbar/BitBar/BitBarTests/TestPlugins"];
  
  NSArray *pluginFiles = [manager pluginFiles];
  XCTAssertEqual((NSUInteger)3, [pluginFiles count], @"pluginFiles count");
  
}

- (void)testPlugins {
  
  PluginManager *manager = [[PluginManager alloc] initWithPluginPath:@"~/Work/bitbar/BitBar/BitBarTests/TestPlugins"];

  NSDictionary *plugins = [manager plugins];
  
  XCTAssertEqual((NSUInteger)3, [plugins count], @"plugins count");
  Plugin *one = [plugins objectForKey:@"one.10s.sh"];
  
  XCTAssertNotNil(one, @"one shouldn't be nil");
  XCTAssert([one.name isEqualToString:@"one.10s.sh"], @"name");
  XCTAssert([one.path isEqualToString:[[@"~/Work/bitbar/BitBar/BitBarTests/TestPlugins" stringByStandardizingPath] stringByAppendingPathComponent:@"one.10s.sh"]], @"path");
  
}

@end
