//
//  BitBarController.h
//  BitBar
//
//  Created by Mat Ryer on 11/13/13.
//  Copyright (c) 2013 Bit Bar. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PluginManager;

@interface BitBarController : NSObject

@property (nonatomic, strong) PluginManager *pluginManager;

- (void) startApp;

@end
