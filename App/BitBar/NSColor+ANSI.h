//
//  NSColor+ANSI.h
//  BitBar
//
//  Created by iosdeveloper on 01.09.16.
//  Copyright © 2016 Bit Bar. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSColor (ANSI)

// Returns colors for the standard 8-bit ansi color codes. Only indices between 16 and 255 are
// supported.
// by George Nachman for iTerm
+ (NSColor *)colorForAnsi256ColorIndex:(int)index;

@end
