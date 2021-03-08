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

#import <Foundation/Foundation.h>
#import "DTTimePeriod.h"

@interface DTTimePeriodGroup : NSObject {
@protected
    NSMutableArray *periods;
    NSDate *StartDate;
    NSDate *EndDate;
}

@property (nonatomic, readonly) NSDate *StartDate;
@property (nonatomic, readonly) NSDate *EndDate;

//Here we will use object subscripting to help create the illusion of an array
- (id)objectAtIndexedSubscript:(NSUInteger)index; //getter
- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)index; //setter

#pragma mark - Group Info
-(double)durationInYears;
-(double)durationInWeeks;
-(double)durationInDays;
-(double)durationInHours;
-(double)durationInMinutes;
-(double)durationInSeconds;
-(NSDate *)StartDate;
-(NSDate *)EndDate;
-(NSInteger)count;

#pragma mark - Chain Time Manipulation
-(void)shiftEarlierWithSize:(DTTimePeriodSize)size;
-(void)shiftEarlierWithSize:(DTTimePeriodSize)size amount:(NSInteger)amount;
-(void)shiftLaterWithSize:(DTTimePeriodSize)size;
-(void)shiftLaterWithSize:(DTTimePeriodSize)size amount:(NSInteger)amount;

#pragma mark - Comparison
-(BOOL)hasSameCharacteristicsAs:(DTTimePeriodGroup *)group;

#pragma mark - Updates
-(void)updateVariables;
@end
