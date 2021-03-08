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

#import "DTTimePeriod.h"
#import "NSDate+DateTools.h"

@interface DTTimePeriod ()

@end


@implementation DTTimePeriod

#pragma mark - Custom Init / Factory Methods
/**
 *  Initializes an instance of DTTimePeriod from a given start and end date
 *
 *  @param startDate NSDate - Desired start date
 *  @param endDate   NSDate - Desired end date
 *
 *  @return DTTimePeriod - new instance
 */
-(instancetype)initWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate{
    if (self = [super init]) {
        self.StartDate = startDate;
        self.EndDate = endDate;
    }
    
    return self;
}

/**
 *  Returns a new instance of DTTimePeriod from a given start and end date
 *
 *  @param startDate NSDate - Desired start date
 *  @param endDate   NSDate - Desired end date
 *
 *  @return DTTimePeriod - new instance
 */
+(instancetype)timePeriodWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate{
    return [[DTTimePeriod alloc] initWithStartDate:startDate endDate:endDate];
}

/**
 *  Returns a new instance of DTTimePeriod that starts on the provided start date
 *  and is of the size provided
 *
 *  @param size DTTimePeriodSize - Desired size of the new time period
 *  @param date NSDate - Desired start date of the new time period
 *
 *  @return DTTimePeriod - new instance
 */
+(instancetype)timePeriodWithSize:(DTTimePeriodSize)size startingAt:(NSDate *)date{
    return [[DTTimePeriod alloc] initWithStartDate:date endDate:[DTTimePeriod dateWithAddedTime:size amount:1 baseDate:date]];
}

/**
 *  Returns a new instance of DTTimePeriod that starts on the provided start date
 *  and is of the size provided. The amount represents a multipler to the size (e.g. "2 weeks" or "4 years")
 *
 *  @param size DTTimePeriodSize - Desired size of the new time period
 *  @param amount NSInteger - Desired multiplier of the size provided
 *  @param date NSDate - Desired start date of the new time period
 *
 *  @return DTTimePeriod - new instance
 */
+(instancetype)timePeriodWithSize:(DTTimePeriodSize)size amount:(NSInteger)amount startingAt:(NSDate *)date{
    return [[DTTimePeriod alloc] initWithStartDate:date endDate:[DTTimePeriod dateWithAddedTime:size amount:amount baseDate:date]];
}

/**
 *  Returns a new instance of DTTimePeriod that ends on the provided end date
 *  and is of the size provided
 *
 *  @param size DTTimePeriodSize - Desired size of the new time period
 *  @param date NSDate - Desired end date of the new time period
 *
 *  @return DTTimePeriod - new instance
 */
+(instancetype)timePeriodWithSize:(DTTimePeriodSize)size endingAt:(NSDate *)date{
    return [[DTTimePeriod alloc] initWithStartDate:[DTTimePeriod dateWithSubtractedTime:size amount:1 baseDate:date] endDate:date];
}

/**
 *  Returns a new instance of DTTimePeriod that ends on the provided end date
 *  and is of the size provided. The amount represents a multipler to the size (e.g. "2 weeks" or "4 years")
 *
 *  @param size   DTTimePeriodSize - Desired size of the new time period
 *  @param amount NSInteger - Desired multiplier of the size provided
 *  @param date   NSDate - Desired end date of the new time period
 *
 *  @return DTTimePeriod - new instance
 */
+(instancetype)timePeriodWithSize:(DTTimePeriodSize)size amount:(NSInteger)amount endingAt:(NSDate *)date{
    return [[DTTimePeriod alloc] initWithStartDate:[DTTimePeriod dateWithSubtractedTime:size amount:amount baseDate:date] endDate:date];
}

/**
 *  Returns a new instance of DTTimePeriod that represents the largest time period available.
 *  The start date is in the distant past and the end date is in the distant future.
 *
 *  @return DTTimePeriod - new instance
 */
+(instancetype)timePeriodWithAllTime{
    return [[DTTimePeriod alloc] initWithStartDate:[NSDate distantPast] endDate:[NSDate distantFuture]];
}

/**
 *  Method serving the various factory methods as well as a few others.
 *  Returns a date with time added to a given base date. Includes multiplier amount.
 *
 *  @param size   DTTimePeriodSize - Desired size of the new time period
 *  @param amount NSInteger - Desired multiplier of the size provided
 *  @param date   NSDate - Desired end date of the new time period
 *
 *  @return NSDate - new instance
 */
