//
//  Plugin.h
//  BitBar
//
//  Created by Mat Ryer on 11/12/13.
//  Copyright (c) 2013 Bit Bar. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PluginManager;

@interface Plugin : NSObject

@property (nonatomic, copy) NSString *path;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *errorContent;
@property (nonatomic, strong) NSNumber *refreshIntervalSeconds;
@property (readonly, nonatomic, strong) PluginManager* manager;
@property (nonatomic, strong) NSStatusItem *statusItem;

- (id) initWithManager:(PluginManager*)manager;

- (BOOL) refreshContentByExecutingCommand;

@end
