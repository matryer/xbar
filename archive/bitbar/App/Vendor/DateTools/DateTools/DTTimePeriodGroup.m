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

#import "DTTimePeriodGroup.h"
#import "NSDate+DateTools.h"

@interface DTTimePeriodGroup ()

@end

@implementation DTTimePeriodGroup

-(id) init
{
    if (self = [super init]) {
        periods = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (id)objectAtIndexedSubscript:(NSUInteger)index
{
    return periods[index];
}

- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)index {
    periods[index] = obj;
}

#pragma mark - Group Info
/**
 *  Returns the duration of the receiver in years
 *
 *  @return NSInteger
 */
-(double)durationInYears {
    if (self.StartDate && self.EndDate) {
        return [self.StartDate yearsEarlierThan:self.EndDate];
    }
    
    return 0;
}

/**
 *  Returns the duration of the receiver in weeks
 *
 *  @return double
 */
-(double)durationInWeeks {
    if (self.StartDate && self.EndDate) {
        return [self.StartDate weeksEarlierThan:self.EndDate];
    }
    
    return 0;
}

/**
 *  Returns the duration of the receiver in days
 *
 *  @return double
 */
-(double)durationInDays {
    if (self.StartDate && self.EndDate) {
        return [self.StartDate daysEarlierThan:self.EndDate];
    }
    
    return 0;
}

/**
 *  Returns the duration of the receiver in hours
 *
 *  @return double
 */
-(double)durationInHours {
    if (self.StartDate && self.EndDate) {
        return [self.StartDate hoursEarlierThan:self.EndDate];
    }
    
    return 0;
}

/**
 *  Returns the duration of the receiver in minutes
 *
 *  @return double
 */
-(double)durationInMinutes {
    if (self.StartDate && self.EndDate) {
        return [self.StartDate minutesEarlierThan:self.EndDate];
    }
    
    return 0;
}

/**
 *  Returns the duration of the receiver in seconds
 *
 *  @return double
 */
-(double)durationInSeconds {
    if (self.StartDate && self.EndDate) {
        return [self.StartDate secondsEarlierThan:self.EndDate];
    }
    
    return 0;
}

/**
 *  Returns the NSDate representing the earliest date in the DTTimePeriodGroup (or subclass)
 *
 *  @return NSDate
 */
-(NSDate *)StartDate{
    return StartDate;
}

/**
 *  Returns the NSDate representing the latest date in the DTTimePeriodGroup (or subclass)
 *
 *  @return NSDate
 */
-(NSDate *)EndDate{
    return EndDate;
}

/**
 *  The total number of DTTimePeriods in the group
 *
 *  @return NSInteger
 */
-(NSInteger)count{
    return periods.count;
}

/**
 *  Returns a BOOL if the receiver and the comparison group have the same metadata (i.e. number of periods, start & end date, etc.)
 *  Returns YES if they share the same characteristics, otherwise NO
 *
 *  @param group The group to compare with the receiver
 *
 *  @return BOOL
 */
-(BOOL)hasSameCharacteristicsAs:(DTTimePeriodGroup *)group{
    //Check characteristics first for speed
    if (group.count != self.count) {
        return NO;
    }
    else if (!group.StartDate && !group.EndDate && !self.StartDate && !self.EndDate){
        return YES;
    }
    else if (![group.StartDate isEqualToDate:self.StartDate] || ![group.EndDate isEqualToDate:self.EndDate]){
        return NO;
    }
    
    return YES;
}

#pragma mark - Chain Time Manipulation
/**
 *  Shifts all the time periods in the collection to an earlier date by the given size
 *
 *  @param size DTTimePeriodSize - The desired size of the shift
 */
-(void)shiftEarlierWithSize:(DTTimePeriodSize)size{
    [self shiftEarlierWithSize:size amount:1];
}

/**
 *  Shifts all the time periods in the collection to an earlier date by the given size and amount.
 *  The amount acts as a multiplier to the size (i.e. "2 weeks" or "4 years")
 *
 *  @param size   DTTimePeriodSize - The desired size of the shift
 *  @param amount NSInteger - Multiplier for the size
 */
-(void)shiftEarlierWithSize:(DTTimePeriodSize)size amount:(NSInteger)amount{
    if (periods) {
        [periods enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [((DTTimePeriod *)obj) shiftEarlierWithSize:size amount:amount];
        }];
        
        [self updateVariables];
    }
}

/**
 *  Shifts all the time periods in the collection to a later date by the given size
 *
 *  @param size DTTimePeriodSize - The desired size of the shift
 */
-(void)shiftLaterWithSize:(DTTimePeriodSize)size{
    [self shiftLaterWithSize:size amount:1];
}

/**
 *  Shifts all the time periods in the collection to an later date by the given size and amount.
 *  The amount acts as a multiplier to the size (i.e. "2 weeks" or "4 years")
 *
 *  @param size   DTTimePeriodSize - The desired size of the shift
 *  @param amount NSInteger - Multiplier for the size
 */
-(void)shiftLaterWithSize:(DTTimePeriodSize)size amount:(NSInteger)amount{
    if (periods) {
        [periods enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [((DTTimePeriod *)obj) shiftLaterWithSize:size amount:amount];
        }];
        
        [self updateVariables];
    }
}

#pragma mark - Updates
-(void)updateVariables{}
@end
