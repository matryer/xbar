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

// disables opening plugins, hides advanced menu items. for global setting use
// `defaults write /Library/Preferences/com.matryer.BitBar userConfigDisabled -bool true`
@property BOOL userConfigDisabled;

@end

#define DEFS NSUserDefaults.standardUserDefaults
