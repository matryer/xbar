//
//  Settings.h
//  BitBar
//
//  Created by Mat Ryer on 11/13/13.
//  Copyright (c) 2013 Bit Bar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Settings : NSObject

+ (NSString *)pluginsDirectory;
+ (void)setPluginsDirectory:(NSString*)value;

@end
