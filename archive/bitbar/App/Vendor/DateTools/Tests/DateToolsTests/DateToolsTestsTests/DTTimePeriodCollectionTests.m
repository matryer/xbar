//
//  DTTimePeriodCollectionTests.m
//  DateToolsExample
//
//  Created by Matthew York on 3/21/14.
//
//

#import <XCTest/XCTest.h>
#import "DTTimePeriodCollection.h"

@interface DTTimePeriodCollectionTests : XCTestCase
@property NSDateFormatter *formatter;
@property DTTimePeriodCollection *controlCollection;
@end

@implementation DTTimePeriodCollectionTests

- (void)setUp
{
    [super setUp];
    
    //Initialize control DTTimePeriodChain
    self.controlCollection = [[DTTimePeriodCollection alloc] init];
    
    //Initialize formatter
    self.formatter = [[NSDateFormatter alloc] init];
    [self.formatter setDateFormat:@"yyyy MM dd HH:mm:ss.SSS"];
    
    //Create test DTTimePeriods
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


#pragma mark - Custom Init / Factory Methods
-(void)testInitsAndFactories{
    DTTimePeriodCollection *initCompareCollection = [[DTTimePeriodCollection alloc] init];
    DTTimePeriodCollection *factoryCompareCollection = [DTTimePeriodCollection collection];
    
    XCTAssertTrue([initCompareCollection isEqualToCollection:factoryCompareCollection considerOrder:YES],  @"%s Failed", __PRETTY_FUNCTION__);
}

#pragma mark - Collection Manipulation
-(void)testAddTimePeriod{
    //Initialize control DTTimePeriodChain
    DTTimePeriodCollection *testCollection = [[DTTimePeriodCollection alloc] init];
    
    //Create test DTTimePeriods that are 1 year long
    DTTimePeriod *firstPeriod = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2014 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2015 11 05 18:15:12.000"]];
    DTTimePeriod *secondPeriod = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2015 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2016 11 05 18:15:12.000"]];
    DTTimePeriod *thirdPeriod = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2016 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2017 11 05 18:15:12.000"]];
    DTTimePeriod *fourthPeriod = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2015 4 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2017 4 05 18:15:12.000"]];
    
    //Add test periods
    [testCollection addTimePeriod:firstPeriod];
    [testCollection addTimePeriod:secondPeriod];
    [testCollection addTimePeriod:thirdPeriod];
    [testCollection addTimePeriod:fourthPeriod];
    
    XCTAssertTrue([self.controlCollection isEqualToCollection:testCollection considerOrder:YES],  @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testInsertTimePeriod{
    //Initialize control DTTimePeriodChain
    DTTimePeriodCollection *testCollection = [[DTTimePeriodCollection alloc] init];
    
    //Create test DTTimePeriods that are 1 year long
    DTTimePeriod *firstPeriod = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2014 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2015 11 05 18:15:12.000"]];
    DTTimePeriod *secondPeriod = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2015 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2016 11 05 18:15:12.000"]];
    DTTimePeriod *thirdPeriod = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2016 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2017 11 05 18:15:12.000"]];
    DTTimePeriod *fourthPeriod = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2015 4 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2017 4 05 18:15:12.000"]];
    
    //Add test periods
    [testCollection addTimePeriod:firstPeriod];
    [testCollection addTimePeriod:secondPeriod];
    [testCollection addTimePeriod:fourthPeriod];
    [testCollection insertTimePeriod:thirdPeriod atIndex:2];
    
    XCTAssertTrue([self.controlCollection isEqualToCollection:testCollection considerOrder:YES],  @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testRemoveTimePeriodAtIndex{
    //Initialize control DTTimePeriodChain
    DTTimePeriodCollection *testCollection = [[DTTimePeriodCollection alloc] init];
    
    //Create test DTTimePeriods that are 1 year long
    DTTimePeriod *firstPeriod = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2014 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2015 11 05 18:15:12.000"]];
    DTTimePeriod *thirdPeriod = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2016 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2017 11 05 18:15:12.000"]];
    DTTimePeriod *fourthPeriod = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2015 4 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2017 4 05 18:15:12.000"]];
    
    //Add test periods
    [testCollection addTimePeriod:firstPeriod];
    [testCollection addTimePeriod:thirdPeriod];
    [testCollection addTimePeriod:fourthPeriod];
    
    //Remove time period from control
    [self.controlCollection removeTimePeriodAtIndex:1];
    
    XCTAssertTrue([self.controlCollection isEqualToCollection:testCollection considerOrder:YES],  @"%s Failed", __PRETTY_FUNCTION__);
}

#pragma mark - Chain Time Manipulation
-(void)testShiftEarlier{
    //Create test chain
    DTTimePeriodCollection *testCollectionOriginal = [DTTimePeriodCollection collection];
    [testCollectionOriginal addTimePeriod:[DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2012 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2013 11 05 18:15:12.000"]]];
    [testCollectionOriginal addTimePeriod:[DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2013 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2014 11 05 18:15:12.000"]]];
    [testCollectionOriginal addTimePeriod:[DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2014 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2015 11 05 18:15:12.000"]]];
    [testCollectionOriginal addTimePeriod:[DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2013 4 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2015 4 05 18:15:12.000"]]];
    
    //Create test chain
    DTTimePeriodCollection *controlCopy = [self.controlCollection copy];
    
    //Shift control chain
    [self.controlCollection shiftEarlierWithSize:DTTimePeriodSizeYear amount:2];
    
    //Check equal
    XCTAssertTrue([self.controlCollection isEqualToCollection:testCollectionOriginal considerOrder:YES],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Check equal
    XCTAssertFalse([self.controlCollection isEqualToCollection:controlCopy considerOrder:YES],  @"%s Failed", __PRETTY_FUNCTION__);
}

-(void)testShiftLater{
    //Create test chain
    DTTimePeriodCollection *testCollectionOriginal = [DTTimePeriodCollection collection];
    [testCollectionOriginal addTimePeriod:[DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2016 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2017 11 05 18:15:12.000"]]];
    [testCollectionOriginal addTimePeriod:[DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2017 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2018 11 05 18:15:12.000"]]];
    [testCollectionOriginal addTimePeriod:[DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2018 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2019 11 05 18:15:12.000"]]];
    [testCollectionOriginal addTimePeriod:[DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2017 4 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2019 4 05 18:15:12.000"]]];
    
    //Create test chain
    DTTimePeriodCollection *controlCopy = [self.controlCollection copy];
    
    //Shift control chain
    [self.controlCollection shiftLaterWithSize:DTTimePeriodSizeYear amount:2];
    
    //Check equal
    XCTAssertTrue([self.controlCollection isEqualToCollection:testCollectionOriginal considerOrder:YES],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Check equal
    XCTAssertFalse([self.controlCollection isEqualToCollection:controlCopy considerOrder:YES],  @"%s Failed", __PRETTY_FUNCTION__);
}


#pragma mark - Sorting
-(void)testSortByStartAscending{
    //Create ordered array
    DTTimePeriodCollection *testCollectionOrdered = [DTTimePeriodCollection collection];
    [testCollectionOrdered addTimePeriod:[DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2014 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2015 11 05 18:15:12.000"]]];
    [testCollectionOrdered addTimePeriod:[DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2015 4 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2017 4 05 18:15:12.000"]]];
    [testCollectionOrdered addTimePeriod:[DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2015 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2016 11 05 18:15:12.000"]]];
    [testCollectionOrdered addTimePeriod:[DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2016 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2017 11 05 18:15:12.000"]]];
    
    //Sort control
    [self.controlCollection sortByStartAscending];
    
    XCTAssertTrue([self.controlCollection isEqualToCollection:testCollectionOrdered considerOrder:YES],  @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testSortByStartDescending{
    //Create ordered array
    DTTimePeriodCollection *testCollectionOrdered = [DTTimePeriodCollection collection];
    [testCollectionOrdered addTimePeriod:[DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2016 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2017 11 05 18:15:12.000"]]];
    [testCollectionOrdered addTimePeriod:[DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2015 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2016 11 05 18:15:12.000"]]];
    [testCollectionOrdered addTimePeriod:[DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2015 4 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2017 4 05 18:15:12.000"]]];
    [testCollectionOrdered addTimePeriod:[DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2014 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2015 11 05 18:15:12.000"]]];
    
    //Sort control
    [self.controlCollection sortByStartDescending];
    
    XCTAssertTrue([self.controlCollection isEqualToCollection:testCollectionOrdered considerOrder:YES],  @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testSortByEndAscending{
    //Create ordered array
    DTTimePeriodCollection *testCollectionOrdered = [DTTimePeriodCollection collection];
    [testCollectionOrdered addTimePeriod:[DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2014 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2015 11 05 18:15:12.000"]]];
    [testCollectionOrdered addTimePeriod:[DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2015 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2016 11 05 18:15:12.000"]]];
    [testCollectionOrdered addTimePeriod:[DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2015 4 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2017 4 05 18:15:12.000"]]];
    [testCollectionOrdered addTimePeriod:[DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2016 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2017 11 05 18:15:12.000"]]];
    
    //Sort control
    [self.controlCollection sortByEndAscending];
    
    XCTAssertTrue([self.controlCollection isEqualToCollection:testCollectionOrdered considerOrder:YES],  @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testSortByEndDescending{
    //Create ordered array
    DTTimePeriodCollection *testCollectionOrdered = [DTTimePeriodCollection collection];
    [testCollectionOrdered addTimePeriod:[DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2016 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2017 11 05 18:15:12.000"]]];
    [testCollectionOrdered addTimePeriod:[DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2015 4 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2017 4 05 18:15:12.000"]]];
    [testCollectionOrdered addTimePeriod:[DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2015 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2016 11 05 18:15:12.000"]]];
    [testCollectionOrdered addTimePeriod:[DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2014 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2015 11 05 18:15:12.000"]]];
    
    //Sort control
    [self.controlCollection sortByEndDescending];
    
    XCTAssertTrue([self.controlCollection isEqualToCollection:testCollectionOrdered considerOrder:YES],  @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testSortByDurationAscending{
    //Create some time periods to sort
    DTTimePeriod *period2Days = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2016 11 04 18:15:12.000"] endDate:[self.formatter dateFromString:@"2016 11 06 18:15:12.000"]];
    DTTimePeriod *period4Months = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2015 07 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2015 11 05 18:15:12.000"]];
    DTTimePeriod *period5Months = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2015 06 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2015 11 05 18:15:12.000"]];
    DTTimePeriod *period2years = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2015 4 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2017 4 05 18:15:12.000"]];
    
    //Create unordered array
    DTTimePeriodCollection *testCollectionUnordered = [DTTimePeriodCollection collection];
    [testCollectionUnordered addTimePeriod:period2years];
    [testCollectionUnordered addTimePeriod:period5Months];
    [testCollectionUnordered addTimePeriod:period4Months];
    [testCollectionUnordered addTimePeriod:period2Days];
    
    //Create ordered array
    DTTimePeriodCollection *testCollectionOrdered = [DTTimePeriodCollection collection];
    [testCollectionOrdered addTimePeriod:period2Days];
    [testCollectionOrdered addTimePeriod:period4Months];
    [testCollectionOrdered addTimePeriod:period5Months];
    [testCollectionOrdered addTimePeriod:period2years];
    
    //Sort unordered
    [testCollectionUnordered sortByDurationAscending];
    
    XCTAssertTrue([testCollectionUnordered isEqualToCollection:testCollectionOrdered considerOrder:YES],  @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testSortByDurationDescending{
    //Create some time periods to sort
    DTTimePeriod *period2Days = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2016 11 04 18:15:12.000"] endDate:[self.formatter dateFromString:@"2016 11 06 18:15:12.000"]];
    DTTimePeriod *period4Months = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2015 07 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2015 11 05 18:15:12.000"]];
    DTTimePeriod *period5Months = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2015 06 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2015 11 05 18:15:12.000"]];
    DTTimePeriod *period2years = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2015 4 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2017 4 05 18:15:12.000"]];
    
    //Create unordered array
    DTTimePeriodCollection *testCollectionUnordered = [DTTimePeriodCollection collection];
    [testCollectionUnordered addTimePeriod:period4Months];
    [testCollectionUnordered addTimePeriod:period2Days];
    [testCollectionUnordered addTimePeriod:period2years];
    [testCollectionUnordered addTimePeriod:period5Months];
    
    //Create ordered array
    DTTimePeriodCollection *testCollectionOrdered = [DTTimePeriodCollection collection];
    [testCollectionOrdered addTimePeriod:period2years];
    [testCollectionOrdered addTimePeriod:period5Months];
    [testCollectionOrdered addTimePeriod:period4Months];
    [testCollectionOrdered addTimePeriod:period2Days];
    
    //Sort unordered
    [testCollectionUnordered sortByDurationDescending];
    
    XCTAssertTrue([testCollectionUnordered isEqualToCollection:testCollectionOrdered considerOrder:YES],  @"%s Failed", __PRETTY_FUNCTION__);
}

#pragma mark - Collection Relationship
-(void)testPeriodsInside{
    //Check positve match
    DTTimePeriod *testPeriodMatch = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2014 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2015 11 06 18:15:12.000"]];
    DTTimePeriodCollection *testCollectionMatch = [DTTimePeriodCollection collection];
    [testCollectionMatch addTimePeriod:self.controlCollection[0]];
    
    XCTAssertTrue([testCollectionMatch isEqualToCollection:[self.controlCollection periodsInside:testPeriodMatch] considerOrder:YES],  @"%s Failed", __PRETTY_FUNCTION__);
    
    
    //Check too narrow
    DTTimePeriod *testPeriodNarrow = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2014 11 06 18:15:12.000"] endDate:[self.formatter dateFromString:@"2015 11 02 18:15:12.000"]];
    DTTimePeriodCollection *testCollectionNarrow = [DTTimePeriodCollection collection];
    
    XCTAssertTrue([testCollectionNarrow isEqualToCollection:[self.controlCollection periodsInside:testPeriodNarrow] considerOrder:YES],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Random no
    XCTAssertFalse([self.controlCollection isEqualToCollection:[self.controlCollection periodsInside:testPeriodMatch] considerOrder:YES],  @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testPeriodsIntersectedByDate{
    //Check positve match
    NSDate *testDate = [self.formatter dateFromString:@"2015 11 05 18:15:12.000"];
    DTTimePeriodCollection *testCollectionMatch = [DTTimePeriodCollection collection];
    [testCollectionMatch addTimePeriod:self.controlCollection[0]];
    [testCollectionMatch addTimePeriod:self.controlCollection[1]];
    [testCollectionMatch addTimePeriod:self.controlCollection[3]];
    
    XCTAssertTrue([testCollectionMatch isEqualToCollection:[self.controlCollection periodsIntersectedByDate:testDate] considerOrder:NO],  @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testPeriodsIntersectedByPeriod{
    //Check positve match
    DTTimePeriod *testPeriodMatch = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2014 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2015 11 05 18:15:12.000"]];
    DTTimePeriodCollection *testCollectionMatch = [DTTimePeriodCollection collection];
    [testCollectionMatch addTimePeriod:self.controlCollection[0]];
    [testCollectionMatch addTimePeriod:self.controlCollection[1]];
    [testCollectionMatch addTimePeriod:self.controlCollection[3]];
    
    XCTAssertTrue([testCollectionMatch isEqualToCollection:[self.controlCollection periodsIntersectedByPeriod:testPeriodMatch] considerOrder:NO],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Check too early
    DTTimePeriod *testPeriodEarly = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2012 11 06 18:15:12.000"] endDate:[self.formatter dateFromString:@"2013 11 02 18:15:12.000"]];
    DTTimePeriodCollection *testCollectionEarly = [DTTimePeriodCollection collection];
    
    XCTAssertTrue([testCollectionEarly isEqualToCollection:[self.controlCollection periodsIntersectedByPeriod:testPeriodEarly] considerOrder:NO],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Random no
    XCTAssertFalse([self.controlCollection isEqualToCollection:[self.controlCollection periodsIntersectedByPeriod:testPeriodMatch] considerOrder:NO],  @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testPeriodsOverlappedByPeriod{
    //Check positve match
    DTTimePeriod *testPeriodMatch = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2014 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2015 11 05 18:15:12.000"]];
    DTTimePeriodCollection *testCollectionMatch = [DTTimePeriodCollection collection];
    [testCollectionMatch addTimePeriod:self.controlCollection[0]];
    [testCollectionMatch addTimePeriod:self.controlCollection[3]];
    
    XCTAssertTrue([testCollectionMatch isEqualToCollection:[self.controlCollection periodsOverlappedByPeriod:testPeriodMatch] considerOrder:NO],  @"%s Failed", __PRETTY_FUNCTION__);
    
    
    //Check too early
    DTTimePeriod *testPeriodEarly = [DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2012 11 06 18:15:12.000"] endDate:[self.formatter dateFromString:@"2013 11 02 18:15:12.000"]];
    DTTimePeriodCollection *testCollectionEarly = [DTTimePeriodCollection collection];
    
    XCTAssertTrue([testCollectionEarly isEqualToCollection:[self.controlCollection periodsOverlappedByPeriod:testPeriodEarly] considerOrder:NO],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Random no
    XCTAssertFalse([self.controlCollection isEqualToCollection:[self.controlCollection periodsOverlappedByPeriod:testPeriodMatch] considerOrder:NO],  @"%s Failed", __PRETTY_FUNCTION__);
}
-(void)testIsEqualToCollection{
    //Create test chains
    DTTimePeriodCollection *testCollection = [DTTimePeriodCollection collection];
    [testCollection addTimePeriod:[DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2014 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2015 11 05 18:15:12.000"]]];
    [testCollection addTimePeriod:[DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2015 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2016 11 05 18:15:12.000"]]];
    [testCollection addTimePeriod:[DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2016 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2017 11 05 18:15:12.000"]]];
    [testCollection addTimePeriod:[DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2015 4 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2017 4 05 18:15:12.000"]]];
    
    
    DTTimePeriodCollection *testCollectionOutOfOrder = [DTTimePeriodCollection collection];
    [testCollectionOutOfOrder addTimePeriod:[DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2015 4 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2017 4 05 18:15:12.000"]]];
    [testCollectionOutOfOrder addTimePeriod:[DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2015 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2016 11 05 18:15:12.000"]]];
    [testCollectionOutOfOrder addTimePeriod:[DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2016 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2017 11 05 18:15:12.000"]]];
    [testCollectionOutOfOrder addTimePeriod:[DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2014 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2015 11 05 18:15:12.000"]]];
    
    //Check equal
    XCTAssertTrue([self.controlCollection isEqualToCollection:testCollection considerOrder:YES],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Check unequal
    [testCollection addTimePeriod:[DTTimePeriod timePeriodWithStartDate:[self.formatter dateFromString:@"2014 11 05 18:15:12.000"] endDate:[self.formatter dateFromString:@"2015 11 05 18:15:12.000"]]];
    XCTAssertFalse([self.controlCollection isEqualToCollection:testCollection considerOrder:NO],  @"%s Failed", __PRETTY_FUNCTION__);
    
    //Check same periods out of order
    XCTAssertTrue([self.controlCollection isEqualToCollection:testCollectionOutOfOrder considerOrder:NO],  @"%s Failed", __PRETTY_FUNCTION__);
    XCTAssertFalse([self.controlCollection isEqualToCollection:testCollectionOutOfOrder considerOrder:YES],  @"%s Failed", __PRETTY_FUNCTION__);
}

@end
