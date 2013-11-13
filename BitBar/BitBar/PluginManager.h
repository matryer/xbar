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
@property (nonatomic, strong) NSDictionary *plugins;
@property (nonatomic, strong) NSStatusBar *statusBar;

- (id) initWithPluginPath:(NSString *)path;

- (NSArray *) pluginFiles;

- (NSDictionary *)plugins;

@end
