//
//  SUUpdateSettingsWindowController.m
//  Sparkle
//
//  Created by Mayur Pawashe on 7/25/15.
//  Copyright (c) 2015 Sparkle Project. All rights reserved.
//

#import "SUUpdateSettingsWindowController.h"
#import <Sparkle/Sparkle.h>

@interface SUUpdateSettingsWindowController ()

@property (nonatomic) IBOutlet SUUpdater *updater;

@end

@implementation SUUpdateSettingsWindowController

@synthesize updater = _updater;

- (NSString *)windowNibName
{
    return NSStringFromClass([self class]);
}

- (IBAction)checkForUpdates:(id __unused)sender
{
    [self.updater checkForUpdates:nil];
}

@end