+(NSDate *)dateWithAddedTime:(DTTimePeriodSize)size amount:(NSInteger)amount baseDate:(NSDate *)date{
    switch (size) {
        case DTTimePeriodSizeSecond:
            return [date dateByAddingSeconds:amount];
            break;
        case DTTimePeriodSizeMinute:
            return [date dateByAddingMinutes:amount];
            break;
        case DTTimePeriodSizeHour:
            return [date dateByAddingHours:amount];
            break;
        case DTTimePeriodSizeDay:
            return [date dateByAddingDays:amount];
            break;
        case DTTimePeriodSizeWeek:
            return [date dateByAddingWeeks:amount];
            break;
        case DTTimePeriodSizeMonth:
            return [date dateByAddingMonths:amount];
            break;
        case DTTimePeriodSizeYear:
            return [date dateByAddingYears:amount];
            break;
        default:
            break;
    }
    
    return date;
}

/**
 *  Method serving the various factory methods as well as a few others.
 *  Returns a date with time subtracted from a given base date. Includes multiplier amount.
 *
 *  @param size   DTTimePeriodSize - Desired size of the new time period
 *  @param amount NSInteger - Desired multiplier of the size provided
 *  @param date   NSDate - Desired end date of the new time period
 *
 *  @return NSDate - new instance
 */
+(NSDate *)dateWithSubtractedTime:(DTTimePeriodSize)size amount:(NSInteger)amount baseDate:(NSDate *)date{
    switch (size) {
        case DTTimePeriodSizeSecond:
            return [date dateBySubtractingSeconds:amount];
            break;
        case DTTimePeriodSizeMinute:
            return [date dateBySubtractingMinutes:amount];
            break;
        case DTTimePeriodSizeHour:
            return [date dateBySubtractingHours:amount];
            break;
        case DTTimePeriodSizeDay:
            return [date dateBySubtractingDays:amount];
            break;
        case DTTimePeriodSizeWeek:
            return [date dateBySubtractingWeeks:amount];
            break;
        case DTTimePeriodSizeMonth:
            return [date dateBySubtractingMonths:amount];
            break;
        case DTTimePeriodSizeYear:
            return [date dateBySubtractingYears:amount];
            break;
        default:
            break;
    }
    
    return date;
}

#pragma mark - Time Period Information
/**
 *  Returns a boolean representing whether the receiver's StartDate exists
 *  Returns YES if StartDate is not nil, otherwise NO
 *
 *  @return BOOL
 */
-(BOOL)hasStartDate {
    return (self.StartDate)? YES:NO;
}

/**
 *  Returns a boolean representing whether the receiver's EndDate exists
 *  Returns YES if EndDate is not nil, otherwise NO
 *
 *  @return BOOL
 */
-(BOOL)hasEndDate {
    return (self.EndDate)? YES:NO;
}

/**
 *  Returns a boolean representing whether the receiver is a "moment", that is the start and end dates are the same.
 *  Returns YES if receiver is a moment, otherwise NO
 *
 *  @return BOOL
 */
-(BOOL)isMoment{
    if (self.StartDate && self.EndDate) {
        if ([self.StartDate isEqualToDate:self.EndDate]) {
            return YES;
        }
    }
    
    return NO;
}

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

#pragma mark - Time Period Relationship
/**
 *  Returns a BOOL representing whether the receiver's start and end dates exatcly match a given time period
 *  Returns YES if the two periods are the same, otherwise NO
 *
 *  @param period DTTimePeriod - Time period to compare to receiver
 *
 *  @return BOOL
 */
-(BOOL)isEqualToPeriod:(DTTimePeriod *)period{
    if ([self.StartDate isEqualToDate:period.StartDate] && [self.EndDate isEqualToDate:period.EndDate]) {
        return YES;
    }
    return NO;
}

/**
 *  Returns a BOOL representing whether the receiver's start and end dates exatcly match a given time period or is contained within them
 *  Returns YES if the receiver is inside the given time period, otherwise NO
 *
 *  @param period DTTimePeriod - Time period to compare to receiver
 *
 *  @return BOOL
 */
