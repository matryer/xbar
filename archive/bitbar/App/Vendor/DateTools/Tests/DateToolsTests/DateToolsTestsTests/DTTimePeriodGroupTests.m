//
//  DTTimePeriodGroupTests.m
//  DateToolsExample
//
//  Created by Matthew York on 3/22/14.
//
//

#import <XCTest/XCTest.h>
#import "DTTimePeriodCollection.h"
#import "DTTimePeriodChain.h"

@interface DTTimePeriodGroupTests : XCTestCase
@property NSDateFormatter *formatter;
@property DTTimePeriodCollection *controlCollection;
@end

@implementation DTTimePeriodGroupTests

- (void)setUp
{
    [super setUp];
    
    //Initialize control DTTimePeriodChain
    self.controlCollection = [[DTTimePeriodCollection alloc] init];
    
    //Initialize formatter
    self.formatter = [[NSDateFormatter alloc] init];
    [self.formatter setDateFormat:@"yyyy MM dd HH:mm:ss.SSS"];
    
    //Create test DTTimePeriods that are 1 year long
    DTTimePeriod *firstPeriod = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2014 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2015 11 05 18:15:12.000"]];
    DTTimePeriod *secondPeriod = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2015 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2016 11 05 18:15:12.000"]];
    DTTimePeriod *thirdPeriod = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2016 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2017 11 05 18:15:12.000"]];
    DTTimePeriod *fourthPeriod = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2015 4 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2017 4 05 18:15:12.000"]];
    
    //Add test periods
    [self.controlCollection addTimePeriod:firstPeriod];
    [self.controlCollection addTimePeriod:secondPeriod];
    [self.controlCollection addTimePeriod:thirdPeriod];
    [self.controlCollection addTimePeriod:fourthPeriod];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


#pragma mark - Group Info
-(void)testDurationInYears{
    XCTAssertEqual(3, self.controlCollection.durationInYears,  @"%s Failed", __PRETTY_FUNCTION__);
}

-(void)testDurationInWeeks{
    XCTAssertEqual(156, self.controlCollection.durationInWeeks,  @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testDurationInDays{
    XCTAssertEqual(1096, self.controlCollection.durationInDays,  @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testDurationInHours{
    XCTAssertEqual(26304, self.controlCollection.durationInHours,  @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testDurationInMinutes{
    XCTAssertEqual(1578240, self.controlCollection.durationInMinutes,  @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testDurationInSeconds{
    XCTAssertEqual(94694400, self.controlCollection.durationInSeconds,  @"%s Failed", __PRETTY_FUNCTION__);
}

#pragma mark - Comparison
-(void)testHasSameCharacteristicsAs{
    DTTimePeriodCollection *collectionSame = [[DTTimePeriodCollection alloc] init];
    DTTimePeriodChain *chain = [[DTTimePeriodChain alloc] init];
    
    //Create test DTTimePeriods to construct same as control
    DTTimePeriod *firstPeriod = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2014 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2015 11 05 18:15:12.000"]];
    DTTimePeriod *secondPeriod = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2015 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2016 11 05 18:15:12.000"]];
    DTTimePeriod *thirdPeriod = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2016 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2017 11 05 18:15:12.000"]];
    DTTimePeriod *fourthPeriod = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2015 4 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2017 4 05 18:15:12.000"]];
    DTTimePeriod *alternateFourthPeriod = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2016 4 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2017 4 05 18:15:12.000"]];
    
    //Add test periods
    [collectionSame addTimePeriod:firstPeriod];
    [collectionSame addTimePeriod:secondPeriod];
    [collectionSame addTimePeriod:thirdPeriod];
    [collectionSame addTimePeriod:fourthPeriod];
    [chain addTimePeriod:firstPeriod];
    [chain addTimePeriod:secondPeriod];
    [chain addTimePeriod:thirdPeriod];
    [chain addTimePeriod:fourthPeriod];
    
    //Test same as control
    XCTAssertTrue([self.controlCollection hasSameCharacteristicsAs:collectionSame],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Test differnt chain
    XCTAssertFalse([self.controlCollection hasSameCharacteristicsAs:chain],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Test alternate
    [collectionSame removeTimePeriodAtIndex:3];
    [collectionSame addTimePeriod:alternateFourthPeriod];
    XCTAssertTrue([self.controlCollection hasSameCharacteristicsAs:collectionSame],  @"%s Failed", __PRETTY_FUNCTION__);
}

@end
