//
//  NSColor+ANSI.m
//  BitBar
//
//  Created by iosdeveloper on 01.09.16.
//  Copyright © 2016 Bit Bar. All rights reserved.
//

#import "NSColor+ANSI.h"

@implementation NSColor (ANSI)

+ (NSColor *)colorForAnsi256ColorIndex:(int)index {
  double r, g, b;
  if (index >= 16 && index < 232) {
    int i = index - 16;
    r = (i / 36) ? ((i / 36) * 40 + 55) / 255.0 : 0.0;
    g = (i % 36) / 6 ? (((i % 36) / 6) * 40 + 55) / 255.0 : 0.0;
    b = (i % 6) ? ((i % 6) * 40 + 55) / 255.0 : 0.0;
  } else if (index >= 232 && index < 256) {
    int i = index - 232;
    r = g = b = (i * 10 + 8) / 255.0;
  } else {
    // The first 16 colors aren't supported here.
    return nil;
  }
  NSColor* srgb = [NSColor colorWithSRGBRed:r
                                      green:g
                                       blue:b
                                      alpha:1];
  return [srgb colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
}

@end
