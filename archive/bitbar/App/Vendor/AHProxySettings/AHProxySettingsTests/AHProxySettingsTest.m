//
//  AHProxySettingsTest.m
//  AHProxySettings
//
//  Created by Eldon on 11/9/14.
//  Copyright (c) 2014 Eldon Ahrold. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

#import "AHProxySettings.h"

@interface AHProxySettingsTest : XCTestCase

@end

@implementation AHProxySettingsTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testAll {
    // When running this test enable Auto Detect, HTTP, HTTPS, SOCKS, FTP
    AHProxySettings *settings = [[AHProxySettings alloc] initWithDestination:@"https://github.com"];

    XCTAssertNotNil(settings.HTTPProxy ,@"No HTTP proxy returned");
    NSLog(@"%@", settings.HTTPProxy);

    XCTAssertNotNil(settings.HTTPSProxy ,@"No HTTPS proxy returned");
    NSLog(@"%@",settings.HTTPSProxy);

    XCTAssertNotNil(settings.SOCKSProxy ,@"No SOCKS proxy returned");
    NSLog(@"%@",settings.SOCKSProxy);

    XCTAssertNotNil(settings.FTPProxy ,@"No FTP proxy returned");
    NSLog(@"%@",settings.FTPProxy);

    XCTAssertNotNil(settings.autoDetectedProxies ,@"No Auto Detected Proxies returned");
    for (AHProxy *p in settings.autoDetectedProxies) {
        NSLog(@"%@",p);
    }
}

- (void)testAutoDetect {
    // When running this test only have Auto Proxy Discovery Enabled
    AHProxySettings *settings = [[AHProxySettings alloc] initWithDestination:@"https://github.com"];

    NSLog(@"Proxy for localhost%@",settings.taskDictionary);

    XCTAssertNotNil(settings.autoDetectedProxies ,@"No proxy returned");
    XCTAssertNotNil(settings.HTTPProxy,@"A proxy returned, but should not have");

    settings.useAutoDetectAsFailover = NO;
    XCTAssertNil(settings.HTTPProxy,@"A proxy returned, but should not have");

    settings.destinationURL = @"http://localhost";
    XCTAssertNil(settings.autoDetectedProxies,@"A proxy returned, but should not have");
    XCTAssertNil(settings.HTTPProxy,@"A proxy returned, but should not have");
}

- (void)testTaskDictOn {
    // Have some proxies enabled when running this test
    AHProxySettings *settings = [[AHProxySettings alloc] init];
    XCTAssertNotNil(settings.taskDictionary,@"Couldn't determine task dictionary");
}

- (void)testTaskDict {
    // Disable all proxies before running this test
    AHProxySettings *settings = [[AHProxySettings alloc] init];
    NSDictionary *dict = settings.taskDictionary;
    XCTAssertNil(dict,@"There should be not task dictionary: %@",dict);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
        [self testAll];
    }];
}

@end
