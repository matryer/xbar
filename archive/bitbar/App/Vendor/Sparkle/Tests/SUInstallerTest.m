//
//  SUInstallerTest.m
//  Sparkle
//
//  Created by Kornel on 24/04/2015.
//  Copyright (c) 2015 Sparkle Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "SUHost.h"
#import "SUInstaller.h"
#import <unistd.h>

@interface SUInstallerTest : XCTestCase

@end

@implementation SUInstallerTest

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

#if __clang_major__ >= 6
- (void)testInstallIfRoot
{
    uid_t uid = getuid();

    if (uid) {
        NSLog(@"Test must be run as root: sudo xctest -XCTest SUInstallerTest 'Sparkle Unit Tests.xctest'");
        return;
    }

    NSString *expectedDestination = @"/tmp/sparklepkgtest.app";
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:expectedDestination error:nil];
    XCTAssertFalse([fm fileExistsAtPath:expectedDestination isDirectory:nil]);

    XCTestExpectation *done = [self expectationWithDescription:@"install finished"];

    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"test.sparkle_guided" ofType:@"pkg"];
    XCTAssertNotNil(path);

    SUHost *host = [[SUHost alloc] initWithBundle:bundle];

    NSString *fileOperationToolPath = [bundle pathForResource:@""SPARKLE_FILEOP_TOOL_NAME ofType:@""];
    XCTAssertNotNil(fileOperationToolPath);
    
    [SUInstaller installFromUpdateFolder:[path stringByDeletingLastPathComponent] overHost:host installationPath:@"/tmp" fileOperationToolPath:fileOperationToolPath versionComparator:nil completionHandler:^(NSError *error) {
        if (error != nil) {
            NSLog(@"Underlying error: %@", [error.userInfo objectForKey:NSUnderlyingErrorKey]);
        }
        XCTAssertNil(error);
        XCTAssertTrue([fm fileExistsAtPath:expectedDestination isDirectory:nil]);
        [done fulfill];
    }];

    [self waitForExpectationsWithTimeout:40 handler:nil];
    [fm removeItemAtPath:expectedDestination error:nil];
}
#endif

@end
