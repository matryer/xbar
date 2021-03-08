//
//  SUUpdateAlert.h
//  Sparkle
//
//  Created by Andy Matuschak on 3/12/06.
//  Copyright 2006 Andy Matuschak. All rights reserved.
//

#ifndef SUUPDATEALERT_H
#define SUUPDATEALERT_H

#import "SUWindowController.h"
#import "SUVersionDisplayProtocol.h"

@protocol SUUpdateAlertDelegate;

typedef NS_ENUM(NSInteger, SUUpdateAlertChoice) {
    SUInstallUpdateChoice,
    SURemindMeLaterChoice,
    SUSkipThisVersionChoice,
    SUOpenInfoURLChoice
};

@class SUAppcastItem, SUHost;
@interface SUUpdateAlert : SUWindowController

@property (weak) id<SUVersionDisplay> versionDisplayer;

- (instancetype)initWithAppcastItem:(SUAppcastItem *)item host:(SUHost *)host completionBlock:(void(^)(SUUpdateAlertChoice))c;

- (IBAction)installUpdate:sender;
- (IBAction)skipThisVersion:sender;
- (IBAction)remindMeLater:sender;

@end

#endif
