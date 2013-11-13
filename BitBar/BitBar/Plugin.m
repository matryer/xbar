//
//  Plugin.m
//  BitBar
//
//  Created by Mat Ryer on 11/12/13.
//  Copyright (c) 2013 Bit Bar. All rights reserved.
//

#import "Plugin.h"

@implementation Plugin

@synthesize refreshIntervalSeconds = _refreshIntervalSeconds;

- (NSNumber *)refreshIntervalSeconds {
  
  if (_refreshIntervalSeconds == nil) {
    
    NSArray *segments = [self.name componentsSeparatedByString:@"."];
    NSString *timeStr = [[segments objectAtIndex:1] lowercaseString];
    NSString *numberPart = [timeStr substringToIndex:[timeStr length]-1];
    double numericalValue = [numberPart doubleValue];
        
    if ([timeStr hasSuffix:@"m"]) {
      numericalValue *= 60;
    } else if ([timeStr hasSuffix:@"h"]) {
      numericalValue *= 60*60;
    } else if ([timeStr hasSuffix:@"d"]) {
      numericalValue *= 60*60*24;
    }
    
    _refreshIntervalSeconds = [NSNumber numberWithDouble:numericalValue];
    
  }
  
  return _refreshIntervalSeconds;
  
}

@end
