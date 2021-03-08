//
//  NSString+Emojize.m
//  Field Recorder
//
//  Created by Jonathan Beilin on 11/5/12.
//  Copyright (c) 2014 DIY. All rights reserved.
//

#import "NSString+Emojize.h"
#import "emojis.h"

@implementation NSString (Emojize)

- (NSString *)emojizedString
{
    return [NSString emojizedStringWithString:self];
}

+ (NSString *)emojizedStringWithString:(NSString *)text
{
    static dispatch_once_t onceToken;
    static NSRegularExpression *regex = nil;
    dispatch_once(&onceToken, ^{
        regex = [[NSRegularExpression alloc] initWithPattern:@"(:[a-z0-9-+_]+:)" options:NSRegularExpressionCaseInsensitive error:NULL];
    });
    
    __block NSString *resultText = text;
    NSRange matchingRange = NSMakeRange(0, [resultText length]);
    [regex enumerateMatchesInString:resultText options:NSMatchingReportCompletion range:matchingRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
         if (result && ([result resultType] == NSTextCheckingTypeRegularExpression) && !(flags & NSMatchingInternalError)) {
             NSRange range = result.range;
             if (range.location != NSNotFound) {
                 NSString *code = [text substringWithRange:range];
                 NSString *unicode = self.emojiAliases[code];
                 if (unicode) {
                     resultText = [resultText stringByReplacingOccurrencesOfString:code withString:unicode];
                 }
             }
         }
     }];
    
    return resultText;
}

+ (NSDictionary *)emojiAliases {
    static NSDictionary *_emojiAliases;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _emojiAliases = EMOJI_HASH;
    });
    return _emojiAliases;
}

@end
