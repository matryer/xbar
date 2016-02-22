//
//  Settings.h
//  BitBar
//
//  Created by Mat Ryer on 11/13/13.
//  Copyright (c) 2013 Bit Bar. All rights reserved.
//

@import Foundation;

@interface NSUserDefaults (Settings)

@property NSString* pluginsDirectory;
@property BOOL isFirstTimeAppRun;
@property BOOL userConfigDisabled;

@end

#define DEFS NSUserDefaults.standardUserDefaults
