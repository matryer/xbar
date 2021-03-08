//
//  DateToolsTests.m
//  DateToolsExample
//
//  Created by Matthew York on 3/19/14.
//
//

#import <XCTest/XCTest.h>
#import "NSDate+DateTools.h"

@interface DateToolsTests : XCTestCase
@property NSDateFormatter *formatter;
@property NSDate *controlDate;
@end

@implementation DateToolsTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    self.formatter = [[NSDateFormatter alloc] init];
    [self.formatter setDateFormat:@"yyyy MM dd HH:mm:ss.SSS"];
    self.controlDate = [self.formatter dateFromString:@"2014 11 05 18:15:12.000"];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - Date Components

- (void)testEra {
    XCTAssertEqual(1, [[NSDate date] era], @"%s Failed", __PRETTY_FUNCTION__);
}
- (void)testYear{
    XCTAssertEqual(2014, self.controlDate.year, @"%s Failed", __PRETTY_FUNCTION__);
}
- (void)testMonth{
    XCTAssertEqual(11, self.controlDate.month, @"%s Failed", __PRETTY_FUNCTION__);
}
- (void)testDay{
    XCTAssertEqual(5, self.controlDate.day, @"%s Failed", __PRETTY_FUNCTION__);
}
- (void)testHour{
    XCTAssertEqual(18, self.controlDate.hour, @"%s Failed", __PRETTY_FUNCTION__);
}
- (void)testMinute{
    XCTAssertEqual(15, self.controlDate.minute, @"%s Failed", __PRETTY_FUNCTION__);
}
- (void)testSecond{
    XCTAssertEqual(12, self.controlDate.second, @"%s Failed", __PRETTY_FUNCTION__);
}
- (void)testWeekday{
    XCTAssertEqual(4, self.controlDate.weekday, @"%s Failed", __PRETTY_FUNCTION__);
}
- (void)testWeekdayOrdinal{
    XCTAssertEqual(1, self.controlDate.weekdayOrdinal, @"%s Failed", __PRETTY_FUNCTION__);
}
- (void)testQuarter{
    //Quarter is a little funky right now
    //XCTAssertEqual(4, self.testDate.quarter, @"%s Failed", __PRETTY_FUNCTION__);
}
- (void)testWeekOfMonth{
    XCTAssertEqual(2, self.controlDate.weekOfMonth, @"%s Failed", __PRETTY_FUNCTION__);
}
- (void)testWeekOfYear{
    XCTAssertEqual(45, self.controlDate.weekOfYear, @"%s Failed", __PRETTY_FUNCTION__);
}
- (void)testYearForWeekOfYear{
    XCTAssertEqual(2014, self.controlDate.yearForWeekOfYear, @"%s Failed", __PRETTY_FUNCTION__);
}
- (void)testDaysInMonth{
    XCTAssertEqual(30, self.controlDate.daysInMonth, @"%s Failed", __PRETTY_FUNCTION__);
}
- (void)testDaysInYear{
    //Non leap year (2014)
    XCTAssertEqual(365, self.controlDate.daysInYear, @"%s Failed", __PRETTY_FUNCTION__);
    
    //Leap year (2000)
    XCTAssertEqual(366, [self.controlDate dateBySubtractingYears:14].daysInYear, @"%s Failed", __PRETTY_FUNCTION__);
}
- (void)testIsInLeapYear{
    //Not leap year
    XCTAssertFalse([self.controlDate isInLeapYear],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Is leap year (%400) 2000
    XCTAssertTrue([[self.controlDate dateBySubtractingYears:14] isInLeapYear],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Not leap year (%100) 1900
    XCTAssertFalse([[self.controlDate dateBySubtractingYears:114] isInLeapYear],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Is leap year (%4) 2016
    XCTAssertTrue([[self.controlDate dateByAddingYears:2] isInLeapYear],  @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testIsToday{
    //Test true now
    XCTAssertTrue([NSDate date].isToday, @"%s Failed", __PRETTY_FUNCTION__);
    
    //Test true past (Technically, could fail if you ran the test precisely at midnight, but...)
    XCTAssertTrue([[NSDate date] dateBySubtractingSeconds:1].isToday, @"%s Failed", __PRETTY_FUNCTION__);
    
    //Test true future (Technically, could fail if you ran the test precisely at midnight, but...)
    XCTAssertTrue([[NSDate date] dateByAddingSeconds:1].isToday, @"%s Failed", __PRETTY_FUNCTION__);
    
    //Tests false past
    XCTAssertFalse([[NSDate date] dateBySubtractingDays:2].isToday, @"%s Failed", __PRETTY_FUNCTION__);
    
    //Tests false future
    XCTAssertFalse([[NSDate date] dateByAddingDays:1].isToday, @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testIsTomorrow{
    //Test false with now
    XCTAssertFalse([NSDate date].isTomorrow, @"%s Failed", __PRETTY_FUNCTION__);
    
    //Test false past
    XCTAssertFalse([[NSDate date] dateBySubtractingDays:1].isTomorrow, @"%s Failed", __PRETTY_FUNCTION__);
    
    //Test true future
    XCTAssertTrue([[NSDate date] dateByAddingDays:1].isTomorrow, @"%s Failed", __PRETTY_FUNCTION__);
    
    //Tests false future
    XCTAssertFalse([[NSDate date] dateByAddingDays:2].isTomorrow, @"%s Failed", __PRETTY_FUNCTION__);
    
}
-(void)testIsYesterday{
    //Test false with now
    XCTAssertFalse([NSDate date].isYesterday, @"%s Failed", __PRETTY_FUNCTION__);
    
    //Test true past
    XCTAssertTrue([[NSDate date] dateBySubtractingDays:1].isYesterday, @"%s Failed", __PRETTY_FUNCTION__);
    
    //Test false future
    XCTAssertFalse([[NSDate date] dateByAddingDays:1].isYesterday, @"%s Failed", __PRETTY_FUNCTION__);
    
    //Tests false future
    XCTAssertFalse([[NSDate date] dateBySubtractingDays:2].isYesterday, @"%s Failed", __PRETTY_FUNCTION__);
}

-(void)testIsWeekend{
    //Created test dates
    NSDate *testFriday = [self.formatter dateFromString:@"2015 09 04 12:45:12.000"];
    NSDate *testMonday = [self.formatter dateFromString:@"2015 02 16 00:00:00.000"];
    NSDate *testWeekend = [self.formatter dateFromString:@"2015 09 05 17:45:12.000"];
    
    //Test false with friday and monday
    XCTAssertFalse(testFriday.isWeekend, @"%s Failed", __PRETTY_FUNCTION__);
    XCTAssertFalse(testMonday.isWeekend, @"%s Failed", __PRETTY_FUNCTION__);
    
    //Test true past
    XCTAssertTrue(testWeekend.isWeekend, @"%s Failed", __PRETTY_FUNCTION__);
}

-(void)testIsSameDay {
    //Test same time stamp
    XCTAssertTrue([[NSDate date] isSameDay:[NSDate date]], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Test true same day
    NSDate *testSameDay1 = [self.formatter dateFromString:@"2014 11 05 12:45:12.000"];
    NSDate *testSameDay2 = [self.formatter dateFromString:@"2014 11 05 17:45:12.000"];
    XCTAssertTrue([testSameDay1 isSameDay:testSameDay2], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Test false 1 day ahead
    XCTAssertFalse([testSameDay1 isSameDay:[[NSDate date] dateByAddingDays:1]], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Test false 1 day before
    XCTAssertFalse([testSameDay1 isSameDay:[[NSDate date] dateBySubtractingDays:1]], @"%s Failed", __PRETTY_FUNCTION__);
}

-(void)testIsSameDayStatic {
    //Test true same time stamp
    XCTAssertTrue([NSDate isSameDay:[NSDate date] asDate:[NSDate date]], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Test true same day
    NSDate *testSameDay1 = [self.formatter dateFromString:@"2014 11 05 12:45:12.000"];
    NSDate *testSameDay2 = [self.formatter dateFromString:@"2014 11 05 17:45:12.000"];
    XCTAssertTrue([NSDate isSameDay:testSameDay1 asDate:testSameDay2], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Test false 1 day ahead
    XCTAssertFalse([NSDate isSameDay:[NSDate date] asDate:[[NSDate date] dateByAddingDays:1]], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Test false 1 day before
    XCTAssertFalse([NSDate isSameDay:[NSDate date] asDate:[[NSDate date] dateBySubtractingDays:1]], @"%s Failed", __PRETTY_FUNCTION__);
}

#pragma mark - Date Editing
#pragma mark Date Creating

- (void)testDateWithYearMonthDayHourMinuteSecond{
    XCTAssertEqual(YES, [self.controlDate isEqualToDate:[NSDate dateWithYear:2014 month:11 day:5 hour:18 minute:15 second:12]], @"%s Failed", __PRETTY_FUNCTION__);
}

- (void)testDateWithStringFormatStringTimeZone {
	NSDate *testDate = [NSDate dateWithString:@"2015-02-27T18:15:00"
								 formatString:@"yyyy-MM-dd'T'HH:mm:ss"
									 timeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
	
	XCTAssertEqual(YES, [testDate isEqualToDate:[NSDate dateWithString:@"2015-02-27T19:15:00"
														  formatString:@"yyyy-MM-dd'T'HH:mm:ss"
															  timeZone:[NSTimeZone timeZoneWithName:@"Europe/Warsaw"]]], @"%s Failed", __PRETTY_FUNCTION__);
}

#pragma mark Date By Adding
- (void)testDateByAddingYears{
    NSDate *testDate = [self.formatter dateFromString:@"2016 11 05 18:15:12.000"];
    XCTAssertEqual(YES, [[self.controlDate dateByAddingYears:2] isEqualToDate:testDate], @"%s Failed", __PRETTY_FUNCTION__);
}
- (void)testDateByAddingMonths{
    NSDate *testDate = [self.formatter dateFromString:@"2015 01 05 18:15:12.000"];
    XCTAssertEqual(YES, [[self.controlDate dateByAddingMonths:2] isEqualToDate:testDate], @"%s Failed", __PRETTY_FUNCTION__);
}
- (void)testDateByAddingWeeks{
    NSDate *testDate = [self.formatter dateFromString:@"2014 11 12 18:15:12.000"];
    XCTAssertEqual(YES, [[self.controlDate dateByAddingWeeks:1] isEqualToDate:testDate], @"%s Failed", __PRETTY_FUNCTION__);
}
- (void)testDateByAddingDays{
    NSDate *testDate = [self.formatter dateFromString:@"2014 11 07 18:15:12.000"];
    XCTAssertEqual(YES, [[self.controlDate dateByAddingDays:2] isEqualToDate:testDate], @"%s Failed", __PRETTY_FUNCTION__);
}
- (void)testDateByAddingHours{
    NSDate *testDate = [self.formatter dateFromString:@"2014 11 06 6:15:12.000"];
    XCTAssertEqual(YES, [[self.controlDate dateByAddingHours:12] isEqualToDate:testDate], @"%s Failed", __PRETTY_FUNCTION__);
}
- (void)testDateByAddingMinutes{
    NSDate *testDate = [self.formatter dateFromString:@"2014 11 05 18:30:12.000"];
    XCTAssertEqual(YES, [[self.controlDate dateByAddingMinutes:15] isEqualToDate:testDate], @"%s Failed", __PRETTY_FUNCTION__);
}
- (void)testDateByAddingSeconds{
    NSDate *testDate = [self.formatter dateFromString:@"2014 11 05 18:16:12.000"];
    XCTAssertEqual(YES, [[self.controlDate dateByAddingSeconds:60] isEqualToDate:testDate], @"%s Failed", __PRETTY_FUNCTION__);
}

#pragma mark Date By Subtracting
- (void)testDateBySubtractingYears{
    NSDate *testDate = [self.formatter dateFromString:@"2000 11 05 18:15:12.000"];
    XCTAssertEqual(YES, [[self.controlDate dateBySubtractingYears:14] isEqualToDate:testDate], @"%s Failed", __PRETTY_FUNCTION__);
}
- (void)testDateBySubtractingMonths{
    NSDate *testDate = [self.formatter dateFromString:@"2014 4 05 18:15:12.000"];
    XCTAssertEqual(YES, [[self.controlDate dateBySubtractingMonths:7] isEqualToDate:testDate], @"%s Failed", __PRETTY_FUNCTION__);
}
- (void)testDateBySubtractingWeeks{
    NSDate *testDate = [self.formatter dateFromString:@"2014 10 29 18:15:12.000"];
    XCTAssertEqual(YES, [[self.controlDate dateBySubtractingWeeks:1] isEqualToDate:testDate], @"%s Failed", __PRETTY_FUNCTION__);
}
- (void)testDateBySubtractingDays{
    NSDate *testDate = [self.formatter dateFromString:@"2014 11 01 18:15:12.000"];
    XCTAssertEqual(YES, [[self.controlDate dateBySubtractingDays:4] isEqualToDate:testDate], @"%s Failed", __PRETTY_FUNCTION__);
}
- (void)testDateBySubtractingHours{
    NSDate *testDate = [self.formatter dateFromString:@"2014 11 05 00:15:12.000"];
    XCTAssertEqual(YES, [[self.controlDate dateBySubtractingHours:18] isEqualToDate:testDate], @"%s Failed", __PRETTY_FUNCTION__);
}
- (void)testDateBySubtractingMinutes{
    NSDate *testDate = [self.formatter dateFromString:@"2014 11 05 17:45:12.000"];
    XCTAssertEqual(YES, [[self.controlDate dateBySubtractingMinutes:30] isEqualToDate:testDate], @"%s Failed", __PRETTY_FUNCTION__);
}
- (void)testDateBySubtractingSeconds{
    NSDate *testDate = [self.formatter dateFromString:@"2014 11 05 18:14:12.000"];
    XCTAssertEqual(YES, [[self.controlDate dateBySubtractingSeconds:60] isEqualToDate:testDate], @"%s Failed", __PRETTY_FUNCTION__);
}

#pragma mark - Date Comparison
#pragma mark Time From
-(void)testYearsFrom{
    //Under a year
    NSDate *testDate = [self.formatter dateFromString:@"2014 11 12 18:15:12.000"];
    XCTAssertEqual(0, [self.controlDate yearsFrom:testDate], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Exactly a year
    NSDate *testDate2 = [self.formatter dateFromString:@"2015 11 05 18:15:12.000"];
    XCTAssertEqual(-1, [self.controlDate yearsFrom:testDate2], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Year number later, still less than a year
    NSDate *testDate3 = [self.formatter dateFromString:@"2015 11 04 18:15:12.000"];
    XCTAssertEqual(0, [self.controlDate yearsFrom:testDate3], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Year number earlier, still less than a year
    NSDate *testDate5 = [self.formatter dateFromString:@"2013 11 06 18:15:12.000"];
    XCTAssertEqual(0, [self.controlDate yearsFrom:testDate5], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Over a year earlier
    NSDate *testDate6 = [self.formatter dateFromString:@"2012 11 04 18:15:12.000"];
    XCTAssertEqual(2, [self.controlDate yearsFrom:testDate6], @"%s Failed", __PRETTY_FUNCTION__);
    
    ///Over a year later
    NSDate *testDate7 = [self.formatter dateFromString:@"2017 11 12 18:15:12.000"];
    XCTAssertEqual(-3, [self.controlDate yearsFrom:testDate7], @"%s Failed", __PRETTY_FUNCTION__);
    
    ///Over a year later, but less than a year in final comparison year
    NSDate *testDate8 = [self.formatter dateFromString:@"2017 11 3 18:15:12.000"];
    XCTAssertEqual(-2, [self.controlDate yearsFrom:testDate8], @"%s Failed", __PRETTY_FUNCTION__);
    
    ///Over a year earlier, but less than a year in final comparison year
    NSDate *testDate9 = [self.formatter dateFromString:@"2012 11 8 18:15:12.000"];
    XCTAssertEqual(1, [self.controlDate yearsFrom:testDate9], @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testMonthsFrom{
    //Under a month
    NSDate *testDate = [self.formatter dateFromString:@"2014 11 12 18:15:12.000"];
    XCTAssertEqual(0, [self.controlDate monthsFrom:testDate], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Exactly a month
    NSDate *testDate2 = [self.formatter dateFromString:@"2014 12 05 18:15:12.000"];
    XCTAssertEqual(-1, [self.controlDate monthsFrom:testDate2], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Year number later, still less than a year
    NSDate *testDate3 = [self.formatter dateFromString:@"2015 11 04 18:15:12.000"];
    XCTAssertEqual(-11, [self.controlDate monthsFrom:testDate3], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Year number earlier, still less than a year
    NSDate *testDate5 = [self.formatter dateFromString:@"2013 11 06 18:15:12.000"];
    XCTAssertEqual(11, [self.controlDate monthsFrom:testDate5], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Over a year earlier
    NSDate *testDate6 = [self.formatter dateFromString:@"2012 11 04 18:15:12.000"];
    XCTAssertEqual(24, [self.controlDate monthsFrom:testDate6], @"%s Failed", __PRETTY_FUNCTION__);
    
    ///Over a year later
    NSDate *testDate7 = [self.formatter dateFromString:@"2017 11 12 18:15:12.000"];
    XCTAssertEqual(-36, [self.controlDate monthsFrom:testDate7], @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testWeeksFrom{
    //Same week
    NSDate *testSameDate = [self.formatter dateFromString:@"2014 11 06 18:15:12.000"];
    XCTAssertEqual(0, [self.controlDate weeksFrom:testSameDate], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Same year
    NSDate *testDate = [self.formatter dateFromString:@"2014 11 12 18:15:12.000"];
    XCTAssertEqual(-1, [self.controlDate weeksFrom:testDate], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Eariler year
    NSDate *testDate2 = [self.formatter dateFromString:@"2013 11 12 18:15:12.000"];
    XCTAssertEqual(51, [self.controlDate weeksFrom:testDate2], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Later year
    NSDate *testDate3 = [self.formatter dateFromString:@"2015 11 12 18:15:12.000"];
    XCTAssertEqual(-53, [self.controlDate weeksFrom:testDate3], @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testDaysFrom{
    //Same day
    NSDate *testSameDate = [self.formatter dateFromString:@"2014 11 05 18:15:12.000"];
    XCTAssertEqual(0, [self.controlDate daysFrom:testSameDate], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Same year
    NSDate *testDate = [self.formatter dateFromString:@"2014 11 12 18:15:12.000"];
    XCTAssertEqual(-7, [self.controlDate daysFrom:testDate], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Eariler year
    NSDate *testDate2 = [self.formatter dateFromString:@"2013 11 12 18:15:12.000"];
    XCTAssertEqual(358, [self.controlDate daysFrom:testDate2], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Later year
    NSDate *testDate3 = [self.formatter dateFromString:@"2015 11 12 18:15:12.000"];
    XCTAssertEqual(-372, [self.controlDate daysFrom:testDate3], @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testHoursFrom{
    //Later
    NSDate *testDate = [self.formatter dateFromString:@"2014 11 05 20:15:12.000"];
    XCTAssertEqual(-2, [self.controlDate hoursFrom:testDate], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Earlier
    NSDate *testDate2 = [self.formatter dateFromString:@"2014 11 05 15:15:12.000"];
    XCTAssertEqual(3, [self.controlDate hoursFrom:testDate2], @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testMinutesFrom{
    //Later
    NSDate *testDate = [self.formatter dateFromString:@"2014 11 05 20:15:12.000"];
    XCTAssertEqual(-120, [self.controlDate minutesFrom:testDate], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Earlier
    NSDate *testDate2 = [self.formatter dateFromString:@"2014 11 05 15:15:12.000"];
    XCTAssertEqual(180, [self.controlDate minutesFrom:testDate2], @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testSecondsFrom{
    //Later
    NSDate *testDate = [self.formatter dateFromString:@"2014 11 05 20:15:12.000"];
    XCTAssertEqual(-7200, [self.controlDate secondsFrom:testDate], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Earlier
    NSDate *testDate2 = [self.formatter dateFromString:@"2014 11 05 15:15:12.000"];
    XCTAssertEqual(10800, [self.controlDate secondsFrom:testDate2], @"%s Failed", __PRETTY_FUNCTION__);
}

#pragma mark Earlier Than
-(void)testYearsEarlierThan{
    //Under a year
    NSDate *testDate = [self.formatter dateFromString:@"2014 11 12 18:15:12.000"];
    XCTAssertEqual(0, [self.controlDate yearsEarlierThan:testDate], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Exactly a year
    NSDate *testDate2 = [self.formatter dateFromString:@"2015 11 05 18:15:12.000"];
    XCTAssertEqual(1, [self.controlDate yearsEarlierThan:testDate2], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Year number later, still less than a year
    NSDate *testDate3 = [self.formatter dateFromString:@"2015 11 04 18:15:12.000"];
    XCTAssertEqual(0, [self.controlDate yearsEarlierThan:testDate3], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Year number earlier, still less than a year
    NSDate *testDate5 = [self.formatter dateFromString:@"2013 11 06 18:15:12.000"];
    XCTAssertEqual(0, [self.controlDate yearsEarlierThan:testDate5], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Over a year earlier
    NSDate *testDate6 = [self.formatter dateFromString:@"2012 11 04 18:15:12.000"];
    XCTAssertEqual(0, [self.controlDate yearsEarlierThan:testDate6], @"%s Failed", __PRETTY_FUNCTION__);
    
    ///Over a year later
    NSDate *testDate7 = [self.formatter dateFromString:@"2017 11 12 18:15:12.000"];
    XCTAssertEqual(3, [self.controlDate yearsEarlierThan:testDate7], @"%s Failed", __PRETTY_FUNCTION__);
    
    ///Over a year later, but less than a year in final comparison year
    NSDate *testDate8 = [self.formatter dateFromString:@"2017 11 3 18:15:12.000"];
    XCTAssertEqual(2, [self.controlDate yearsEarlierThan:testDate8], @"%s Failed", __PRETTY_FUNCTION__);
    
    ///Over a year earlier, but less than a year in final comparison year
    NSDate *testDate9 = [self.formatter dateFromString:@"2012 11 8 18:15:12.000"];
    XCTAssertEqual(0, [self.controlDate yearsEarlierThan:testDate9], @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testMonthsEarlerThan{
    //Under a month
    NSDate *testDate = [self.formatter dateFromString:@"2014 11 12 18:15:12.000"];
    XCTAssertEqual(0, [self.controlDate monthsEarlierThan:testDate], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Exactly a month
    NSDate *testDate2 = [self.formatter dateFromString:@"2014 12 05 18:15:12.000"];
    XCTAssertEqual(1, [self.controlDate monthsEarlierThan:testDate2], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Year number later, still less than a year
    NSDate *testDate3 = [self.formatter dateFromString:@"2015 11 04 18:15:12.000"];
    XCTAssertEqual(11, [self.controlDate monthsEarlierThan:testDate3], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Year number earlier, still less than a year
    NSDate *testDate5 = [self.formatter dateFromString:@"2013 11 06 18:15:12.000"];
    XCTAssertEqual(0, [self.controlDate monthsEarlierThan:testDate5], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Over a year earlier
    NSDate *testDate6 = [self.formatter dateFromString:@"2012 11 04 18:15:12.000"];
    XCTAssertEqual(0, [self.controlDate monthsEarlierThan:testDate6], @"%s Failed", __PRETTY_FUNCTION__);
    
    ///Over a year later
    NSDate *testDate7 = [self.formatter dateFromString:@"2017 11 12 18:15:12.000"];
    XCTAssertEqual(36, [self.controlDate monthsEarlierThan:testDate7], @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testWeeksEarlierThan{
    //Same week
    NSDate *testSameDate = [self.formatter dateFromString:@"2014 11 06 18:15:12.000"];
    XCTAssertEqual(0, [self.controlDate weeksEarlierThan:testSameDate], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Same year
    NSDate *testDate = [self.formatter dateFromString:@"2014 11 12 18:15:12.000"];
    XCTAssertEqual(1, [self.controlDate weeksEarlierThan:testDate], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Eariler year
    NSDate *testDate2 = [self.formatter dateFromString:@"2013 11 12 18:15:12.000"];
    XCTAssertEqual(0, [self.controlDate weeksEarlierThan:testDate2], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Later year
    NSDate *testDate3 = [self.formatter dateFromString:@"2015 11 12 18:15:12.000"];
    XCTAssertEqual(53, [self.controlDate weeksEarlierThan:testDate3], @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testDaysEarlierThan{
    //Same day
    NSDate *testSameDate = [self.formatter dateFromString:@"2014 11 05 18:15:12.000"];
    XCTAssertEqual(0, [self.controlDate daysEarlierThan:testSameDate], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Same year
    NSDate *testDate = [self.formatter dateFromString:@"2014 11 12 18:15:12.000"];
    XCTAssertEqual(7, [self.controlDate daysEarlierThan:testDate], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Eariler year
    NSDate *testDate2 = [self.formatter dateFromString:@"2013 11 12 18:15:12.000"];
    XCTAssertEqual(0, [self.controlDate daysEarlierThan:testDate2], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Later year
    NSDate *testDate3 = [self.formatter dateFromString:@"2015 11 12 18:15:12.000"];
    XCTAssertEqual(372, [self.controlDate daysEarlierThan:testDate3], @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testHoursEarlierThan{
    //Later
    NSDate *testDate = [self.formatter dateFromString:@"2014 11 05 20:15:12.000"];
    XCTAssertEqual(2, [self.controlDate hoursEarlierThan:testDate], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Earlier
    NSDate *testDate2 = [self.formatter dateFromString:@"2014 11 05 15:15:12.000"];
    XCTAssertEqual(0, [self.controlDate hoursEarlierThan:testDate2], @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testMinutesEarlierThan{
    //Later
    NSDate *testDate = [self.formatter dateFromString:@"2014 11 05 20:15:12.000"];
    XCTAssertEqual(120, [self.controlDate minutesEarlierThan:testDate], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Earlier
    NSDate *testDate2 = [self.formatter dateFromString:@"2014 11 05 15:15:12.000"];
    XCTAssertEqual(0, [self.controlDate minutesEarlierThan:testDate2], @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testSecondsEarlierThan{
    //Later
    NSDate *testDate = [self.formatter dateFromString:@"2014 11 05 20:15:12.000"];
    XCTAssertEqual(7200, [self.controlDate secondsEarlierThan:testDate], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Earlier
    NSDate *testDate2 = [self.formatter dateFromString:@"2014 11 05 15:15:12.000"];
    XCTAssertEqual(0, [self.controlDate secondsEarlierThan:testDate2], @"%s Failed", __PRETTY_FUNCTION__);
}

#pragma mark Later Than
-(void)testYearsLaterThan{
    //Under a year
    NSDate *testDate = [self.formatter dateFromString:@"2014 11 12 18:15:12.000"];
    XCTAssertEqual(0, [self.controlDate yearsLaterThan:testDate], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Exactly a year later
    NSDate *testDate2 = [self.formatter dateFromString:@"2015 11 05 18:15:12.000"];
    XCTAssertEqual(0, [self.controlDate yearsLaterThan:testDate2], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Exactly a year earlier
    NSDate *testDate3 = [self.formatter dateFromString:@"2013 11 05 18:15:12.000"];
    XCTAssertEqual(1, [self.controlDate yearsLaterThan:testDate3], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Year number later, still less than a year
    NSDate *testDate4 = [self.formatter dateFromString:@"2015 11 04 18:15:12.000"];
    XCTAssertEqual(0, [self.controlDate yearsLaterThan:testDate4], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Year number earlier, still less than a year
    NSDate *testDate5 = [self.formatter dateFromString:@"2013 11 06 18:15:12.000"];
    XCTAssertEqual(0, [self.controlDate yearsLaterThan:testDate5], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Over a year earlier
    NSDate *testDate6 = [self.formatter dateFromString:@"2012 11 04 18:15:12.000"];
    XCTAssertEqual(2, [self.controlDate yearsLaterThan:testDate6], @"%s Failed", __PRETTY_FUNCTION__);
    
    ///Over a year later
    NSDate *testDate7 = [self.formatter dateFromString:@"2017 11 12 18:15:12.000"];
    XCTAssertEqual(0, [self.controlDate yearsLaterThan:testDate7], @"%s Failed", __PRETTY_FUNCTION__);
    
    ///Over a year later, but less than a year in final comparison year
    NSDate *testDate8 = [self.formatter dateFromString:@"2017 11 3 18:15:12.000"];
    XCTAssertEqual(0, [self.controlDate yearsLaterThan:testDate8], @"%s Failed", __PRETTY_FUNCTION__);
    
    ///Over a year earlier, but less than a year in final comparison year
    NSDate *testDate9 = [self.formatter dateFromString:@"2012 11 8 18:15:12.000"];
    XCTAssertEqual(1, [self.controlDate yearsLaterThan:testDate9], @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testMonthsLaterThan{
    //Under a month
    NSDate *testDate = [self.formatter dateFromString:@"2014 11 12 18:15:12.000"];
    XCTAssertEqual(0, [self.controlDate monthsLaterThan:testDate], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Exactly a month
    NSDate *testDate2 = [self.formatter dateFromString:@"2014 12 05 18:15:12.000"];
    XCTAssertEqual(0, [self.controlDate monthsLaterThan:testDate2], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Year number later, still less than a year
    NSDate *testDate3 = [self.formatter dateFromString:@"2015 11 04 18:15:12.000"];
    XCTAssertEqual(0, [self.controlDate monthsLaterThan:testDate3], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Year number earlier, still less than a year
    NSDate *testDate5 = [self.formatter dateFromString:@"2013 11 06 18:15:12.000"];
    XCTAssertEqual(11, [self.controlDate monthsLaterThan:testDate5], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Over a year earlier
    NSDate *testDate6 = [self.formatter dateFromString:@"2012 11 04 18:15:12.000"];
    XCTAssertEqual(24, [self.controlDate monthsLaterThan:testDate6], @"%s Failed", __PRETTY_FUNCTION__);
    
    ///Over a year later
    NSDate *testDate7 = [self.formatter dateFromString:@"2017 11 12 18:15:12.000"];
    XCTAssertEqual(0, [self.controlDate monthsLaterThan:testDate7], @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testWeeksLaterThan{
    //Same week
    NSDate *testSameDate = [self.formatter dateFromString:@"2014 11 06 18:15:12.000"];
    XCTAssertEqual(0, [self.controlDate weeksLaterThan:testSameDate], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Same year later
    NSDate *testDate = [self.formatter dateFromString:@"2014 11 12 18:15:12.000"];
    XCTAssertEqual(0, [self.controlDate weeksLaterThan:testDate], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Same year earlier
    NSDate *testDate2 = [self.formatter dateFromString:@"2014 10 24 18:15:12.000"];
    XCTAssertEqual(1, [self.controlDate weeksLaterThan:testDate2], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Eariler year
    NSDate *testDate3 = [self.formatter dateFromString:@"2013 11 12 18:15:12.000"];
    XCTAssertEqual(51, [self.controlDate weeksLaterThan:testDate3], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Later year
    NSDate *testDate4 = [self.formatter dateFromString:@"2015 11 12 18:15:12.000"];
    XCTAssertEqual(0, [self.controlDate weeksLaterThan:testDate4], @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testDaysLaterThan{
    //Same day
    NSDate *testSameDate = [self.formatter dateFromString:@"2014 11 05 18:15:12.000"];
    XCTAssertEqual(0, [self.controlDate daysLaterThan:testSameDate], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Same year later
    NSDate *testDate = [self.formatter dateFromString:@"2014 11 12 18:15:12.000"];
    XCTAssertEqual(0, [self.controlDate daysLaterThan:testDate], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Same year earlier
    NSDate *testDate2 = [self.formatter dateFromString:@"2014 11 3 18:15:12.000"];
    XCTAssertEqual(2, [self.controlDate daysLaterThan:testDate2], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Eariler year
    NSDate *testDate3 = [self.formatter dateFromString:@"2013 11 12 18:15:12.000"];
    XCTAssertEqual(358, [self.controlDate daysLaterThan:testDate3], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Later year
    NSDate *testDate4 = [self.formatter dateFromString:@"2015 11 12 18:15:12.000"];
    XCTAssertEqual(0, [self.controlDate daysLaterThan:testDate4], @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testHoursLaterThan{
    //Later
    NSDate *testDate = [self.formatter dateFromString:@"2014 11 05 20:15:12.000"];
    XCTAssertEqual(0, [self.controlDate hoursLaterThan:testDate], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Earlier
    NSDate *testDate2 = [self.formatter dateFromString:@"2014 11 05 15:15:12.000"];
    XCTAssertEqual(3, [self.controlDate hoursLaterThan:testDate2], @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testMinutesLaterThan{
    //Later
    NSDate *testDate = [self.formatter dateFromString:@"2014 11 05 20:15:12.000"];
    XCTAssertEqual(0, [self.controlDate minutesLaterThan:testDate], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Earlier
    NSDate *testDate2 = [self.formatter dateFromString:@"2014 11 05 15:15:12.000"];
    XCTAssertEqual(180, [self.controlDate minutesLaterThan:testDate2], @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testSecondsLaterThan{
    //Later
    NSDate *testDate = [self.formatter dateFromString:@"2014 11 05 20:15:12.000"];
    XCTAssertEqual(0, [self.controlDate secondsLaterThan:testDate], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Earlier
    NSDate *testDate2 = [self.formatter dateFromString:@"2014 11 05 15:15:12.000"];
    XCTAssertEqual(10800, [self.controlDate secondsLaterThan:testDate2], @"%s Failed", __PRETTY_FUNCTION__);
}

#pragma mark Comparators
-(void)testIsEarlierThan{
    //Later
    NSDate *testDate = [self.formatter dateFromString:@"2014 11 05 20:15:12.000"];
    XCTAssertEqual(YES, [self.controlDate isEarlierThan:testDate], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Earlier
    NSDate *testDate2 = [self.formatter dateFromString:@"2014 11 05 15:15:12.000"];
    XCTAssertEqual(NO, [self.controlDate isEarlierThan:testDate2], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Same
    XCTAssertEqual(NO, [self.controlDate isEarlierThan:self.controlDate], @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testIsLaterThan{
    //Later
    NSDate *testDate = [self.formatter dateFromString:@"2014 11 05 20:15:12.000"];
    XCTAssertEqual(NO, [self.controlDate isLaterThan:testDate], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Earlier
    NSDate *testDate2 = [self.formatter dateFromString:@"2014 11 05 15:15:12.000"];
    XCTAssertEqual(YES, [self.controlDate isLaterThan:testDate2], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Same
    XCTAssertEqual(NO, [self.controlDate isLaterThan:self.controlDate], @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testisEarlierThanOrEqualTo{
    //Later
    NSDate *testDate = [self.formatter dateFromString:@"2014 11 05 20:15:12.000"];
    XCTAssertEqual(YES, [self.controlDate isEarlierThanOrEqualTo:testDate], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Earlier
    NSDate *testDate2 = [self.formatter dateFromString:@"2014 11 05 15:15:12.000"];
    XCTAssertEqual(NO, [self.controlDate isEarlierThanOrEqualTo:testDate2], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Same
    XCTAssertEqual(YES, [self.controlDate isEarlierThanOrEqualTo:self.controlDate], @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testIsLaterOrEqualToDate{
    //Later
    NSDate *testDate = [self.formatter dateFromString:@"2014 11 05 20:15:12.000"];
    XCTAssertEqual(NO, [self.controlDate isLaterThanOrEqualTo:testDate], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Earlier
    NSDate *testDate2 = [self.formatter dateFromString:@"2014 11 05 15:15:12.000"];
    XCTAssertEqual(YES, [self.controlDate isLaterThanOrEqualTo:testDate2], @"%s Failed", __PRETTY_FUNCTION__);
    
    //Same
    XCTAssertEqual(YES, [self.controlDate isLaterThanOrEqualTo:self.controlDate], @"%s Failed", __PRETTY_FUNCTION__);
}

@end
