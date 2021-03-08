// Copyright (C) 2014 by Matthew York
//
// Permission is hereby granted, free of charge, to any
// person obtaining a copy of this software and
// associated documentation files (the "Software"), to
// deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge,
// publish, distribute, sublicense, and/or sell copies of the
// Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall
// be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
// BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
// ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "DTTimePeriodCollection.h"
#import "DTError.h"
#import "NSDate+DateTools.h"

@implementation DTTimePeriodCollection

#pragma mark - Custom Init / Factory Methods
/**
 *  Initializes a new instance of DTTimePeriodCollection
 *
 *  @return DTTimePeriodCollection
 */
+(DTTimePeriodCollection *)collection{
    return [[DTTimePeriodCollection alloc] init];
}

#pragma mark - Collection Manipulation
/**
 *  Adds a time period to the reciever.
 *
 *  @param period DTTimePeriod - The time period to add to the collection
 */
-(void)addTimePeriod:(DTTimePeriod *)period{
    if ([period isKindOfClass:[DTTimePeriod class]]) {
        [periods addObject:period];
        
        //Set object's variables with updated array values
        [self updateVariables];
    }
    else {
        [DTError throwBadTypeException:period expectedClass:[DTTimePeriod class]];
    }
}

/**
 *  Inserts a time period to the receiver at a given index.
 *
 *  @param period DTTimePeriod - The time period to insert into the collection
 *  @param index  NSInteger - The index in the collection the time period is to be added at
 */
-(void)insertTimePeriod:(DTTimePeriod *)period atIndex:(NSInteger)index{
    if ([period class] != [DTTimePeriod class]) {
        [DTError throwBadTypeException:period expectedClass:[DTTimePeriod class]];
        return;
    }
    
    if (index >= 0 && index < periods.count) {
        [periods insertObject:period atIndex:index];
        
        //Set object's variables with updated array values
        [self updateVariables];
    }
    else {
        [DTError throwInsertOutOfBoundsException:index array:periods];
    }
}

/**
 *  Removes the time period at a given index from the collection
 *
 *  @param index NSInteger - The index in the collection the time period is to be removed from
 */
-(void)removeTimePeriodAtIndex:(NSInteger)index{
    if (index >= 0 && index < periods.count) {
        [periods removeObjectAtIndex:index];
        
        //Update the object variables
        if (periods.count > 0) {
            //Set object's variables with updated array values
            [self updateVariables];
        }
        else {
            [self setVariablesNil];
        }
    }
    else {
        [DTError throwRemoveOutOfBoundsException:index array:periods];
    }
}



#pragma mark - Sorting
/**
 *  Sorts the time periods in the collection by earliest start date to latest start date.
 */
-(void)sortByStartAscending{
    [periods sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [((DTTimePeriod *) obj1).StartDate compare:((DTTimePeriod *) obj2).StartDate];
    }];
}

/**
 *  Sorts the time periods in the collection by latest start date to earliest start date.
 */
-(void)sortByStartDescending{
    [periods sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [((DTTimePeriod *) obj2).StartDate compare:((DTTimePeriod *) obj1).StartDate];
    }];
}

/**
 *  Sorts the time periods in the collection by earliest end date to latest end date.
 */
-(void)sortByEndAscending{
    [periods sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [((DTTimePeriod *) obj1).EndDate compare:((DTTimePeriod *) obj2).EndDate];
    }];
}

/**
 *  Sorts the time periods in the collection by latest end date to earliest end date.
 */
-(void)sortByEndDescending{
    [periods sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [((DTTimePeriod *) obj2).EndDate compare:((DTTimePeriod *) obj1).EndDate];
    }];
}

/**
 *  Sorts the time periods in the collection by how much time they span. Sorts smallest durations to longest.
 */
-(void)sortByDurationAscending{
    [periods sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if (((DTTimePeriod *) obj1).durationInSeconds < ((DTTimePeriod *) obj2).durationInSeconds) {
            return NSOrderedAscending;
        }
        else {
            return NSOrderedDescending;
        }
        return NSOrderedSame;
    }];
}

/**
 *  Sorts the time periods in the collection by how much time they span. Sorts longest durations to smallest.
 */
-(void)sortByDurationDescending{
    [periods sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if (((DTTimePeriod *) obj1).durationInSeconds > ((DTTimePeriod *) obj2).durationInSeconds) {
            return NSOrderedAscending;
        }
        else {
            return NSOrderedDescending;
        }
        return NSOrderedSame;
    }];
}

#pragma mark - Collection Relationship
/**
 *  Returns an instance of DTTimePeriodCollection with all the time periods in the receiver that fall inside a given time period.
 *  Time periods of the receiver must have a start date and end date within the closed interval of the period provided to be included.
 *
 *  @param period DTTimePeriod - The time period to check against the receiver's time periods.
 *
 *  @return DTTimePeriodCollection
 */
-(DTTimePeriodCollection *)periodsInside:(DTTimePeriod *)period{
    DTTimePeriodCollection *collection = [[DTTimePeriodCollection alloc] init];
    
    if ([period isKindOfClass:[DTTimePeriod class]]) {
        [periods enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([((DTTimePeriod *) obj) isInside:period]) {
                [collection addTimePeriod:obj];
            }
        }];
    }
    else {
        [DTError throwBadTypeException:period expectedClass:[DTTimePeriod class]];
    }
    
    return collection;
}

