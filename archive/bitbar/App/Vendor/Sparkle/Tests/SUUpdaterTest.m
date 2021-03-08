//
//  SUUpdaterTest.m
//  Sparkle
//
//  Created by Jake Petroules on 2014-06-29.
//  Copyright (c) 2014 Sparkle Project. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SUConstants.h"
#import "SUUpdater.h"

@interface SUUpdaterTest : XCTestCase <SUUpdaterDelegate>
@property (strong) NSOperationQueue *queue;
@property (strong) SUUpdater *updater;
@end

@implementation SUUpdaterTest

@synthesize queue;
@synthesize updater;

- (void)setUp
{
    [super setUp];
    self.queue = [[NSOperationQueue alloc] init];
    self.updater = [[SUUpdater alloc] initForBundle:[NSBundle bundleForClass:[self class]]];
    self.updater.delegate = self;
}

- (void)tearDown
{
    self.updater = nil;
    self.queue = nil;
    [super tearDown];
}

- (NSString *)feedURLStringForUpdater:(SUUpdater *) __unused updater
{
    return @"https://test.example.com";
}

- (void)testFeedURL
{
    [self.updater feedURL]; // this WON'T throw

    [self.queue addOperationWithBlock:^{
        XCTAssertTrue(![NSThread isMainThread]);
        @try {
            [self.updater feedURL];
            XCTFail(@"feedURL did not throw an exception when called on a secondary thread");
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception);
        }
    }];
    [self.queue waitUntilAllOperationsAreFinished];
}

- (void)testSetTestFeedURL
{
    [self.updater setFeedURL:[NSURL URLWithString:@""]]; // this WON'T throw

    [self.queue addOperationWithBlock:^{
        XCTAssertTrue(![NSThread isMainThread]);
        @try {
            [self.updater setFeedURL:[NSURL URLWithString:@""]];
            XCTFail(@"setFeedURL: did not throw an exception when called on a secondary thread");
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception);
        }
    }];
    [self.queue waitUntilAllOperationsAreFinished];
}

@end
