//
//  DTTimePeriodChainTests.m
//  DateToolsExample
//
//  Created by Matthew York on 3/21/14.
//
//

#import <XCTest/XCTest.h>
#import "DTTimePeriodChain.h"

@interface DTTimePeriodChainTests : XCTestCase
@property NSDateFormatter *formatter;
@property DTTimePeriodChain *controlChain;
@end

@implementation DTTimePeriodChainTests

- (void)setUp
{
    [super setUp];
    
    //Initialize control DTTimePeriodChain
    self.controlChain = [[DTTimePeriodChain alloc] init];
    
    //Initialize formatter
    self.formatter = [[NSDateFormatter alloc] init];
    [self.formatter setDateFormat:@"yyyy MM dd HH:mm:ss.SSS"];
    
    //Create test DTTimePeriods that are 1 year long
    DTTimePeriod *firstPeriod = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2014 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2015 11 05 18:15:12.000"]];
    DTTimePeriod *secondPeriod = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2015 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2016 11 05 18:15:12.000"]];
    DTTimePeriod *thirdPeriod = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2016 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2017 11 05 18:15:12.000"]];
    
    //Add test periods
    [self.controlChain addTimePeriod:firstPeriod];
    [self.controlChain addTimePeriod:secondPeriod];
    [self.controlChain addTimePeriod:thirdPeriod];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - Custom Init / Factory Chain
-(void)testInitsAndFactories{
    DTTimePeriodChain *initCompareChain = [[DTTimePeriodChain alloc] init];
    DTTimePeriodChain *factoryCompareChain = [DTTimePeriodChain chain];
    
    XCTAssertTrue([initCompareChain isEqualToChain:factoryCompareChain],  @"%s Failed", __PRETTY_FUNCTION__);
}

#pragma mark - Chain Existence Manipulation
-(void)testAddTimePeriod{
    //Create test chain
    DTTimePeriodChain *testChain = [DTTimePeriodChain chain];
    [testChain addTimePeriod:[DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2014 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2015 11 05 18:15:12.000"]]];
    [testChain addTimePeriod:[DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2015 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2016 11 05 18:15:12.000"]]];
    [testChain addTimePeriod:[DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2016 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2017 11 05 18:15:12.000"]]];
    
    //Check equal
    XCTAssertTrue([self.controlChain isEqualToChain:testChain],  @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testInsertTimePeriod{
    //Create test chain
    DTTimePeriodChain *testChain = [DTTimePeriodChain chain];
    [testChain addTimePeriod:[DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2014 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2015 11 05 18:15:12.000"]]];
    [testChain addTimePeriod:[DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2016 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2017 11 05 18:15:12.000"]]];
    [testChain insertTimePeriod:[DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2015 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2016 11 05 18:15:12.000"]] atInedx:1];
    
    //Check equal
    XCTAssertTrue([self.controlChain isEqualToChain:testChain],  @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testRemoveTimePeriodAtIndex{
    //Create test chain
    DTTimePeriodChain *testChain = [DTTimePeriodChain chain];
    [testChain addTimePeriod:[DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2014 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2015 11 05 18:15:12.000"]]];
    [testChain addTimePeriod:[DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2016 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2017 11 05 18:15:12.000"]]];
    
    [self.controlChain removeTimePeriodAtIndex:1];
    
    //Check equal
    XCTAssertTrue([self.controlChain isEqualToChain:testChain],  @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testRemoveLatestTimePeriod{
    //Create test chain
    DTTimePeriodChain *testChain = [DTTimePeriodChain chain];
    [testChain addTimePeriod:[DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2014 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2015 11 05 18:15:12.000"]]];
    [testChain addTimePeriod:[DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2015 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2016 11 05 18:15:12.000"]]];
    
    [self.controlChain removeLatestTimePeriod];
    
    //Check equal
    XCTAssertTrue([self.controlChain isEqualToChain:testChain],  @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testRemoveEarliestTimePeriod{
    //Create test chain
    DTTimePeriodChain *testChain = [DTTimePeriodChain chain];
    [testChain addTimePeriod:[DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2015 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2016 11 05 18:15:12.000"]]];
    [testChain addTimePeriod:[DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2016 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2017 11 05 18:15:12.000"]]];
    [testChain shiftEarlierWithSize:DTTimePeriodSizeSecond amount:[[DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2014 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2015 11 05 18:15:12.000"]] durationInSeconds]];
    
    [self.controlChain removeEarliestTimePeriod];
    
    //Check equal
    XCTAssertTrue([self.controlChain isEqualToChain:testChain],  @"%s Failed", __PRETTY_FUNCTION__);
}

#pragma mark - Chain Time Manipulation
-(void)testShiftEarlier{
    //Create test chain
    DTTimePeriodChain *testChainOriginal = [DTTimePeriodChain chain];
    [testChainOriginal addTimePeriod:[DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2014 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2015 11 05 18:15:12.000"]]];
    [testChainOriginal addTimePeriod:[DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2015 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2016 11 05 18:15:12.000"]]];
    [testChainOriginal addTimePeriod:[DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2016 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2017 11 05 18:15:12.000"]]];
    
    //Create test chain
    DTTimePeriodChain *testChain = [DTTimePeriodChain chain];
    [testChain addTimePeriod:[DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2012 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2013 11 05 18:15:12.000"]]];
    [testChain addTimePeriod:[DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2013 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2014 11 05 18:15:12.000"]]];
    [testChain addTimePeriod:[DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2014 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2015 11 05 18:15:12.000"]]];
    
    //Shift control chain
    [self.controlChain shiftEarlierWithSize:DTTimePeriodSizeYear amount:2];
    
    //Check equal
    XCTAssertTrue([self.controlChain isEqualToChain:testChain],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Check equal
    XCTAssertFalse([self.controlChain isEqualToChain:testChainOriginal],  @"%s Failed", __PRETTY_FUNCTION__);
}

-(void)testShiftLater{
    //Create test chain
    DTTimePeriodChain *testChainOriginal = [DTTimePeriodChain chain];
    [testChainOriginal addTimePeriod:[DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2014 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2015 11 05 18:15:12.000"]]];
    [testChainOriginal addTimePeriod:[DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2015 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2016 11 05 18:15:12.000"]]];
    [testChainOriginal addTimePeriod:[DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2016 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2017 11 05 18:15:12.000"]]];
    
    //Create test chain
    DTTimePeriodChain *testChain = [DTTimePeriodChain chain];
    [testChain addTimePeriod:[DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2016 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2017 11 05 18:15:12.000"]]];
    [testChain addTimePeriod:[DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2017 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2018 11 05 18:15:12.000"]]];
    [testChain addTimePeriod:[DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2018 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2019 11 05 18:15:12.000"]]];
    
    //Shift control chain
    [self.controlChain shiftLaterWithSize:DTTimePeriodSizeYear amount:2];
    
    //Check equal
    XCTAssertTrue([self.controlChain isEqualToChain:testChain],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Check equal
    XCTAssertFalse([self.controlChain isEqualToChain:testChainOriginal],  @"%s Failed", __PRETTY_FUNCTION__);
}

#pragma mark - Chain Relationship
-(void)testIsEqualToChain{
    //Create test chains
    DTTimePeriodChain *testChain = [DTTimePeriodChain chain];
    [testChain addTimePeriod:[DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2014 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2015 11 05 18:15:12.000"]]];
    [testChain addTimePeriod:[DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2015 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2016 11 05 18:15:12.000"]]];
    [testChain addTimePeriod:[DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2016 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2017 11 05 18:15:12.000"]]];
    
    
    DTTimePeriodChain *testChainOutOfOrder = [DTTimePeriodChain chain];
    [testChainOutOfOrder addTimePeriod:[DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2015 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2016 11 05 18:15:12.000"]]];
    [testChainOutOfOrder addTimePeriod:[DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2016 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2017 11 05 18:15:12.000"]]];
    [testChainOutOfOrder addTimePeriod:[DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2014 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2015 11 05 18:15:12.000"]]];
    
    //Check equal
    XCTAssertTrue([self.controlChain isEqualToChain:testChain],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Check unequal
    [testChain addTimePeriod:[DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2014 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2015 11 05 18:15:12.000"]]];
    XCTAssertFalse([self.controlChain isEqualToChain:testChain],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Check same periods out of order
    XCTAssertFalse([self.controlChain isEqualToChain:testChainOutOfOrder],  @"%s Failed", __PRETTY_FUNCTION__);
}

@end