-(BOOL)isInside:(DTTimePeriod *)period{
    if ([period.StartDate isEarlierThanOrEqualTo:self.StartDate] && [period.EndDate isLaterThanOrEqualTo:self.EndDate]) {
        return YES;
    }
    return NO;
}

/**
 *  Returns a BOOL representing whether the given time period's start and end dates exatcly match the receivers' or is contained within them
 *  Returns YES if the receiver is inside the given time period, otherwise NO
 *
 *  @param period DTTimePeriod - Time period to compare to receiver
 *
 *  @return BOOL
 */
-(BOOL)contains:(DTTimePeriod *)period{
    if ([self.StartDate isEarlierThanOrEqualTo:period.StartDate] && [self.EndDate isLaterThanOrEqualTo:period.EndDate]) {
        return YES;
    }
    return NO;
}

/**
 *  Returns a BOOL representing whether the receiver and the given time period overlap. 
 *  This covers all space they share, minus instantaneous space (i.e. one's start date equals another's end date)
 *  Returns YES if they overlap, otherwise NO
 *
 *  @param period DTTimePeriod - Time period to compare to receiver
 *
 *  @return BOOL
 */
-(BOOL)overlapsWith:(DTTimePeriod *)period{
    //Outside -> Inside
    if ([period.StartDate isEarlierThan:self.StartDate] && [period.EndDate isLaterThan:self.StartDate]) {
        return YES;
    }
    //Enclosing
    else if ([period.StartDate isLaterThanOrEqualTo:self.StartDate] && [period.EndDate isEarlierThanOrEqualTo:self.EndDate]){
        return YES;
    }
    //Inside -> Out
    else if([period.StartDate isEarlierThan:self.EndDate] && [period.EndDate isLaterThan:self.EndDate]){
        return YES;
    }
    return NO;
}

/**
 *  Returns a BOOL representing whether the receiver and the given time period overlap.
 *  This covers all space they share, including instantaneous space (i.e. one's start date equals another's end date)
 *  Returns YES if they overlap, otherwise NO
 *
 *  @param period DTTimePeriod - Time period to compare to receiver
 *
 *  @return BOOL
 */
-(BOOL)intersects:(DTTimePeriod *)period{
    //Outside -> Inside
    if ([period.StartDate isEarlierThan:self.StartDate] && [period.EndDate isLaterThanOrEqualTo:self.StartDate]) {
        return YES;
    }
    //Enclosing
    else if ([period.StartDate isLaterThanOrEqualTo:self.StartDate] && [period.EndDate isEarlierThanOrEqualTo:self.EndDate]){
        return YES;
    }
    //Inside -> Out
    else if([period.StartDate isEarlierThanOrEqualTo:self.EndDate] && [period.EndDate isLaterThan:self.EndDate]){
        return YES;
    }
    return NO;
}

/**
 *  Returns the relationship of the receiver to a given time period
 *
 *  @param period DTTimePeriod - Time period to compare to receiver
 *
 *  @return DTTimePeriodRelation
 */
-(DTTimePeriodRelation)relationToPeriod:(DTTimePeriod *)period{
    
    //Make sure that all start and end points exist for comparison
    if (self.StartDate && self.EndDate && period.StartDate && period.EndDate) {
        //Make sure time periods are of positive durations
        if ([self.StartDate isEarlierThan:self.EndDate] && [period.StartDate isEarlierThan:period.EndDate]) {
            
            //Make comparisons
            if ([period.EndDate isEarlierThan:self.StartDate]) {
                return DTTimePeriodRelationAfter;
            }
            else if ([period.EndDate isEqualToDate:self.StartDate]){
                return DTTimePeriodRelationStartTouching;
            }
            else if ([period.StartDate isEarlierThan:self.StartDate] && [period.EndDate isEarlierThan:self.EndDate]){
                return DTTimePeriodRelationStartInside;
            }
            else if ([period.StartDate isEqualToDate:self.StartDate] && [period.EndDate isLaterThan:self.EndDate]){
                return DTTimePeriodRelationInsideStartTouching;
            }
            else if ([period.StartDate isEqualToDate:self.StartDate] && [period.EndDate isEarlierThan:self.EndDate]){
                return DTTimePeriodRelationEnclosingStartTouching;
            }
            else if ([period.StartDate isLaterThan:self.StartDate] && [period.EndDate isEarlierThan:self.EndDate]){
                return DTTimePeriodRelationEnclosing;
            }
            else if ([period.StartDate isLaterThan:self.StartDate] && [period.EndDate isEqualToDate:self.EndDate]){
                return DTTimePeriodRelationEnclosingEndTouching;
            }
            else if ([period.StartDate isEqualToDate:self.StartDate] && [period.EndDate isEqualToDate:self.EndDate]){
                return DTTimePeriodRelationExactMatch;
            }
            else if ([period.StartDate isEarlierThan:self.StartDate] && [period.EndDate isLaterThan:self.EndDate]){
                return DTTimePeriodRelationInside;
            }
            else if ([period.StartDate isEarlierThan:self.StartDate] && [period.EndDate isEqualToDate:self.EndDate]){
                return DTTimePeriodRelationInsideEndTouching;
            }
            else if ([period.StartDate isEarlierThan:self.EndDate] && [period.EndDate isLaterThan:self.EndDate]){
                return DTTimePeriodRelationEndInside;
            }
            else if ([period.StartDate isEqualToDate:self.EndDate] && [period.EndDate isLaterThan:self.EndDate]){
                return DTTimePeriodRelationEndTouching;
            }
            else if ([period.StartDate isLaterThan:self.EndDate]){
                return DTTimePeriodRelationBefore;
            }
        }
    }
    
    return DTTimePeriodRelationNone;
}

