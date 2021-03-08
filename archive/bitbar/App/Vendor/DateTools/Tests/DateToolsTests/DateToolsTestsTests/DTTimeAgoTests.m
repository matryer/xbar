//
//  DTTimeAgoTests.m
//  DateToolsTests
//
//  Created by kevin on 2014.04.05.
//
//

#import <XCTest/XCTest.h>
#import "NSDate+DateTools.h"

@interface DTTimeAgoTests : XCTestCase
@property NSDateFormatter *formatter;
@property NSDate *date0;
@property NSDate *date1;
@end

@implementation DTTimeAgoTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    self.formatter = [[NSDateFormatter alloc] init];
    [self.formatter setDateFormat:@"yyyy MM dd HH:mm:ss.SSS"];
    self.date0 = [self.formatter dateFromString:@"2014 11 05 18:15:12.000"];
    self.date1 = [self.formatter dateFromString:@"2014 11 07 18:15:12.000"];
    
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testBasicLongTimeAgo
{
    NSString *now = [self.date0 timeAgoSinceDate:self.date0];
    
    XCTAssert(now && now.length > 0, @"'Now' is nil or empty.");
    
    
    NSString *ago = [self.date1 timeAgoSinceDate:self.date0];
    
    XCTAssert(ago && ago.length > 0, @"Ago is nil or empty.");
}

- (void)testLongTimeAgo2Days
{
    self.date0 = [self.formatter dateFromString:@"2014 11 05 18:15:12.000"];
    self.date1 = [self.formatter dateFromString:@"2014 11 07 18:15:12.000"];
    NSString *ago = [self.date0 timeAgoSinceDate:self.date1];
    XCTAssertEqualObjects(ago, DateToolsLocalizedStrings(@"2 days ago"));
}

- (void)testLongTimeAgo1DayAndHalf
{
    self.date0 = [self.formatter dateFromString:@"2014 11 06 9:15:12.000"];
    self.date1 = [self.formatter dateFromString:@"2014 11 07 18:15:12.000"];
    NSString *ago = [self.date0 timeAgoSinceDate:self.date1];
    XCTAssertEqualObjects(ago, DateToolsLocalizedStrings(@"Yesterday"));
}

- (void)testLongTimeAgoExactlyYesterday
{
    self.date0 = [self.formatter dateFromString:@"2014 11 06 18:15:12.000"];
    self.date1 = [self.formatter dateFromString:@"2014 11 07 18:15:12.000"];
    NSString *ago = [self.date0 timeAgoSinceDate:self.date1];
    XCTAssertEqualObjects(ago, DateToolsLocalizedStrings(@"Yesterday"));
}

- (void)testLongTimeAgoLessThan24hoursButYesterday
{
    self.date0 = [self.formatter dateFromString:@"2014 11 06 20:15:12.000"];
    self.date1 = [self.formatter dateFromString:@"2014 11 07 18:15:12.000"];
    NSString *ago = [self.date0 timeAgoSinceDate:self.date1];
    XCTAssertEqualObjects(ago, DateToolsLocalizedStrings(@"22 hours ago"));
}

- (void)testLongTimeAgoLessThan24hoursSameDay
{
    self.date0 = [self.formatter dateFromString:@"2014 11 07 10:15:12.000"];
    self.date1 = [self.formatter dateFromString:@"2014 11 07 18:15:12.000"];
    NSString *ago = [self.date0 timeAgoSinceDate:self.date1];
    XCTAssertEqualObjects(ago, DateToolsLocalizedStrings(@"8 hours ago"));
}

- (void)testLongTimeAgoBetween24And48Hours
{
    self.date0 = [self.formatter dateFromString:@"2014 11 07 10:15:12.000"];
    self.date1 = [self.formatter dateFromString:@"2014 11 08 18:15:12.000"];
    NSString *ago = [self.date0 timeAgoSinceDate:self.date1];
    XCTAssertEqualObjects(ago, DateToolsLocalizedStrings(@"Yesterday"));
}

- (void)testBasicShortTimeAgo
{
    NSString *now = [self.date0 shortTimeAgoSinceDate:self.date0];
    
    XCTAssert(now && now.length > 0, @"'Now' is nil or empty.");
    
    
    NSString *ago = [self.date1 shortTimeAgoSinceDate:self.date0];
    
    XCTAssert(ago && ago.length > 0, @"Ago is nil or empty.");
}


- (void)testShortTimeAgo2Days
{
  self.date0 = [self.formatter dateFromString:@"2014 11 05 18:15:12.000"];
  self.date1 = [self.formatter dateFromString:@"2014 11 07 18:15:12.000"];
  NSString *ago = [self.date0 shortTimeAgoSinceDate:self.date1];
  XCTAssertEqualObjects(ago, DateToolsLocalizedStrings(@"2d"));
}

- (void)testShortTimeAgo1DayAndHalf
{
  self.date0 = [self.formatter dateFromString:@"2014 11 06 9:15:12.000"];
  self.date1 = [self.formatter dateFromString:@"2014 11 07 18:15:12.000"];
  NSString *ago = [self.date0 shortTimeAgoSinceDate:self.date1];
  XCTAssertEqualObjects(ago, DateToolsLocalizedStrings(@"1d"));
}

- (void)testShortTimeAgoExactlyYesterday
{
  self.date0 = [self.formatter dateFromString:@"2014 11 06 18:15:12.000"];
  self.date1 = [self.formatter dateFromString:@"2014 11 07 18:15:12.000"];
  NSString *ago = [self.date0 shortTimeAgoSinceDate:self.date1];
  XCTAssertEqualObjects(ago, DateToolsLocalizedStrings(@"1d"));
}

- (void)testShortTimeAgoLessThan24hoursButYesterday
{
  self.date0 = [self.formatter dateFromString:@"2014 11 06 20:15:12.000"];
  self.date1 = [self.formatter dateFromString:@"2014 11 07 18:15:12.000"];
  NSString *ago = [self.date0 shortTimeAgoSinceDate:self.date1];
  XCTAssertEqualObjects(ago, DateToolsLocalizedStrings(@"22h"));
}

- (void)testShortTimeAgoLessThan24hoursSameDay
{
  self.date0 = [self.formatter dateFromString:@"2014 11 07 10:15:12.000"];
  self.date1 = [self.formatter dateFromString:@"2014 11 07 18:15:12.000"];
  NSString *ago = [self.date0 shortTimeAgoSinceDate:self.date1];
  XCTAssertEqualObjects(ago, DateToolsLocalizedStrings(@"8h"));
}

- (void)testShortTimeAgoBetween24And48Hours
{
    self.date0 = [self.formatter dateFromString:@"2014 11 07 10:15:12.000"];
    self.date1 = [self.formatter dateFromString:@"2014 11 08 18:15:12.000"];
    NSString *ago = [self.date0 shortTimeAgoSinceDate:self.date1];
    XCTAssertEqualObjects(ago, DateToolsLocalizedStrings(@"1d"));
}

- (void)testLongTimeAgoLocalizationsAccessible
{
    NSString *en_local = @"Yesterday";
    NSString *ja_local = @"昨日";

    NSString *key = en_local;
    
    NSString *path = [NSBundle.mainBundle.bundlePath stringByAppendingPathComponent:@"DateTools.bundle/ja.lproj"];
    NSBundle *bundle = [NSBundle bundleWithPath:path];
    
    NSString *ja_result = NSLocalizedStringFromTableInBundle(key, @"DateTools", bundle, nil);
    
    XCTAssertEqualObjects(ja_local, ja_result, @"Could not access localizations.");
}


@end
