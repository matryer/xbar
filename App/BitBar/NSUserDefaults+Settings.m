//
//  Settings.m
//  BitBar
//
//  Created by Mat Ryer on 11/13/13.
//  Copyright (c) 2013 Bit Bar. All rights reserved.
//

#import "NSUserDefaults+Settings.h"

@implementation NSUserDefaults (Settings)


- (NSString *)pluginsDirectory {
  return [self stringForKey:@"pluginsDirectory"];
}
- (void) setPluginsDirectory:(NSString*)value {

  [self setObject:value forKey:@"pluginsDirectory"];
}

- (BOOL) isFirstTimeAppRun { return ![self boolForKey:@"appHasRun"]; }

- (void) setIsFirstTimeAppRun:(BOOL)firstTime {
  [self setBool:firstTime forKey:@"appHasRun"];
}
- (BOOL) useiTerm { return [self boolForKey:@"useiTerm"]; }



@end

