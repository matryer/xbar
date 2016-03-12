//
//  PluginTest.m
//  BitBar
//
//  Created by Mat Ryer on 11/12/13.
//  Copyright (c) 2013 Bit Bar. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ExecutablePlugin.h"
#import "PluginManager+Test.h"

@interface PluginTest : XCTestCase

@end

@implementation PluginTest

- (void)testInitWithManager {
  PluginManager *manager = [PluginManager testManager];
  XCTAssertNotNil(manager);

  Plugin *p = [Plugin.alloc initWithManager:manager];
  XCTAssertNotNil(p);

  XCTAssertEqual(p.manager, manager);
  XCTAssertEqual((NSInteger)-1, p.currentLine);
  XCTAssertEqual((NSInteger)5, p.cycleLinesIntervalSeconds);
  
}

- (void)testStatusItem {
  
  PluginManager *manager = [PluginManager testManager];
  Plugin *p = [Plugin.alloc initWithManager:manager];
  NSStatusItem *item = p.statusItem;
  XCTAssertNotNil(item, @"item nil?");
  XCTAssertEqual((CGFloat)NSVariableStatusItemLength, item.length, @"length == NSVariableStatusItemLength");
  
  // make sure it has a menu
  XCTAssertNotNil(item.menu, @"menu");
  
}

- (void)testExample
{

  PluginManager *manager = [PluginManager testManager];
  Plugin *p = [Plugin.alloc initWithManager:manager];
  
  p.name = @"name.10s.sh";
  p.refreshIntervalSeconds = nil;
  XCTAssertEqual((double)10, [p.refreshIntervalSeconds doubleValue], @"10s");
  
  p.name = @"name.10m.sh";
  p.refreshIntervalSeconds = nil;
  XCTAssertEqual((double)(10*60), [p.refreshIntervalSeconds doubleValue], @"10m");
  
  p.name = @"name.10h.sh";
  p.refreshIntervalSeconds = nil;
  XCTAssertEqual((double)(10*60*60), [p.refreshIntervalSeconds doubleValue], @"10h");
  
  p.name = @"name.10d.sh";
  p.refreshIntervalSeconds = nil;
  XCTAssertEqual((double)(10*60*60*24), [p.refreshIntervalSeconds doubleValue], @"10d");
  
  p.name = @"name.10S.sh";
  p.refreshIntervalSeconds = nil;
  XCTAssertEqual((double)10, [p.refreshIntervalSeconds doubleValue], @"10S");
  
  p.name = @"name.10M.sh";
  p.refreshIntervalSeconds = nil;
  XCTAssertEqual((double)(10*60), [p.refreshIntervalSeconds doubleValue], @"10M");
  
  p.name = @"name.10H.sh";
  p.refreshIntervalSeconds = nil;
  XCTAssertEqual((double)(10*60*60), [p.refreshIntervalSeconds doubleValue], @"10H");
  
  p.name = @"name.10D.sh";
  p.refreshIntervalSeconds = nil;
  XCTAssertEqual((double)(10*60*60*24), [p.refreshIntervalSeconds doubleValue], @"10D");
  
  // and some failures
  
  p.name = @"name.10.sh";
  p.refreshIntervalSeconds = nil;
  XCTAssertEqual((double)(60), [p.refreshIntervalSeconds doubleValue], @"10");
  
  p.name = @"name.sh";
  p.refreshIntervalSeconds = nil;
  XCTAssertEqual((double)(60), [p.refreshIntervalSeconds doubleValue], @"name.sh");
 
  p.name = @"name.bollocks.sh";
  p.refreshIntervalSeconds = nil;
  XCTAssertEqual((double)(60), [p.refreshIntervalSeconds doubleValue], @"name.sh");
  
}

