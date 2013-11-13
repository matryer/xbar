//
//  PluginManager.h
//  BitBar
//
//  Created by Mat Ryer on 11/12/13.
//  Copyright (c) 2013 Bit Bar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PluginManager : NSObject

@property (nonatomic, copy) NSString *path;

- (id) initWithPluginPath:(NSString *)path;

- (NSArray *) pluginFiles;

@end