/**
 *  Returns the gap in seconds between the receiver and provided time period
 *  Returns 0 if the time periods intersect, otherwise returns the gap between.
 *
 *  @param period <#period description#>
 *
 *  @return <#return value description#>
 */
-(NSTimeInterval)gapBetween:(DTTimePeriod *)period{
    if ([self.EndDate isEarlierThan:period.StartDate]) {
        return ABS([self.EndDate timeIntervalSinceDate:period.StartDate]);
    }
    else if ([period.EndDate isEarlierThan:self.StartDate]){
        return ABS([period.EndDate timeIntervalSinceDate:self.StartDate]);
    }
    
    return 0;
}

#pragma mark - Date Relationships
/**
 *  Returns a BOOL representing whether the provided date is contained in the receiver.
 *
 *  @param date     NSDate - Date to evaluate
 *  @param interval DTTimePeriodInterval representing evaluation type (Closed includes StartDate and EndDate in evaluation, Open does not)
 *
 *  @return <#return value description#>
 */
-(BOOL)containsDate:(NSDate *)date interval:(DTTimePeriodInterval)interval{
    if (interval == DTTimePeriodIntervalOpen) {
        if ([self.StartDate isEarlierThan:date] && [self.EndDate isLaterThan:date]) {
            return YES;
        }
        else {
            return NO;
        }
    }
    else if (interval == DTTimePeriodIntervalClosed){
        if ([self.StartDate isEarlierThanOrEqualTo:date] && [self.EndDate isLaterThanOrEqualTo:date]) {
            return YES;
        }
        else {
            return NO;
        }
    }
    
    return NO;
}

#pragma mark - Period Manipulation
/**
 *  Shifts the StartDate and EndDate earlier by a given size amount
 *
 *  @param size DTTimePeriodSize - Desired shift size
 */
-(void)shiftEarlierWithSize:(DTTimePeriodSize)size{
    [self shiftEarlierWithSize:size amount:1];
}

/**
 *  Shifts the StartDate and EndDate earlier by a given size amount. Amount multiplies size.
 *
 *  @param size DTTimePeriodSize - Desired shift size
 *  @param amount NSInteger - Multiplier of size (i.e. "2 weeks" or "4 years")
 */
-(void)shiftEarlierWithSize:(DTTimePeriodSize)size amount:(NSInteger)amount{
    self.StartDate = [DTTimePeriod dateWithSubtractedTime:size amount:amount baseDate:self.StartDate];
    self.EndDate = [DTTimePeriod dateWithSubtractedTime:size amount:amount baseDate:self.EndDate];
}

/**
 *  Shifts the StartDate and EndDate later by a given size amount
 *
 *  @param size DTTimePeriodSize - Desired shift size
 */
-(void)shiftLaterWithSize:(DTTimePeriodSize)size{
    [self shiftLaterWithSize:size amount:1];
}

/**
 *  Shifts the StartDate and EndDate later by a given size amount. Amount multiplies size.
 *
 *  @param size DTTimePeriodSize - Desired shift size
 *  @param amount NSInteger - Multiplier of size (i.e. "2 weeks" or "4 years")
 */