- (void)testRefreshContentByExecutingCommandSuccess {

  PluginManager *manager = [PluginManager testManager];
  ExecutablePlugin *p = [ExecutablePlugin.alloc initWithManager:manager];
  
  p.name = @"one.10s.sh";
  p.path = [[PluginManager pluginPath] stringByAppendingPathComponent:p.name];
  
  XCTAssertEqual(YES, [p refreshContentByExecutingCommand]);
    
  XCTAssert([p.content isEqualToString:@"This is just a test.\n"], @"Content");
  XCTAssert([[p allContent] isEqualToString:@"This is just a test.\n"], @"all content");

  XCTAssertEqual(NO, p.lastCommandWasError);
  
  p.name = @"two.5m.sh";
  p.path = [[PluginManager pluginPath] stringByAppendingPathComponent:p.name];
  
  XCTAssertEqual(NO, [p refreshContentByExecutingCommand]);
  
  XCTAssert([p.content isEqualToString:@""], @"content");
  XCTAssert([p.allContent isEqualToString:@"⚠️\n---\nSomething went tits up."], @"all content");
  XCTAssertEqual(YES, p.lastCommandWasError);
  
}

- (void)testRefreshContentByExecutingCommandError {
  
  PluginManager *manager = [PluginManager testManager];
  ExecutablePlugin *p = [ExecutablePlugin.alloc initWithManager:manager];
  
  p.name = @"two.5m.sh";
  p.path = [[PluginManager pluginPath] stringByAppendingPathComponent:p.name];
  
  XCTAssertEqual(NO, [p refreshContentByExecutingCommand]);
  
  XCTAssert([p.errorContent isEqualToString:@"Something went tits up."], @"Error content");
  XCTAssert([p.allContent isEqualToString:@"⚠️\n---\nSomething went tits up."], @"all content");
  XCTAssertEqual(YES, p.lastCommandWasError);
  
  p.name = @"one.10s.sh";
  p.path = [[PluginManager pluginPath] stringByAppendingPathComponent:p.name];
  
  XCTAssertEqual(YES, [p refreshContentByExecutingCommand]);
  
  XCTAssert([p.errorContent isEqualToString:@""], @"Error content");
  XCTAssert([p.allContent isEqualToString:@"This is just a test.\n"], @"all content");
  XCTAssertEqual(NO, p.lastCommandWasError);
  
}

- (void)testContentLines {
  
  PluginManager *manager = [PluginManager testManager];
  Plugin *p = [Plugin.alloc initWithManager:manager];
  
  p.content = @"---\nHello\nWorld\nOf\nBitBar";
  
  NSArray *lines = p.allContentLines;
  
  XCTAssertEqual((NSUInteger)4, lines.count);
  XCTAssert([lines[0] isEqualToString:@"Hello"]);
  XCTAssert([lines[1] isEqualToString:@"World"]);
  XCTAssert([lines[2] isEqualToString:@"Of"]);
  XCTAssert([lines[3] isEqualToString:@"BitBar"]);
  
  p.content = @"---\n  Hello \t \n\tWorld\t\n  Of  \n  BitBar";
  
  [p contentHasChanged];
  lines = p.allContentLines;
  
  XCTAssertEqual((NSUInteger)4, lines.count);
  XCTAssert([lines[0] isEqualToString:@"  Hello \t "]);
  XCTAssert([lines[1] isEqualToString:@"\tWorld\t"]);
  XCTAssert([lines[2] isEqualToString:@"  Of  "]);
  XCTAssert([lines[3] isEqualToString:@"  BitBar"]);
  
  p.content = @"---\n\n\n  Hello \t \n\t\n\n\nWorld\t\n\n\n\n  Of  \n  BitBar";
  
  [p contentHasChanged];
  lines = p.allContentLines;
  
  XCTAssertEqual((NSUInteger)4, lines.count);
  XCTAssert([lines[0] isEqualToString:@"  Hello \t "]);
  XCTAssert([lines[1] isEqualToString:@"World\t"]);
  XCTAssert([lines[2] isEqualToString:@"  Of  "]);
  XCTAssert([lines[3] isEqualToString:@"  BitBar"]);
  
  
  p.content = @"---\n\n\n  Hello \t \n\t\nWorld\n\n---\nThe World\t\n\n\n\n  Of  \n  BitBar";
  
  [p contentHasChanged];
  lines = p.allContentLines;
  
  XCTAssertEqual((NSUInteger)6, lines.count);
  XCTAssert([lines[0] isEqualToString:@"  Hello \t "]);
  XCTAssert([lines[1] isEqualToString:@"World"]);
  XCTAssert([lines[2] isEqualToString:@"---"]);
  XCTAssert([lines[3] isEqualToString:@"The World\t"]);
  XCTAssert([lines[4] isEqualToString:@"  Of  "]);
  XCTAssert([lines[5] isEqualToString:@"  BitBar"]);
}

