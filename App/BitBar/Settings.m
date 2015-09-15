//
//  Settings.m
//  BitBar
//
//  Created by Mat Ryer on 11/13/13.
//  Copyright (c) 2013 Bit Bar. All rights reserved.
//

#import "Settings.h"

#define DEFS NSUserDefaults.standardUserDefaults

@implementation Settings

+ (NSString *)pluginsDirectory {
  return [DEFS stringForKey:@"pluginsDirectory"];
}
+ (void)setPluginsDirectory:(NSString*)value {
  [DEFS setObject:value forKey:@"pluginsDirectory"];
}

+ (BOOL)isFirstTimeAppRun {
  return ![DEFS boolForKey:@"appHasRun"];
}

+ (void)setNotFirstTimeAppRun {
  [DEFS setBool:YES forKey:@"appHasRun"];
}

@end