-(void)shiftLaterWithSize:(DTTimePeriodSize)size amount:(NSInteger)amount{
    self.StartDate = [DTTimePeriod dateWithAddedTime:size amount:amount baseDate:self.StartDate];
    self.EndDate = [DTTimePeriod dateWithAddedTime:size amount:amount baseDate:self.EndDate];
}

#pragma mark Lengthen / Shorten
/**
 *  Lengthens the receiver by a given amount, anchored by a provided point
 *
 *  @param anchor DTTimePeriodAnchor - Anchor point for the lengthen (the date that stays the same)
 *  @param size DTTimePeriodSize - Desired lenghtening size
 */
-(void)lengthenWithAnchorDate:(DTTimePeriodAnchor)anchor size:(DTTimePeriodSize)size{
    [self lengthenWithAnchorDate:anchor size:size amount:1];
}
/**
 *  Lengthens the receiver by a given amount, anchored by a provided point. Amount multiplies size.
 *
 *  @param anchor DTTimePeriodAnchor - Anchor point for the lengthen (the date that stays the same)
 *  @param size   DTTimePeriodSize - Desired lenghtening size
 *  @param amount NSInteger - Multiplier of size (i.e. "2 weeks" or "4 years")
 */
-(void)lengthenWithAnchorDate:(DTTimePeriodAnchor)anchor size:(DTTimePeriodSize)size amount:(NSInteger)amount{
    switch (anchor) {
        case DTTimePeriodAnchorStart:
            self.EndDate = [DTTimePeriod dateWithAddedTime:size amount:amount baseDate:self.EndDate];
            break;
        case DTTimePeriodAnchorCenter:
            self.StartDate = [DTTimePeriod dateWithSubtractedTime:size amount:amount/2 baseDate:self.StartDate];
            self.EndDate = [DTTimePeriod dateWithAddedTime:size amount:amount/2 baseDate:self.EndDate];
            break;
        case DTTimePeriodAnchorEnd:
            self.StartDate = [DTTimePeriod dateWithSubtractedTime:size amount:amount baseDate:self.StartDate];
            break;
        default:
            break;
    }
}

/**
 *  Shortens the receiver by a given amount, anchored by a provided point
 *
 *  @param anchor DTTimePeriodAnchor - Anchor point for the shorten (the date that stays the same)
 *  @param size DTTimePeriodSize - Desired shortening size
 */
-(void)shortenWithAnchorDate:(DTTimePeriodAnchor)anchor size:(DTTimePeriodSize)size{
    [self shortenWithAnchorDate:anchor size:size amount:1];
}

/**
 *  Shortens the receiver by a given amount, anchored by a provided point. Amount multiplies size.
 *
 *  @param anchor DTTimePeriodAnchor - Anchor point for the shorten (the date that stays the same)
 *  @param size   DTTimePeriodSize - Desired shortening size
 *  @param amount NSInteger - Multiplier of size (i.e. "2 weeks" or "4 years")
 */
-(void)shortenWithAnchorDate:(DTTimePeriodAnchor)anchor size:(DTTimePeriodSize)size amount:(NSInteger)amount{
    switch (anchor) {
        case DTTimePeriodAnchorStart:
            self.EndDate = [DTTimePeriod dateWithSubtractedTime:size amount:amount baseDate:self.EndDate];
            break;
        case DTTimePeriodAnchorCenter:
            self.StartDate = [DTTimePeriod dateWithAddedTime:size amount:amount/2 baseDate:self.StartDate];
            self.EndDate = [DTTimePeriod dateWithSubtractedTime:size amount:amount/2 baseDate:self.EndDate];
            break;
        case DTTimePeriodAnchorEnd:
            self.StartDate = [DTTimePeriod dateWithAddedTime:size amount:amount baseDate:self.StartDate];
            break;
        default:
            break;
    }
}

#pragma mark - Helper Methods
-(DTTimePeriod *)copy{
    DTTimePeriod *period = [DTTimePeriod timePeriodWithStartDate:[NSDate dateWithTimeIntervalSince1970:self.StartDate.timeIntervalSince1970] endDate:[NSDate dateWithTimeIntervalSince1970:self.EndDate.timeIntervalSince1970]];
    return period;
}

@end
