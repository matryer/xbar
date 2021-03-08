//
//  DTTimePeriodTests.m
//  DateToolsExample
//
//  Created by Matthew York on 3/19/14.
//
//

#import <XCTest/XCTest.h>
#import "DTTimePeriod.h"
#import "NSDate+DateTools.h"

@interface DTTimePeriodTests : XCTestCase
@property NSDateFormatter *formatter;
@property DTTimePeriod *controlTimePeriod;
@end

@implementation DTTimePeriodTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.controlTimePeriod = [[DTTimePeriod alloc] init];
    
    //Create TimePeriod that is 2 years long
     self.formatter = [[NSDateFormatter alloc] init];
    [self.formatter setDateFormat:@"yyyy MM dd HH:mm:ss.SSS"];
    self.controlTimePeriod.StartDate = [self.formatter dateFromString:@"2014 11 05 18:15:12.000"];
    self.controlTimePeriod.EndDate = [self.formatter dateFromString:@"2016 11 05 18:15:12.000"];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - Custom Init / Factory Methods
-(void)testBasicInitsAndFactoryMethods{
    //Basic init
    DTTimePeriod *testPeriodInit = [[DTTimePeriod alloc] initWithStartDate:self.controlTimePeriod.StartDate endDate:self.controlTimePeriod.EndDate];
    XCTAssertTrue([self.controlTimePeriod.StartDate isEqualToDate:testPeriodInit.StartDate] && [self.controlTimePeriod.EndDate isEqualToDate:testPeriodInit.EndDate],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Basic factory
    DTTimePeriod *testPeriodFactoryInit = [DTTimePeriod timePeriodWithStartDate:self.controlTimePeriod.StartDate endDate:self.controlTimePeriod.EndDate];
    XCTAssertTrue([self.controlTimePeriod.StartDate isEqualToDate:testPeriodFactoryInit.StartDate] && [self.controlTimePeriod.EndDate isEqualToDate:testPeriodFactoryInit.EndDate],  @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testFactoryStartingAt{
    //Test dates
    NSDate *startLaterSecond = [self.formatter dateFromString:@"2014 11 05 18:15:13.000"];
    NSDate *startLaterMinute = [self.formatter dateFromString:@"2014 11 05 18:16:12.000"];
    NSDate *startLaterHour = [self.formatter dateFromString:@"2014 11 05 19:15:12.000"];
    NSDate *startLaterDay = [self.formatter dateFromString:@"2014 11 06 18:15:12.000"];
    NSDate *startLaterWeek = [self.formatter dateFromString:@"2014 11 12 18:15:12.000"];
    NSDate *startLaterMonth = [self.formatter dateFromString:@"2014 12 05 18:15:12.000"];
    NSDate *startLaterYear = [self.formatter dateFromString:@"2015 11 05 18:15:12.000"];
    
    //Starting At
    //Second time period
    DTTimePeriod *testPeriodSecond  = [DTTimePeriod timePeriodWithSize:DTTimePeriodSizeSecond startingAt:self.controlTimePeriod.StartDate];
    XCTAssertTrue([testPeriodSecond.StartDate isEqualToDate:self.controlTimePeriod.StartDate] && [testPeriodSecond.EndDate isEqualToDate:startLaterSecond],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Minute time period
    DTTimePeriod *testPeriodMinute  = [DTTimePeriod timePeriodWithSize:DTTimePeriodSizeMinute startingAt:self.controlTimePeriod.StartDate];
    XCTAssertTrue([testPeriodMinute.StartDate isEqualToDate:self.controlTimePeriod.StartDate] && [testPeriodMinute.EndDate isEqualToDate:startLaterMinute],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Hour time period
    DTTimePeriod *testPeriodHour  = [DTTimePeriod timePeriodWithSize:DTTimePeriodSizeHour startingAt:self.controlTimePeriod.StartDate];
    XCTAssertTrue([testPeriodHour.StartDate isEqualToDate:self.controlTimePeriod.StartDate] && [testPeriodHour.EndDate isEqualToDate:startLaterHour],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Day time period
    DTTimePeriod *testPeriodDay  = [DTTimePeriod timePeriodWithSize:DTTimePeriodSizeDay startingAt:self.controlTimePeriod.StartDate];
    XCTAssertTrue([testPeriodDay.StartDate isEqualToDate:self.controlTimePeriod.StartDate] && [testPeriodDay.EndDate isEqualToDate:startLaterDay],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Week time period
    DTTimePeriod *testPeriodWeek  = [DTTimePeriod timePeriodWithSize:DTTimePeriodSizeWeek startingAt:self.controlTimePeriod.StartDate];
    XCTAssertTrue([testPeriodWeek.StartDate isEqualToDate:self.controlTimePeriod.StartDate] && [testPeriodWeek.EndDate isEqualToDate:startLaterWeek],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Month time period
    DTTimePeriod *testPeriodMonth  = [DTTimePeriod timePeriodWithSize:DTTimePeriodSizeMonth startingAt:self.controlTimePeriod.StartDate];
    XCTAssertTrue([testPeriodMonth.StartDate isEqualToDate:self.controlTimePeriod.StartDate] && [testPeriodMonth.EndDate isEqualToDate:startLaterMonth],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Year time period
    DTTimePeriod *testPeriodYear  = [DTTimePeriod timePeriodWithSize:DTTimePeriodSizeYear startingAt:self.controlTimePeriod.StartDate];
    XCTAssertTrue([testPeriodYear.StartDate isEqualToDate:self.controlTimePeriod.StartDate] && [testPeriodYear.EndDate isEqualToDate:startLaterYear],  @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testFactoryEndingAt {
    //Test End dates
    NSDate *endEarlierSecond = [self.formatter dateFromString:@"2016 11 05 18:15:11.000"];
    NSDate *endEarlierMinute = [self.formatter dateFromString:@"2016 11 05 18:14:12.000"];
    NSDate *endEarlierHour = [self.formatter dateFromString:@"2016 11 05 17:15:12.000"];
    NSDate *endEarlierDay = [self.formatter dateFromString:@"2016 11 04 18:15:12.000"];
    NSDate *endEarlierWeek = [self.formatter dateFromString:@"2016 10 29 18:15:12.000"];
    NSDate *endEarlierMonth = [self.formatter dateFromString:@"2016 10 05 18:15:12.000"];
    NSDate *endEarlierYear = [self.formatter dateFromString:@"2015 11 05 18:15:12.000"];
    
    //Ending At
    //Second time period
    DTTimePeriod *testPeriodSecond  = [DTTimePeriod timePeriodWithSize:DTTimePeriodSizeSecond endingAt:self.controlTimePeriod.EndDate];
    XCTAssertTrue([testPeriodSecond.StartDate isEqualToDate:endEarlierSecond] && [testPeriodSecond.EndDate isEqualToDate:self.controlTimePeriod.EndDate],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Minute time period
    DTTimePeriod *testPeriodMinute  = [DTTimePeriod timePeriodWithSize:DTTimePeriodSizeMinute endingAt:self.controlTimePeriod.EndDate];
    XCTAssertTrue([testPeriodMinute.StartDate isEqualToDate:endEarlierMinute] && [testPeriodMinute.EndDate isEqualToDate:self.controlTimePeriod.EndDate],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Hour time period
    DTTimePeriod *testPeriodHour  = [DTTimePeriod timePeriodWithSize:DTTimePeriodSizeHour endingAt:self.controlTimePeriod.EndDate];
    XCTAssertTrue([testPeriodHour.StartDate isEqualToDate:endEarlierHour] && [testPeriodHour.EndDate isEqualToDate:self.controlTimePeriod.EndDate],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Day time period
    DTTimePeriod *testPeriodDay  = [DTTimePeriod timePeriodWithSize:DTTimePeriodSizeDay endingAt:self.controlTimePeriod.EndDate];
    XCTAssertTrue([testPeriodDay.StartDate isEqualToDate:endEarlierDay] && [testPeriodDay.EndDate isEqualToDate:self.controlTimePeriod.EndDate],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Week time period
    DTTimePeriod *testPeriodWeek  = [DTTimePeriod timePeriodWithSize:DTTimePeriodSizeWeek endingAt:self.controlTimePeriod.EndDate];
    XCTAssertTrue([testPeriodWeek.StartDate isEqualToDate:endEarlierWeek] && [testPeriodWeek.EndDate isEqualToDate:self.controlTimePeriod.EndDate],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Month time period
    DTTimePeriod *testPeriodMonth  = [DTTimePeriod timePeriodWithSize:DTTimePeriodSizeMonth endingAt:self.controlTimePeriod.EndDate];
    XCTAssertTrue([testPeriodMonth.StartDate isEqualToDate:endEarlierMonth] && [testPeriodMonth.EndDate isEqualToDate:self.controlTimePeriod.EndDate],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Year time period
    DTTimePeriod *testPeriodYear  = [DTTimePeriod timePeriodWithSize:DTTimePeriodSizeYear endingAt:self.controlTimePeriod.EndDate];
    XCTAssertTrue([testPeriodYear.StartDate isEqualToDate:endEarlierYear] && [testPeriodYear.EndDate isEqualToDate:self.controlTimePeriod.EndDate],  @"%s Failed", __PRETTY_FUNCTION__);
}

#pragma mark - Time Period Information
-(void)testHasStartDate{
    //Has start date
    XCTAssertTrue([self.controlTimePeriod hasStartDate],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Deosn't have start date
    DTTimePeriod *testPeriod = [DTTimePeriod timePeriodWithStartDate:nil endDate:self.controlTimePeriod.EndDate];
    XCTAssertFalse([testPeriod hasStartDate],  @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testHasEndDate{
    //Has end date
    XCTAssertTrue([self.controlTimePeriod hasEndDate],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Deosn't have end date
    DTTimePeriod *testPeriod = [DTTimePeriod timePeriodWithStartDate:self.controlTimePeriod.StartDate endDate:nil];
    XCTAssertFalse([testPeriod hasEndDate],  @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testIsMoment{
    //Is moment
    DTTimePeriod *testPeriod = [DTTimePeriod timePeriodWithStartDate:self.controlTimePeriod.StartDate endDate:self.controlTimePeriod.StartDate];
    XCTAssertTrue(testPeriod.isMoment,  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Is not moment
    XCTAssertFalse(self.controlTimePeriod.isMoment,  @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testDurationInYears{
    XCTAssertEqual(2, [self.controlTimePeriod durationInYears],  @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testDurationInWeeks{
    XCTAssertEqual(104, [self.controlTimePeriod durationInWeeks],  @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testDurationInDays{
    XCTAssertEqual(731, [self.controlTimePeriod durationInDays],  @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testDurationInHours{
    DTTimePeriod *testPeriod = [DTTimePeriod timePeriodWithStartDate:self.controlTimePeriod.StartDate endDate:[self.controlTimePeriod.StartDate dateByAddingHours:4]];
    XCTAssertEqual(4, [testPeriod durationInHours],  @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testDurationInMinutes{
    DTTimePeriod *testPeriod = [DTTimePeriod timePeriodWithStartDate:self.controlTimePeriod.StartDate endDate:[self.controlTimePeriod.StartDate dateByAddingHours:4]];
    XCTAssertEqual(240, [testPeriod durationInMinutes],  @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testDurationInSeconds{
    DTTimePeriod *testPeriod = [DTTimePeriod timePeriodWithStartDate:self.controlTimePeriod.StartDate endDate:[self.controlTimePeriod.StartDate dateByAddingHours:4]];
    XCTAssertEqual(14400, [testPeriod durationInSeconds],  @"%s Failed", __PRETTY_FUNCTION__);
}

#pragma mark - Time Period Relationship
-(void)testIsSamePeriod{
    //Same
    XCTAssertTrue([self.controlTimePeriod isEqualToPeriod:self.controlTimePeriod],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Different ending
    DTTimePeriod *differentEndPeriod = [DTTimePeriod timePeriodWithStartDate:self.controlTimePeriod.StartDate endDate:[self.controlTimePeriod.EndDate dateByAddingYears:1]];
    XCTAssertFalse([self.controlTimePeriod isEqualToPeriod:differentEndPeriod],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Different beginning
    DTTimePeriod *differentStartPeriod = [DTTimePeriod timePeriodWithStartDate:[self.controlTimePeriod.StartDate dateBySubtractingYears:1] endDate:self.controlTimePeriod.EndDate];
    XCTAssertFalse([self.controlTimePeriod isEqualToPeriod:differentStartPeriod],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Both endings different
    DTTimePeriod *differentStartAndEndPeriod = [DTTimePeriod timePeriodWithStartDate:[self.controlTimePeriod.StartDate dateBySubtractingYears:1] endDate:[self.controlTimePeriod.EndDate dateBySubtractingWeeks:1]];
    XCTAssertFalse([self.controlTimePeriod isEqualToPeriod:differentStartAndEndPeriod],  @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testIsInside{
    //POSITIVE MATCHES
    //Test exact match
    DTTimePeriod *testTimePeriodExact = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2014 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2016 11 05 18:15:12.000"]];
    XCTAssertTrue([testTimePeriodExact isInside:self.controlTimePeriod],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Test same start
    DTTimePeriod *testTimePeriodSameStart = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2014 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2015 11 05 18:15:12.000"]];
    XCTAssertTrue([testTimePeriodSameStart isInside:self.controlTimePeriod],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Test same end
    DTTimePeriod *testTimePeriodSameEnd = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2015 12 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2016 11 05 18:15:12.000"]];
    XCTAssertTrue([testTimePeriodSameEnd isInside:self.controlTimePeriod],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Test completely inside
    DTTimePeriod *testTimePeriodCompletelyInside = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2015 12 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2016 04 05 18:15:12.000"]];
    XCTAssertTrue([testTimePeriodCompletelyInside isInside:self.controlTimePeriod],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //NEGATIVE MATCHES
    //Test before
    DTTimePeriod *testTimePeriodBefore = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2014 11 02 18:15:12.000"] endDate:[self.formatter dateFromString:@"2014 11 04 18:15:12.000"]];
    XCTAssertFalse([testTimePeriodBefore isInside:self.controlTimePeriod],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Test end same as start
    DTTimePeriod *testTimePeriodEndSameStart = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2013 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2014 11 05 18:15:12.000"]];
    XCTAssertFalse([testTimePeriodEndSameStart isInside:self.controlTimePeriod],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Test end inside
    DTTimePeriod *testTimePeriodEndInside = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2014 11 02 18:15:12.000"] endDate:[self.formatter dateFromString:@"2014 11 07 18:15:12.000"]];
    XCTAssertFalse([testTimePeriodEndInside isInside:self.controlTimePeriod],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Test start inside
    DTTimePeriod *testTimePeriodStartInside = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2014 11 07 18:15:12.000"] endDate:[self.formatter dateFromString:@"2016 12 05 18:15:12.000"]];
    XCTAssertFalse([testTimePeriodStartInside isInside:self.controlTimePeriod],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Test start same as end
    DTTimePeriod *testTimePeriodStartSameEnd = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2016 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2016 11 10 18:15:12.000"]];
    XCTAssertFalse([testTimePeriodStartSameEnd isInside:self.controlTimePeriod],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Test after
    DTTimePeriod *testTimePeriodAfter = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2016 12 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2016 12 10 18:15:12.000"]];
    XCTAssertFalse([testTimePeriodAfter isInside:self.controlTimePeriod],  @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testContains{
    //POSITIVE MATCHES
    //Test exact match
    DTTimePeriod *testTimePeriodExact = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2014 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2016 11 05 18:15:12.000"]];
    XCTAssertTrue([self.controlTimePeriod contains:testTimePeriodExact],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Test same start
    DTTimePeriod *testTimePeriodSameStart = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2014 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2015 11 05 18:15:12.000"]];
    XCTAssertTrue([self.controlTimePeriod contains:testTimePeriodSameStart],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Test same end
    DTTimePeriod *testTimePeriodSameEnd = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2015 12 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2016 11 05 18:15:12.000"]];
    XCTAssertTrue([self.controlTimePeriod contains:testTimePeriodSameEnd],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Test completely inside
    DTTimePeriod *testTimePeriodCompletelyInside = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2015 12 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2016 04 05 18:15:12.000"]];
    XCTAssertTrue([self.controlTimePeriod contains:testTimePeriodCompletelyInside],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //NEGATIVE MATCHES
    //Test before
    DTTimePeriod *testTimePeriodBefore = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2014 11 02 18:15:12.000"] endDate:[self.formatter dateFromString:@"2014 11 04 18:15:12.000"]];
    XCTAssertFalse([self.controlTimePeriod contains:testTimePeriodBefore],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Test end same as start
    DTTimePeriod *testTimePeriodEndSameStart = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2013 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2014 11 05 18:15:12.000"]];
    XCTAssertFalse([self.controlTimePeriod contains:testTimePeriodEndSameStart],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Test end inside
    DTTimePeriod *testTimePeriodEndInside = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2014 11 02 18:15:12.000"] endDate:[self.formatter dateFromString:@"2014 11 07 18:15:12.000"]];
    XCTAssertFalse([self.controlTimePeriod contains:testTimePeriodEndInside],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Test start inside
    DTTimePeriod *testTimePeriodStartInside = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2014 11 07 18:15:12.000"] endDate:[self.formatter dateFromString:@"2016 12 05 18:15:12.000"]];
    XCTAssertFalse([self.controlTimePeriod contains:testTimePeriodStartInside],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Test start same as end
    DTTimePeriod *testTimePeriodStartSameEnd = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2016 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2016 11 10 18:15:12.000"]];
    XCTAssertFalse([self.controlTimePeriod contains:testTimePeriodStartSameEnd],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Test after
    DTTimePeriod *testTimePeriodAfter = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2016 12 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2016 12 10 18:15:12.000"]];
    XCTAssertFalse([self.controlTimePeriod contains:testTimePeriodAfter],  @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testOverlapsWith{
    //POSITIVE MATCHES
    //Test exact match
    DTTimePeriod *testTimePeriodExact = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2014 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2016 11 05 18:15:12.000"]];
    XCTAssertTrue([self.controlTimePeriod overlapsWith:testTimePeriodExact],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Test same start
    DTTimePeriod *testTimePeriodSameStart = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2014 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2015 11 05 18:15:12.000"]];
    XCTAssertTrue([self.controlTimePeriod overlapsWith:testTimePeriodSameStart],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Test same end
    DTTimePeriod *testTimePeriodSameEnd = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2015 12 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2016 11 05 18:15:12.000"]];
    XCTAssertTrue([self.controlTimePeriod overlapsWith:testTimePeriodSameEnd],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Test completely inside
    DTTimePeriod *testTimePeriodCompletelyInside = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2015 12 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2016 04 05 18:15:12.000"]];
    XCTAssertTrue([self.controlTimePeriod overlapsWith:testTimePeriodCompletelyInside],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Test start inside
    DTTimePeriod *testTimePeriodStartInside = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2014 11 07 18:15:12.000"] endDate:[self.formatter dateFromString:@"2016 12 05 18:15:12.000"]];
    XCTAssertTrue([self.controlTimePeriod overlapsWith:testTimePeriodStartInside],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Test end inside
    DTTimePeriod *testTimePeriodEndInside = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2014 11 02 18:15:12.000"] endDate:[self.formatter dateFromString:@"2014 11 07 18:15:12.000"]];
    XCTAssertTrue([self.controlTimePeriod overlapsWith:testTimePeriodEndInside],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //NEGATIVE MATCHES
    //Test before
    DTTimePeriod *testTimePeriodBefore = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2014 11 02 18:15:12.000"] endDate:[self.formatter dateFromString:@"2014 11 04 18:15:12.000"]];
    XCTAssertFalse([self.controlTimePeriod overlapsWith:testTimePeriodBefore],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Test end same as start
    DTTimePeriod *testTimePeriodEndSameStart = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2013 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2014 11 05 18:15:12.000"]];
    XCTAssertFalse([self.controlTimePeriod overlapsWith:testTimePeriodEndSameStart],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Test start same as end
    DTTimePeriod *testTimePeriodStartSameEnd = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2016 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2016 11 10 18:15:12.000"]];
    XCTAssertFalse([self.controlTimePeriod overlapsWith:testTimePeriodStartSameEnd],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Test after
    DTTimePeriod *testTimePeriodAfter = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2016 12 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2016 12 10 18:15:12.000"]];
    XCTAssertFalse([self.controlTimePeriod overlapsWith:testTimePeriodAfter],  @"%s Failed", __PRETTY_FUNCTION__);
    
}
-(void)testIntersects{
    //POSITIVE MATCHES
    //Test exact match
    DTTimePeriod *testTimePeriodExact = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2014 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2016 11 05 18:15:12.000"]];
    XCTAssertTrue([self.controlTimePeriod intersects:testTimePeriodExact],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Test same start
    DTTimePeriod *testTimePeriodSameStart = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2014 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2015 11 05 18:15:12.000"]];
    XCTAssertTrue([self.controlTimePeriod intersects:testTimePeriodSameStart],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Test same end
    DTTimePeriod *testTimePeriodSameEnd = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2015 12 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2016 11 05 18:15:12.000"]];
    XCTAssertTrue([self.controlTimePeriod intersects:testTimePeriodSameEnd],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Test completely inside
    DTTimePeriod *testTimePeriodCompletelyInside = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2015 12 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2016 04 05 18:15:12.000"]];
    XCTAssertTrue([self.controlTimePeriod intersects:testTimePeriodCompletelyInside],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Test start inside
    DTTimePeriod *testTimePeriodStartInside = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2014 11 07 18:15:12.000"] endDate:[self.formatter dateFromString:@"2016 12 05 18:15:12.000"]];
    XCTAssertTrue([self.controlTimePeriod intersects:testTimePeriodStartInside],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Test end inside
    DTTimePeriod *testTimePeriodEndInside = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2014 11 02 18:15:12.000"] endDate:[self.formatter dateFromString:@"2014 11 07 18:15:12.000"]];
    XCTAssertTrue([self.controlTimePeriod intersects:testTimePeriodEndInside],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Test end same as start
    DTTimePeriod *testTimePeriodEndSameStart = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2013 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2014 11 05 18:15:12.000"]];
    XCTAssertTrue([self.controlTimePeriod intersects:testTimePeriodEndSameStart],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Test start same as end
    DTTimePeriod *testTimePeriodStartSameEnd = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2016 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2016 11 10 18:15:12.000"]];
    XCTAssertTrue([self.controlTimePeriod intersects:testTimePeriodStartSameEnd],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //NEGATIVE MATCHES
    //Test before
    DTTimePeriod *testTimePeriodBefore = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2014 11 02 18:15:12.000"] endDate:[self.formatter dateFromString:@"2014 11 04 18:15:12.000"]];
    XCTAssertFalse([self.controlTimePeriod intersects:testTimePeriodBefore],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Test after
    DTTimePeriod *testTimePeriodAfter = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2016 12 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2016 12 10 18:15:12.000"]];
    XCTAssertFalse([self.controlTimePeriod intersects:testTimePeriodAfter],  @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testRelationToPeriod{
    //Test exact match
    DTTimePeriod *testTimePeriodExact = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2014 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2016 11 05 18:15:12.000"]];
    XCTAssertEqual(DTTimePeriodRelationExactMatch, [testTimePeriodExact relationToPeriod:self.controlTimePeriod],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Test same start
    DTTimePeriod *testTimePeriodSameStart = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2014 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2015 11 05 18:15:12.000"]];
    XCTAssertEqual(DTTimePeriodRelationInsideStartTouching, [testTimePeriodSameStart relationToPeriod:self.controlTimePeriod],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Test same end
    DTTimePeriod *testTimePeriodSameEnd = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2015 12 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2016 11 05 18:15:12.000"]];
    XCTAssertEqual(DTTimePeriodRelationInsideEndTouching, [testTimePeriodSameEnd relationToPeriod:self.controlTimePeriod],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Test completely inside
    DTTimePeriod *testTimePeriodCompletelyInside = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2015 12 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2016 04 05 18:15:12.000"]];
    XCTAssertEqual(DTTimePeriodRelationInside, [testTimePeriodCompletelyInside relationToPeriod:self.controlTimePeriod],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //NEGATIVE MATCHES
    //Test before
    DTTimePeriod *testTimePeriodBefore = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2014 11 02 18:15:12.000"] endDate:[self.formatter dateFromString:@"2014 11 04 18:15:12.000"]];
    XCTAssertEqual(DTTimePeriodRelationBefore, [testTimePeriodBefore relationToPeriod:self.controlTimePeriod],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Test end same as start
    DTTimePeriod *testTimePeriodEndSameStart = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2013 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2014 11 05 18:15:12.000"]];
    XCTAssertEqual(DTTimePeriodRelationEndTouching, [testTimePeriodEndSameStart relationToPeriod:self.controlTimePeriod],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Test end inside
    DTTimePeriod *testTimePeriodEndInside = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2014 11 02 18:15:12.000"] endDate:[self.formatter dateFromString:@"2014 11 07 18:15:12.000"]];
    XCTAssertEqual(DTTimePeriodRelationEndInside, [testTimePeriodEndInside relationToPeriod:self.controlTimePeriod],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Test start inside
    DTTimePeriod *testTimePeriodStartInside = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2014 11 07 18:15:12.000"] endDate:[self.formatter dateFromString:@"2016 12 05 18:15:12.000"]];
    XCTAssertEqual(DTTimePeriodRelationStartInside, [testTimePeriodStartInside relationToPeriod:self.controlTimePeriod],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Test start same as end
    DTTimePeriod *testTimePeriodStartSameEnd = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2016 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2016 11 10 18:15:12.000"]];
    XCTAssertEqual(DTTimePeriodRelationStartTouching, [testTimePeriodStartSameEnd relationToPeriod:self.controlTimePeriod],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Test after
    DTTimePeriod *testTimePeriodAfter = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2016 12 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2016 12 10 18:15:12.000"]];
    XCTAssertEqual(DTTimePeriodRelationAfter, [testTimePeriodAfter relationToPeriod:self.controlTimePeriod],  @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testGapBetween{
    //We are going to treat some of these as False=noGap and True=gap
    
    //No Gap Same
    XCTAssertFalse([self.controlTimePeriod gapBetween:self.controlTimePeriod],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //No Gap End Inside
    DTTimePeriod *testPeriodNoGap = [DTTimePeriod timePeriodWithStartDate:[self.controlTimePeriod.StartDate dateBySubtractingDays:1] endDate:[self.controlTimePeriod.EndDate dateBySubtractingDays:1]];
    XCTAssertFalse([self.controlTimePeriod gapBetween:testPeriodNoGap],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Gap receiver early
    DTTimePeriod *testPeriodReceiverEarly = [DTTimePeriod timePeriodWithSize:DTTimePeriodSizeWeek startingAt:[self.controlTimePeriod.EndDate dateByAddingYears:1]];
    XCTAssertTrue([self.controlTimePeriod gapBetween:testPeriodReceiverEarly],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Gap parameter early
    DTTimePeriod *testPeriodParameterEarly = [DTTimePeriod timePeriodWithSize:DTTimePeriodSizeWeek endingAt:[self.controlTimePeriod.StartDate dateBySubtractingYears:1]];
    XCTAssertTrue([self.controlTimePeriod gapBetween:testPeriodParameterEarly],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Gap of 1 minute
    DTTimePeriod *testPeriodParameter1MinuteEarly = [DTTimePeriod timePeriodWithSize:DTTimePeriodSizeSecond endingAt:[self.controlTimePeriod.StartDate dateBySubtractingMinutes:1]];
    XCTAssertEqual(60, [self.controlTimePeriod gapBetween:testPeriodParameter1MinuteEarly],  @"%s Failed", __PRETTY_FUNCTION__);
}

#pragma mark - Date Relationships
-(void)testContainsDate{
    NSDate *testDateBefore = [self.formatter dateFromString:@"2014 10 05 18:15:12.000"];
    NSDate *testDateBetween = [self.formatter dateFromString:@"2015 11 05 18:15:12.000"];
    NSDate *testDateAfter = [self.formatter dateFromString:@"2016 12 05 18:15:12.000"];
    
    //Test before
    XCTAssertFalse([self.controlTimePeriod containsDate:testDateBefore interval:DTTimePeriodIntervalOpen],  @"%s Failed", __PRETTY_FUNCTION__);
    XCTAssertFalse([self.controlTimePeriod containsDate:testDateBefore interval:DTTimePeriodIntervalClosed],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Test on start date
    XCTAssertFalse([self.controlTimePeriod containsDate:self.controlTimePeriod.StartDate interval:DTTimePeriodIntervalOpen],  @"%s Failed", __PRETTY_FUNCTION__);
    XCTAssertTrue([self.controlTimePeriod containsDate:self.controlTimePeriod.StartDate interval:DTTimePeriodIntervalClosed],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Test in middle
    XCTAssertTrue([self.controlTimePeriod containsDate:testDateBetween interval:DTTimePeriodIntervalClosed],  @"%s Failed", __PRETTY_FUNCTION__);
    XCTAssertTrue([self.controlTimePeriod containsDate:testDateBetween interval:DTTimePeriodIntervalClosed],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Test on end date
    XCTAssertFalse([self.controlTimePeriod containsDate:self.controlTimePeriod.EndDate interval:DTTimePeriodIntervalOpen],  @"%s Failed", __PRETTY_FUNCTION__);
    XCTAssertTrue([self.controlTimePeriod containsDate:self.controlTimePeriod.EndDate interval:DTTimePeriodIntervalClosed],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Test after
    XCTAssertFalse([self.controlTimePeriod containsDate:testDateAfter interval:DTTimePeriodIntervalOpen],  @"%s Failed", __PRETTY_FUNCTION__);
    XCTAssertFalse([self.controlTimePeriod containsDate:testDateAfter interval:DTTimePeriodIntervalClosed],  @"%s Failed", __PRETTY_FUNCTION__);
}


#pragma mark - Period Manipulation
#pragma mark Shift Earlier
-(void)testShiftSecondEarlier{
    NSDate *startEarlierSecond = [self.formatter dateFromString:@"2014 11 05 18:15:11.000"];
    NSDate *endEarlierSecond = [self.formatter dateFromString:@"2016 11 05 18:15:11.000"];
    
    //Second time period
    DTTimePeriod *testPeriod  = [DTTimePeriod timePeriodWithStartDate:startEarlierSecond endDate:endEarlierSecond];
    [self.controlTimePeriod shiftEarlierWithSize:DTTimePeriodSizeSecond];
    XCTAssertTrue([testPeriod.StartDate isEqualToDate:self.controlTimePeriod.StartDate] && [testPeriod.EndDate isEqualToDate:self.controlTimePeriod.EndDate],  @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testShiftMinuteEarlier{
    NSDate *startEarlier = [self.formatter dateFromString:@"2014 11 05 18:14:12.000"];
    NSDate *endEarlier = [self.formatter dateFromString:@"2016 11 05 18:14:12.000"];
    
    DTTimePeriod *testPeriod  = [DTTimePeriod timePeriodWithStartDate:startEarlier endDate:endEarlier];
    [self.controlTimePeriod shiftEarlierWithSize:DTTimePeriodSizeMinute];
    XCTAssertTrue([testPeriod.StartDate isEqualToDate:self.controlTimePeriod.StartDate] && [testPeriod.EndDate isEqualToDate:self.controlTimePeriod.EndDate],  @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testShiftHourEarlier{
    NSDate *startEarlier = [self.formatter dateFromString:@"2014 11 05 17:15:12.000"];
    NSDate *endEarlier = [self.formatter dateFromString:@"2016 11 05 17:15:12.000"];
    
    DTTimePeriod *testPeriod  = [DTTimePeriod timePeriodWithStartDate:startEarlier endDate:endEarlier];
    [self.controlTimePeriod shiftEarlierWithSize:DTTimePeriodSizeHour];
    XCTAssertTrue([testPeriod.StartDate isEqualToDate:self.controlTimePeriod.StartDate] && [testPeriod.EndDate isEqualToDate:self.controlTimePeriod.EndDate],  @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testShiftDayEarlier{
    NSDate *startEarlier = [self.formatter dateFromString:@"2014 11 04 18:15:12.000"];
    NSDate *endEarlier = [self.formatter dateFromString:@"2016 11 04 18:15:12.000"];
    
    DTTimePeriod *testPeriod  = [DTTimePeriod timePeriodWithStartDate:startEarlier endDate:endEarlier];
    [self.controlTimePeriod shiftEarlierWithSize:DTTimePeriodSizeDay];
    XCTAssertTrue([testPeriod.StartDate isEqualToDate:self.controlTimePeriod.StartDate] && [testPeriod.EndDate isEqualToDate:self.controlTimePeriod.EndDate],  @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testShiftWeekEarlier{
    NSDate *startEarlier = [self.formatter dateFromString:@"2014 10 29 18:15:12.000"];
    NSDate *endEarlier = [self.formatter dateFromString:@"2016 10 29 18:15:12.000"];
    
    DTTimePeriod *testPeriod  = [DTTimePeriod timePeriodWithStartDate:startEarlier endDate:endEarlier];
    [self.controlTimePeriod shiftEarlierWithSize:DTTimePeriodSizeWeek];
    XCTAssertTrue([testPeriod.StartDate isEqualToDate:self.controlTimePeriod.StartDate] && [testPeriod.EndDate isEqualToDate:self.controlTimePeriod.EndDate],  @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testShiftMonthEarlier{
    NSDate *startEarlier = [self.formatter dateFromString:@"2014 10 05 18:15:12.000"];
    NSDate *endEarlier = [self.formatter dateFromString:@"2016 10 05 18:15:12.000"];
    
    DTTimePeriod *testPeriod  = [DTTimePeriod timePeriodWithStartDate:startEarlier endDate:endEarlier];
    [self.controlTimePeriod shiftEarlierWithSize:DTTimePeriodSizeMonth];
    XCTAssertTrue([testPeriod.StartDate isEqualToDate:self.controlTimePeriod.StartDate] && [testPeriod.EndDate isEqualToDate:self.controlTimePeriod.EndDate],  @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testShiftYearEarlier{
    NSDate *startEarlier = [self.formatter dateFromString:@"2013 11 05 18:15:12.000"];
    NSDate *endEarlier = [self.formatter dateFromString:@"2015 11 05 18:15:12.000"];
    
    DTTimePeriod *testPeriod  = [DTTimePeriod timePeriodWithStartDate:startEarlier endDate:endEarlier];
    [self.controlTimePeriod shiftEarlierWithSize:DTTimePeriodSizeYear];
    XCTAssertTrue([testPeriod.StartDate isEqualToDate:self.controlTimePeriod.StartDate] && [testPeriod.EndDate isEqualToDate:self.controlTimePeriod.EndDate],  @"%s Failed", __PRETTY_FUNCTION__);
}

#pragma mark Shift Later
-(void)testShiftSecondLater{
    NSDate *startLater = [self.formatter dateFromString:@"2014 11 05 18:15:13.000"];
    NSDate *endLater = [self.formatter dateFromString:@"2016 11 05 18:15:13.000"];
    
    //Second time period
    DTTimePeriod *testPeriod  = [DTTimePeriod timePeriodWithStartDate:startLater endDate:endLater];
    [self.controlTimePeriod shiftLaterWithSize:DTTimePeriodSizeSecond];
    XCTAssertTrue([testPeriod.StartDate isEqualToDate:self.controlTimePeriod.StartDate] && [testPeriod.EndDate isEqualToDate:self.controlTimePeriod.EndDate],  @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testShiftMinuteLater{
    NSDate *startLater = [self.formatter dateFromString:@"2014 11 05 18:16:12.000"];
    NSDate *endLater = [self.formatter dateFromString:@"2016 11 05 18:16:12.000"];
    
    DTTimePeriod *testPeriod  = [DTTimePeriod timePeriodWithStartDate:startLater endDate:endLater];
    [self.controlTimePeriod shiftLaterWithSize:DTTimePeriodSizeMinute];
    XCTAssertTrue([testPeriod.StartDate isEqualToDate:self.controlTimePeriod.StartDate] && [testPeriod.EndDate isEqualToDate:self.controlTimePeriod.EndDate],  @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testShiftHourLater{
    NSDate *startLater = [self.formatter dateFromString:@"2014 11 05 19:15:12.000"];
    NSDate *endLater = [self.formatter dateFromString:@"2016 11 05 19:15:12.000"];
    
    DTTimePeriod *testPeriod  = [DTTimePeriod timePeriodWithStartDate:startLater endDate:endLater];
    [self.controlTimePeriod shiftLaterWithSize:DTTimePeriodSizeHour];
    XCTAssertTrue([testPeriod.StartDate isEqualToDate:self.controlTimePeriod.StartDate] && [testPeriod.EndDate isEqualToDate:self.controlTimePeriod.EndDate],  @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testShiftDayLater{
    NSDate *startLater = [self.formatter dateFromString:@"2014 11 06 18:15:12.000"];
    NSDate *endLater = [self.formatter dateFromString:@"2016 11 06 18:15:12.000"];
    
    DTTimePeriod *testPeriod  = [DTTimePeriod timePeriodWithStartDate:startLater endDate:endLater];
    [self.controlTimePeriod shiftLaterWithSize:DTTimePeriodSizeDay];
    XCTAssertTrue([testPeriod.StartDate isEqualToDate:self.controlTimePeriod.StartDate] && [testPeriod.EndDate isEqualToDate:self.controlTimePeriod.EndDate],  @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testShiftWeekLater{
    NSDate *startLater = [self.formatter dateFromString:@"2014 11 12 18:15:12.000"];
    NSDate *endLater = [self.formatter dateFromString:@"2016 11 12 18:15:12.000"];
    
    DTTimePeriod *testPeriod  = [DTTimePeriod timePeriodWithStartDate:startLater endDate:endLater];
    [self.controlTimePeriod shiftLaterWithSize:DTTimePeriodSizeWeek];
    XCTAssertTrue([testPeriod.StartDate isEqualToDate:self.controlTimePeriod.StartDate] && [testPeriod.EndDate isEqualToDate:self.controlTimePeriod.EndDate],  @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testShiftMonthLater{
    NSDate *startLater = [self.formatter dateFromString:@"2014 12 05 18:15:12.000"];
    NSDate *endLater = [self.formatter dateFromString:@"2016 12 05 18:15:12.000"];
    
    DTTimePeriod *testPeriod  = [DTTimePeriod timePeriodWithStartDate:startLater endDate:endLater];
    [self.controlTimePeriod shiftLaterWithSize:DTTimePeriodSizeMonth];
    XCTAssertTrue([testPeriod.StartDate isEqualToDate:self.controlTimePeriod.StartDate] && [testPeriod.EndDate isEqualToDate:self.controlTimePeriod.EndDate],  @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testShiftYearLater{
    NSDate *startLater = [self.formatter dateFromString:@"2015 11 05 18:15:12.000"];
    NSDate *endLater = [self.formatter dateFromString:@"2017 11 05 18:15:12.000"];
    
    DTTimePeriod *testPeriod  = [DTTimePeriod timePeriodWithStartDate:startLater endDate:endLater];
    [self.controlTimePeriod shiftLaterWithSize:DTTimePeriodSizeYear];
    XCTAssertTrue([testPeriod.StartDate isEqualToDate:self.controlTimePeriod.StartDate] && [testPeriod.EndDate isEqualToDate:self.controlTimePeriod.EndDate],  @"%s Failed", __PRETTY_FUNCTION__);
}

#pragma mark Lengthen / Shorten
-(void)testLengthenAnchorStart{
    //Test dates
    NSDate *lengthenedEnd = [self.formatter dateFromString:@"2016 11 05 18:15:14.000"];
    
    DTTimePeriod *testPeriod  = [DTTimePeriod timePeriodWithStartDate:self.controlTimePeriod.StartDate endDate:lengthenedEnd];
    [self.controlTimePeriod lengthenWithAnchorDate:DTTimePeriodAnchorStart size:DTTimePeriodSizeSecond amount:2];
    XCTAssertTrue([testPeriod.StartDate isEqualToDate:self.controlTimePeriod.StartDate] && [testPeriod.EndDate isEqualToDate:self.controlTimePeriod.EndDate],  @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testLengthenAnchorCenter{
    //Test dates
    NSDate *lengthenedStart = [self.formatter dateFromString:@"2014 11 05 18:15:11.000"];
    NSDate *lengthenedEnd = [self.formatter dateFromString:@"2016 11 05 18:15:13.000"];
    
    DTTimePeriod *testPeriod  = [DTTimePeriod timePeriodWithStartDate:lengthenedStart endDate:lengthenedEnd];
    [self.controlTimePeriod lengthenWithAnchorDate:DTTimePeriodAnchorCenter size:DTTimePeriodSizeSecond amount:2];
    XCTAssertTrue([testPeriod.StartDate isEqualToDate:self.controlTimePeriod.StartDate] && [testPeriod.EndDate isEqualToDate:self.controlTimePeriod.EndDate],  @"%s Failed", __PRETTY_FUNCTION__);
    
}
-(void)testLengthenAnchorEnd{
    //Test dates
    NSDate *lengthenedStart = [self.formatter dateFromString:@"2014 11 05 18:15:10.000"];
    
    DTTimePeriod *testPeriod  = [DTTimePeriod timePeriodWithStartDate:lengthenedStart endDate:self.controlTimePeriod.EndDate];
    [self.controlTimePeriod lengthenWithAnchorDate:DTTimePeriodAnchorEnd size:DTTimePeriodSizeSecond amount:2];
    XCTAssertTrue([testPeriod.StartDate isEqualToDate:self.controlTimePeriod.StartDate] && [testPeriod.EndDate isEqualToDate:self.controlTimePeriod.EndDate],  @"%s Failed", __PRETTY_FUNCTION__);
    
}
-(void)testShortenAnchorStart{
    //Test dates
    NSDate *shortenedEnd = [self.formatter dateFromString:@"2016 11 05 18:15:10.000"];
    
    DTTimePeriod *testPeriod  = [DTTimePeriod timePeriodWithStartDate:self.controlTimePeriod.StartDate endDate:shortenedEnd];
    [self.controlTimePeriod shortenWithAnchorDate:DTTimePeriodAnchorStart size:DTTimePeriodSizeSecond amount:2];
    XCTAssertTrue([testPeriod.StartDate isEqualToDate:self.controlTimePeriod.StartDate] && [testPeriod.EndDate isEqualToDate:self.controlTimePeriod.EndDate],  @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testShortenAnchorCenter{
    //Test dates
    NSDate *shortenedStart = [self.formatter dateFromString:@"2014 11 05 18:15:13.000"];
    NSDate *shortenedEnd = [self.formatter dateFromString:@"2016 11 05 18:15:11.000"];
    
    DTTimePeriod *testPeriod  = [DTTimePeriod timePeriodWithStartDate:shortenedStart endDate:shortenedEnd];
    [self.controlTimePeriod shortenWithAnchorDate:DTTimePeriodAnchorCenter size:DTTimePeriodSizeSecond amount:2];
    XCTAssertTrue([testPeriod.StartDate isEqualToDate:self.controlTimePeriod.StartDate] && [testPeriod.EndDate isEqualToDate:self.controlTimePeriod.EndDate],  @"%s Failed", __PRETTY_FUNCTION__);
    
}
-(void)testShortenAnchorEnd{
    //Test dates
    NSDate *shortenedStart = [self.formatter dateFromString:@"2014 11 05 18:15:14.000"];
    
    DTTimePeriod *testPeriod  = [DTTimePeriod timePeriodWithStartDate:shortenedStart endDate:self.controlTimePeriod.EndDate];
    [self.controlTimePeriod shortenWithAnchorDate:DTTimePeriodAnchorEnd size:DTTimePeriodSizeSecond amount:2];
    XCTAssertTrue([testPeriod.StartDate isEqualToDate:self.controlTimePeriod.StartDate] && [testPeriod.EndDate isEqualToDate:self.controlTimePeriod.EndDate],  @"%s Failed", __PRETTY_FUNCTION__);
    
}


@end
