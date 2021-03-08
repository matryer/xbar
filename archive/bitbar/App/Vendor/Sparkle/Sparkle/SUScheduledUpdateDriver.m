//
//  SUScheduledUpdateDriver.m
//  Sparkle
//
//  Created by Andy Matuschak on 5/6/08.
//  Copyright 2008 Andy Matuschak. All rights reserved.
//

#import "SUScheduledUpdateDriver.h"
#import "SUUpdater.h"

#import "SUAppcast.h"
#import "SUAppcastItem.h"
#import "SUVersionComparisonProtocol.h"

@interface SUScheduledUpdateDriver ()

@property (assign) BOOL showErrors;

@end

@implementation SUScheduledUpdateDriver

@synthesize showErrors;

- (void)didFindValidUpdate
{
    self.showErrors = YES; // We only start showing errors after we present the UI for the first time.
    [super didFindValidUpdate];
}

- (void)didNotFindUpdate
{
    id<SUUpdaterDelegate> updaterDelegate = [self.updater delegate];

    if ([updaterDelegate respondsToSelector:@selector(updaterDidNotFindUpdate:)]) {
        [updaterDelegate updaterDidNotFindUpdate:self.updater];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:SUUpdaterDidNotFindUpdateNotification object:self.updater];

    [self abortUpdate]; // Don't tell the user that no update was found; this was a scheduled update.
}

- (void)abortUpdateWithError:(NSError *)error
{
    if (self.showErrors) {
        [super abortUpdateWithError:error];
    } else {
        // Call delegate separately here because otherwise it won't know we stopped.
        // Normally this gets called by the superclass
        id<SUUpdaterDelegate> updaterDelegate = [self.updater delegate];
        if ([updaterDelegate respondsToSelector:@selector(updater:didAbortWithError:)]) {
            [updaterDelegate updater:self.updater didAbortWithError:error];
        }

        [self abortUpdate];
    }
}

@end
