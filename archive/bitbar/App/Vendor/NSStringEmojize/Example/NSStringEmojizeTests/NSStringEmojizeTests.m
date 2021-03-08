//
//  NSStringEmojizeTests.m
//  NSStringEmojizeTests
//
//  Created by Jonathan Beilin on 1/30/13.
//  Copyright (c) 2013 DIY. All rights reserved.
//

#import "NSStringEmojizeTests.h"

#import "NSString+Emojize.h"

@implementation NSStringEmojizeTests

- (void)testFound
{
    NSString *emojiString = @"This comment has an emoji :mushroom:";
    STAssertTrue([[emojiString emojizedString] rangeOfString:@"\U0001F344"].location != NSNotFound, nil);
}

- (void)testNotFound
{
    NSString *emojiString = @"This comment has an emoji :qwertyasdf:";
    STAssertTrue([[emojiString emojizedString] rangeOfString:@"\U0001F344"].location == NSNotFound, nil);
}

@end
