//
//  SUAutomaticUpdateAlert.h
//  Sparkle
//
//  Created by Andy Matuschak on 3/18/06.
//  Copyright 2006 Andy Matuschak. All rights reserved.
//

#ifndef SUAUTOMATICUPDATEALERT_H
#define SUAUTOMATICUPDATEALERT_H

#import "SUWindowController.h"

typedef NS_ENUM(NSInteger, SUAutomaticInstallationChoice) {
    SUInstallNowChoice,
    SUInstallLaterChoice,
    SUDoNotInstallChoice
};

@class SUAppcastItem, SUHost;
@interface SUAutomaticUpdateAlert : SUWindowController

- (instancetype)initWithAppcastItem:(SUAppcastItem *)item host:(SUHost *)hostBundle completionBlock:(void (^)(SUAutomaticInstallationChoice))c;
- (IBAction)installNow:sender;
- (IBAction)installLater:sender;
- (IBAction)doNotInstall:sender;

@end

#endif
