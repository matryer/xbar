//
//  ExecutablePlugin.h
//  BitBar
//
//  Created by Mathias Leppich on 22/01/14.
//  Copyright (c) 2014 Bit Bar. All rights reserved.
//

#import "Plugin.h"

@interface ExecutablePlugin : Plugin

@property (nonatomic, strong) NSTimer *lineCycleTimer;
@property (nonatomic, strong) NSTimer *refreshTimer;

- (BOOL) refreshContentByExecutingCommand;
- (BOOL)refreshContentByExecutingCommand:(NSArray<NSString *> *)args;

@end
