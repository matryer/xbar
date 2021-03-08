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


typedef NS_ENUM(NSUInteger, DTTimePeriodRelation){
    DTTimePeriodRelationAfter,
    DTTimePeriodRelationStartTouching,
    DTTimePeriodRelationStartInside,
    DTTimePeriodRelationInsideStartTouching,
    DTTimePeriodRelationEnclosingStartTouching,
    DTTimePeriodRelationEnclosing,
    DTTimePeriodRelationEnclosingEndTouching,
    DTTimePeriodRelationExactMatch,
    DTTimePeriodRelationInside,
    DTTimePeriodRelationInsideEndTouching,
    DTTimePeriodRelationEndInside,
    DTTimePeriodRelationEndTouching,
    DTTimePeriodRelationBefore,
    DTTimePeriodRelationNone //One or more of the dates does not exist
};

typedef NS_ENUM(NSUInteger, DTTimePeriodSize) {
    DTTimePeriodSizeSecond,
    DTTimePeriodSizeMinute,
    DTTimePeriodSizeHour,
    DTTimePeriodSizeDay,
    DTTimePeriodSizeWeek,
    DTTimePeriodSizeMonth,
    DTTimePeriodSizeYear
};

typedef NS_ENUM(NSUInteger, DTTimePeriodInterval) {
    DTTimePeriodIntervalOpen,
    DTTimePeriodIntervalClosed
};

typedef NS_ENUM(NSUInteger, DTTimePeriodAnchor) {
    DTTimePeriodAnchorStart,
    DTTimePeriodAnchorCenter,
    DTTimePeriodAnchorEnd
};

@interface DTTimePeriod : NSObject

/**
 *  The start date for a DTTimePeriod representing the starting boundary of the time period
 */
@property (nonatomic,strong) NSDate *StartDate;

/**
 *  The end date for a DTTimePeriod representing the ending boundary of the time period
 */
@property (nonatomic,strong) NSDate *EndDate;

#pragma mark - Custom Init / Factory Methods
-(instancetype)initWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;
+(instancetype)timePeriodWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;
+(instancetype)timePeriodWithSize:(DTTimePeriodSize)size startingAt:(NSDate *)date;
+(instancetype)timePeriodWithSize:(DTTimePeriodSize)size amount:(NSInteger)amount startingAt:(NSDate *)date;
+(instancetype)timePeriodWithSize:(DTTimePeriodSize)size endingAt:(NSDate *)date;
+(instancetype)timePeriodWithSize:(DTTimePeriodSize)size amount:(NSInteger)amount endingAt:(NSDate *)date;
+(instancetype)timePeriodWithAllTime;

#pragma mark - Time Period Information
-(BOOL)hasStartDate;
-(BOOL)hasEndDate;
-(BOOL)isMoment;
-(double)durationInYears;
-(double)durationInWeeks;
-(double)durationInDays;
-(double)durationInHours;
-(double)durationInMinutes;
-(double)durationInSeconds;

#pragma mark - Time Period Relationship
-(BOOL)isEqualToPeriod:(DTTimePeriod *)period;
-(BOOL)isInside:(DTTimePeriod *)period;
-(BOOL)contains:(DTTimePeriod *)period;
-(BOOL)overlapsWith:(DTTimePeriod *)period;
-(BOOL)intersects:(DTTimePeriod *)period;
-(DTTimePeriodRelation)relationToPeriod:(DTTimePeriod *)period;
-(NSTimeInterval)gapBetween:(DTTimePeriod *)period;

#pragma mark - Date Relationships
-(BOOL)containsDate:(NSDate *)date interval:(DTTimePeriodInterval)interval;

#pragma mark - Period Manipulation
#pragma mark Shifts
-(void)shiftEarlierWithSize:(DTTimePeriodSize)size;
-(void)shiftEarlierWithSize:(DTTimePeriodSize)size amount:(NSInteger)amount;
-(void)shiftLaterWithSize:(DTTimePeriodSize)size;
-(void)shiftLaterWithSize:(DTTimePeriodSize)size amount:(NSInteger)amount;

#pragma mark Lengthen / Shorten
-(void)lengthenWithAnchorDate:(DTTimePeriodAnchor)anchor size:(DTTimePeriodSize)size;
-(void)lengthenWithAnchorDate:(DTTimePeriodAnchor)anchor size:(DTTimePeriodSize)size amount:(NSInteger)amount;
-(void)shortenWithAnchorDate:(DTTimePeriodAnchor)anchor size:(DTTimePeriodSize)size;
-(void)shortenWithAnchorDate:(DTTimePeriodAnchor)anchor size:(DTTimePeriodSize)size amount:(NSInteger)amount;

#pragma mark - Helper Methods
-(DTTimePeriod *)copy;
@end
