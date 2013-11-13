//
//  Plugin.h
//  BitBar
//
//  Created by Mat Ryer on 11/12/13.
//  Copyright (c) 2013 Bit Bar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Plugin : NSObject

@property (nonatomic, copy) NSString *path;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSNumber *refreshIntervalSeconds;

@end
