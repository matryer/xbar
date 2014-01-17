//
//  Settings.m
//  BitBar
//
//  Created by Mat Ryer on 11/13/13.
//  Copyright (c) 2013 Bit Bar. All rights reserved.
//

#import "Settings.h"

@implementation Settings

+ (NSString *)pluginsDirectory {
  return [[NSUserDefaults standardUserDefaults] stringForKey:@"pluginsDirectory"];
}
+ (void)setPluginsDirectory:(NSString*)value {
  [[NSUserDefaults standardUserDefaults] setObject:value forKey:@"pluginsDirectory"];
}

+ (BOOL)isFirstTimeAppRun {
  return ![[NSUserDefaults standardUserDefaults] boolForKey:@"appHasRun"];
}

+ (void)setNotFirstTimeAppRun {
  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"appHasRun"];
}

@end
