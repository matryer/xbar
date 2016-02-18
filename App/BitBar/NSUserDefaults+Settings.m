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
#ifdef DISTRO
  return [self stringForKey:@"pluginsDirectory"] ?: [NSBundle mainBundle].executablePath.stringByDeletingLastPathComponent;
#else
  return [self stringForKey:@"pluginsDirectory"];
#endif
}
- (void) setPluginsDirectory:(NSString*)value {

  [self setObject:value forKey:@"pluginsDirectory"];
}

- (BOOL) isFirstTimeAppRun { return ![self boolForKey:@"appHasRun"]; }

- (void) setIsFirstTimeAppRun:(BOOL)firstTime {
  [self setBool:!firstTime forKey:@"appHasRun"];
}

- (BOOL)userConfigDisabled {
#ifdef DISTRO
  id disabled = [self objectForKey:@"userConfigDisabled"];
  return disabled ? [disabled boolValue] : YES;
#else
  return [self boolForKey:@"userConfigDisabled"];
#endif
}

- (void)setUserConfigDisabled:(BOOL)disabled {
  [self setBool:disabled forKey:@"userConfigDisabled"];
}

@end