/**
 *  Returns an instance of DTTimePeriodCollection with all the time periods in the receiver that intersect a given date.
 *  Time periods of the receiver must have a start date earlier than or equal to the comparison date and an end date later than or equal to the comparison date to be included
 *
 *  @param date NSDate - The date to check against the receiver's time periods
 *
 *  @return DTTimePeriodCollection
 */
-(DTTimePeriodCollection *)periodsIntersectedByDate:(NSDate *)date{
    DTTimePeriodCollection *collection = [[DTTimePeriodCollection alloc] init];
    
    if ([date isKindOfClass:[NSDate class]]) {
        [periods enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([((DTTimePeriod *) obj) containsDate:date interval:DTTimePeriodIntervalClosed]) {
                [collection addTimePeriod:obj];
            }
        }];
    }
    else {
        [DTError throwBadTypeException:date expectedClass:[NSDate class]];
    }
    
    return collection;
}

/**
 *  Returns an instance of DTTimePeriodCollection with all the time periods in the receiver that intersect a given time period.
 *  Intersection with the given time period includes other time periods that simply touch it. (i.e. one's start date is equal to another's end date)
 *
 *  @param period DTTimePeriod - The time period to check against the receiver's time periods.
 *
 *  @return DTTimePeriodCollection
 */
-(DTTimePeriodCollection *)periodsIntersectedByPeriod:(DTTimePeriod *)period{
    DTTimePeriodCollection *collection = [[DTTimePeriodCollection alloc] init];
    
    if ([period isKindOfClass:[DTTimePeriod class]]) {
        [periods enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([((DTTimePeriod *) obj) intersects:period]) {
                [collection addTimePeriod:obj];
            }
        }];
    }
    else {
        [DTError throwBadTypeException:period expectedClass:[DTTimePeriod class]];
    }
    
    return collection;
}

/**
 *  Returns an instance of DTTimePeriodCollection with all the time periods in the receiver that overlap a given time period.
 *  Overlap with the given time period does NOT include other time periods that simply touch it. (i.e. one's start date is equal to another's end date)
 *
 *  @param period DTTimePeriod - The time period to check against the receiver's time periods.
 *
 *  @return DTTimePeriodCollection
 */
-(DTTimePeriodCollection *)periodsOverlappedByPeriod:(DTTimePeriod *)period{
    DTTimePeriodCollection *collection = [[DTTimePeriodCollection alloc] init];
    
    [periods enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([((DTTimePeriod *) obj) overlapsWith:period]) {
            [collection addTimePeriod:obj];
        }
    }];
    
    return collection;
}

/**
 *  Returns a BOOL representing whether the receiver is equal to a given DTTimePeriodCollection. Equality requires the start and end dates to be the same, and all time periods to be the same. 
 *
 *  If you would like to take the order of the time periods in two collections into consideration, you may do so with the considerOrder BOOL
 *
 *  @param collection    DTTimePeriodCollection - The collection to compare with the receiver
 *  @param considerOrder BOOL - Option for whether to account for the time periods order in the test for equality. YES considers order, NO does not.
 *
 *  @return BOOL
 */
-(BOOL)isEqualToCollection:(DTTimePeriodCollection *)collection considerOrder:(BOOL)considerOrder{
    //Check class
    if ([collection class] != [DTTimePeriodCollection class]) {
        [DTError throwBadTypeException:collection expectedClass:[DTTimePeriodCollection class]];
        return NO;
    }
    
    //Check group level characteristics for speed
    if (![self hasSameCharacteristicsAs:collection]) {
        return NO;
    }
    
    //Default to equality and look for inequality
    __block BOOL isEqual = YES;
    if (considerOrder) {
        
        [periods enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if (![collection[idx] isEqualToPeriod:obj]) {
                isEqual = NO;
                *stop = YES;
            }
        }];
    }
    else {
        __block DTTimePeriodCollection *collectionCopy = [collection copy];
        
        [periods enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            __block BOOL innerMatch = NO;
            __block NSInteger matchIndex = 0; //We will remove matches to account for duplicates and to help speed
            for (int ii = 0; ii < collectionCopy.count; ii++) {
                if ([obj isEqualToPeriod:collectionCopy[ii]]) {
                    innerMatch = YES;
                    matchIndex = ii;
                    break;
                }
            }
            
            //If there was a match found, stop
            if (!innerMatch) {
                isEqual = NO;
                *stop = YES;
            }
            else {
                [collectionCopy removeTimePeriodAtIndex:matchIndex];
            }
        }];
    }
    
    return isEqual;
}

#pragma mark - Helper Methods

-(void)updateVariables{
    //Set helper variables
    __block NSDate *startDate = [NSDate distantFuture];
    __block NSDate *endDate = [NSDate distantPast];
    [periods enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([((DTTimePeriod *) obj).StartDate isEarlierThan:startDate]) {
            startDate = ((DTTimePeriod *) obj).StartDate;
        }
        if ([((DTTimePeriod *) obj).EndDate isLaterThan:endDate]) {
            endDate = ((DTTimePeriod *) obj).EndDate;
        }
    }];
    
    //Make assignments after evaluation
    StartDate = startDate;
    EndDate = endDate;
}

-(void)setVariablesNil{
    //Set helper variables
    StartDate = nil;
    EndDate = nil;
}

/**
 *  Returns a new instance of DTTimePeriodCollection that is an exact copy of the receiver, but with differnt memory references, etc.
 *
 *  @return DTTimePeriodCollection
 */
-(DTTimePeriodCollection *)copy{
    DTTimePeriodCollection *collection = [DTTimePeriodCollection collection];
    
    [periods enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [collection addTimePeriod:[obj copy]];
    }];
    
    return collection;
}

@end