- (void)testIsMultiline {
  
  PluginManager *manager = [PluginManager testManager];
  Plugin *p = [Plugin.alloc initWithManager:manager];
  
  p.content = @"Hello\nWorld\nOf\nBitBar";
  XCTAssertEqual(YES, p.isMultiline);
  
  p.content = @"One line mate";
  XCTAssertEqual(NO, p.isMultiline);
  
}


- (void)testRefresh {
  
  PluginManager *manager = [PluginManager testManager];
  ExecutablePlugin *p = [ExecutablePlugin.alloc initWithManager:manager];

  p.name = @"three.7d.sh";
  p.path = [[PluginManager pluginPath] stringByAppendingPathComponent:p.name];

  XCTAssertEqual(YES, [p refresh]);

  [self keyValueObservingExpectationForObject:p keyPath:@"currentLine" expectedValue:0];
  [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
    XCTAssert([p.statusItem.title isEqualToString:@"line 1"]);
  }];

}

- (void)testCycleLinesAndCurrentLine {
  
  PluginManager *manager = [PluginManager testManager];
  ExecutablePlugin *p = [ExecutablePlugin.alloc initWithManager:manager];

  p.name = @"three.7d.sh";
  p.path = [[PluginManager pluginPath] stringByAppendingPathComponent:p.name];

  XCTAssertEqual((NSInteger)-1, p.currentLine);
  
  [p refresh];
  [self keyValueObservingExpectationForObject:p keyPath:@"currentLine" expectedValue:0];
  [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
    XCTAssertEqual((NSInteger)0, p.currentLine);
    XCTAssert([p.statusItem.title isEqualToString:@"line 1"]);

    [p cycleLines];
    XCTAssertEqual((NSInteger)1, p.currentLine);
    XCTAssert([p.statusItem.title isEqualToString:@"line 2"]);

    [p cycleLines];
    XCTAssertEqual((NSInteger)2, p.currentLine);
    XCTAssert([p.statusItem.title isEqualToString:@"line 3"]);

    [p cycleLines];
    XCTAssertEqual((NSInteger)0, p.currentLine);
    XCTAssert([p.statusItem.title isEqualToString:@"line 1"]);

    [p cycleLines];
    XCTAssertEqual((NSInteger)1, p.currentLine);
    XCTAssert([p.statusItem.title isEqualToString:@"line 2"]);

    [p cycleLines];
    XCTAssertEqual((NSInteger)2, p.currentLine);
    XCTAssert([p.statusItem.title isEqualToString:@"line 3"]);
  }];
}

- (void)testRebuildMenuForStatusItem {
  
  PluginManager *manager = [PluginManager testManager];
  ExecutablePlugin *p = [ExecutablePlugin.alloc initWithManager:manager];
  
  p.name = @"three.7d.sh";
  p.path = [[PluginManager pluginPath] stringByAppendingPathComponent:p.name];

  [p refreshContentByExecutingCommand];
  
  [p rebuildMenuForStatusItem:p.statusItem];

  NSUInteger itemCount = 3;
#ifdef DISTRO
  itemCount += 2;
#else
  itemCount += 3;
#endif  
  XCTAssertEqual(itemCount, [[p.statusItem.menu itemArray] count]);
  
}

@end
