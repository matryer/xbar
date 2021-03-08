//
//  PluginManager+Test.h
//  BitBar
//
//  Created by Kent Karlsson on 3/11/16.
//  Copyright © 2016 Bit Bar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PluginManager.h"

@interface PluginManager (Test)

+ (NSString*)pluginPath;
+ (PluginManager*)testManager;

@end
