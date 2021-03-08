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
#import "DTTimePeriodGroup.h"

@interface DTTimePeriodCollection : DTTimePeriodGroup

#pragma mark - Custom Init / Factory Methods
+(DTTimePeriodCollection *)collection;

#pragma mark - Collection Manipulation
-(void)addTimePeriod:(DTTimePeriod *)period;
-(void)insertTimePeriod:(DTTimePeriod *)period atIndex:(NSInteger)index;
-(void)removeTimePeriodAtIndex:(NSInteger)index;

#pragma mark - Sorting
-(void)sortByStartAscending;
-(void)sortByStartDescending;
-(void)sortByEndAscending;
-(void)sortByEndDescending;
-(void)sortByDurationAscending;
-(void)sortByDurationDescending;

#pragma mark - Collection Relationship
-(DTTimePeriodCollection *)periodsInside:(DTTimePeriod *)period;
-(DTTimePeriodCollection *)periodsIntersectedByDate:(NSDate *)date;
-(DTTimePeriodCollection *)periodsIntersectedByPeriod:(DTTimePeriod *)period;
-(DTTimePeriodCollection *)periodsOverlappedByPeriod:(DTTimePeriod *)period;
-(BOOL)isEqualToCollection:(DTTimePeriodCollection *)collection considerOrder:(BOOL)considerOrder;

#pragma mark - Helper Methods
-(DTTimePeriodCollection *)copy;

#pragma mark - Updates
-(void)updateVariables;
@end
