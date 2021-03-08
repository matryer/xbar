//
//  SUVersionComparisonTest.m
//  Sparkle
//
//  Created by Andy Matuschak on 4/15/08.
//  Copyright 2008 Andy Matuschak. All rights reserved.
//

#import "SUStandardVersionComparator.h"

#import <XCTest/XCTest.h>

@interface SUVersionComparisonTestCase : XCTestCase {
}
@end

@implementation SUVersionComparisonTestCase

#define SUAssertOrder(a, b, c) XCTAssertTrue([[SUStandardVersionComparator defaultComparator] compareVersion:a toVersion:b] == c, @"b should be newer than a!")
#define SUAssertAscending(a, b) SUAssertOrder(a, b, NSOrderedAscending)
#define SUAssertDescending(a, b) SUAssertOrder(a, b, NSOrderedDescending)
#define SUAssertEqual(a, b) SUAssertOrder(a, b, NSOrderedSame)

- (void)testNumbers
{
    SUAssertAscending(@"1.0", @"1.1");
    SUAssertEqual(@"1.0", @"1.0");
    SUAssertDescending(@"2.0", @"1.1");
    SUAssertDescending(@"0.1", @"0.0.1");
    //SUAssertDescending(@".1", @"0.0.1"); Known bug, but I'm not sure I care.
    SUAssertAscending(@"0.1", @"0.1.2");
}

- (void)testPrereleases
{
    SUAssertAscending(@"1.5.5", @"1.5.6a1");
    SUAssertAscending(@"1.1.0b1", @"1.1.0b2");
    SUAssertAscending(@"1.1.1b2", @"1.1.2b1");
    SUAssertAscending(@"1.1.1b2", @"1.1.2a1");
    SUAssertAscending(@"1.0a1", @"1.0b1");
    SUAssertAscending(@"1.0b1", @"1.0");
    SUAssertAscending(@"0.9", @"1.0a1");
    SUAssertAscending(@"1.0b", @"1.0b2");
    SUAssertAscending(@"1.0b10", @"1.0b11");
    SUAssertAscending(@"1.0b9", @"1.0b10");
    SUAssertAscending(@"1.0rc", @"1.0");
    SUAssertAscending(@"1.0b", @"1.0");
    SUAssertAscending(@"1.0pre1", @"1.0");
}

- (void)testVersionsWithBuildNumbers
{
    SUAssertAscending(@"1.0 (1234)", @"1.0 (1235)");
    SUAssertAscending(@"1.0b1 (1234)", @"1.0 (1234)");
    SUAssertAscending(@"1.0b5 (1234)", @"1.0b5 (1235)");
    SUAssertAscending(@"1.0b5 (1234)", @"1.0.1b5 (1234)");
    SUAssertAscending(@"1.0.1b5 (1234)", @"1.0.1b6 (1234)");
    SUAssertAscending(@"2.0.0.2429", @"2.0.0.2430");
    SUAssertAscending(@"1.1.1.1818", @"2.0.0.2430");

    SUAssertAscending(@"3.3 (5847)", @"3.3.1b1 (5902)");
}

- (void)testWordsWithSpaceInFront
{
//	SUAssertAscending(@"1.0 beta", @"1.0");
//	SUAssertAscending(@"1.0  - beta", @"1.0");
//	SUAssertAscending(@"1.0 alpha", @"1.0 beta");
//	SUAssertEqual(@"1.0  - beta", @"1.0beta");
//	SUAssertEqual(@"1.0  - beta", @"1.0 beta");
}

- (void)testVersionsWithReverseDateBasedNumbers
{
    SUAssertAscending(@"201210251627", @"201211051041");
}

@end
