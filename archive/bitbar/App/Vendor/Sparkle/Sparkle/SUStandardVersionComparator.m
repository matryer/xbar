//
//  SUStandardVersionComparator.m
//  Sparkle
//
//  Created by Andy Matuschak on 12/21/07.
//  Copyright 2007 Andy Matuschak. All rights reserved.
//

#import "SUUpdater.h"

#import "SUAppcast.h"
#import "SUAppcastItem.h"
#import "SUVersionComparisonProtocol.h"
#import "SUStandardVersionComparator.h"

@implementation SUStandardVersionComparator

+ (SUStandardVersionComparator *)defaultComparator
{
    static SUStandardVersionComparator *defaultComparator = nil;
    if (defaultComparator == nil) {
        defaultComparator = [[SUStandardVersionComparator alloc] init];
    }
    return defaultComparator;
}

typedef NS_ENUM(NSInteger, SUCharacterType) {
    kNumberType,
    kStringType,
    kSeparatorType,
};

- (SUCharacterType)typeOfCharacter:(NSString *)character
{
    if ([character isEqualToString:@"."]) {
        return kSeparatorType;
    } else if ([[NSCharacterSet decimalDigitCharacterSet] characterIsMember:[character characterAtIndex:0]]) {
        return kNumberType;
    } else if ([[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:[character characterAtIndex:0]]) {
        return kSeparatorType;
    } else if ([[NSCharacterSet punctuationCharacterSet] characterIsMember:[character characterAtIndex:0]]) {
        return kSeparatorType;
    } else {
        return kStringType;
    }
}

- (NSArray *)splitVersionString:(NSString *)version
{
    NSString *character;
    NSMutableString *s;
    NSUInteger i, n;
    SUCharacterType oldType, newType;
    NSMutableArray *parts = [NSMutableArray array];
    if ([version length] == 0) {
        // Nothing to do here
        return parts;
    }
    s = [[version substringToIndex:1] mutableCopy];
    oldType = [self typeOfCharacter:s];
    n = [version length] - 1;
    for (i = 1; i <= n; ++i) {
        character = [version substringWithRange:NSMakeRange(i, 1)];
        newType = [self typeOfCharacter:character];
        if (oldType != newType || oldType == kSeparatorType) {
            // We've reached a new segment
            NSString *aPart = [[NSString alloc] initWithString:s];
            [parts addObject:aPart];
            [s setString:character];
        } else {
            // Add character to string and continue
            [s appendString:character];
        }
        oldType = newType;
    }

    // Add the last part onto the array
    [parts addObject:[NSString stringWithString:s]];
    return parts;
}

- (NSComparisonResult)compareVersion:(NSString *)versionA toVersion:(NSString *)versionB
{
    NSArray *partsA = [self splitVersionString:versionA];
    NSArray *partsB = [self splitVersionString:versionB];

    NSString *partA, *partB;
    NSUInteger i, n;
    long long valueA, valueB;
    SUCharacterType typeA, typeB;

    n = MIN([partsA count], [partsB count]);
    for (i = 0; i < n; ++i) {
        partA = [partsA objectAtIndex:i];
        partB = [partsB objectAtIndex:i];

        typeA = [self typeOfCharacter:partA];
        typeB = [self typeOfCharacter:partB];

        // Compare types
        if (typeA == typeB) {
            // Same type; we can compare
            if (typeA == kNumberType) {
                valueA = [partA longLongValue];
                valueB = [partB longLongValue];
                if (valueA > valueB) {
                    return NSOrderedDescending;
                } else if (valueA < valueB) {
                    return NSOrderedAscending;
                }
            } else if (typeA == kStringType) {
                NSComparisonResult result = [partA compare:partB];
                if (result != NSOrderedSame) {
                    return result;
                }
            }
        } else {
            // Not the same type? Now we have to do some validity checking
            if (typeA != kStringType && typeB == kStringType) {
                // typeA wins
                return NSOrderedDescending;
            } else if (typeA == kStringType && typeB != kStringType) {
                // typeB wins
                return NSOrderedAscending;
            } else {
                // One is a number and the other is a period. The period is invalid
                if (typeA == kNumberType) {
                    return NSOrderedDescending;
                } else {
                    return NSOrderedAscending;
                }
            }
        }
    }
    // The versions are equal up to the point where they both still have parts
    // Lets check to see if one is larger than the other
    if ([partsA count] != [partsB count]) {
        // Yep. Lets get the next part of the larger
        // n holds the index of the part we want.
        NSString *missingPart;
        SUCharacterType missingType;
        NSComparisonResult shorterResult, largerResult;

        if ([partsA count] > [partsB count]) {
            missingPart = [partsA objectAtIndex:n];
            shorterResult = NSOrderedAscending;
            largerResult = NSOrderedDescending;
        } else {
            missingPart = [partsB objectAtIndex:n];
            shorterResult = NSOrderedDescending;
            largerResult = NSOrderedAscending;
        }

        missingType = [self typeOfCharacter:missingPart];
        // Check the type
        if (missingType == kStringType) {
            // It's a string. Shorter version wins
            return shorterResult;
        } else {
            // It's a number/period. Larger version wins
            return largerResult;
        }
    }

    // The 2 strings are identical
    return NSOrderedSame;
}


@end
