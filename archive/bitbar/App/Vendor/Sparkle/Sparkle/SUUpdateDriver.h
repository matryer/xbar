//
//  SUUpdateDriver.h
//  Sparkle
//
//  Created by Andy Matuschak on 5/7/08.
//  Copyright 2008 Andy Matuschak. All rights reserved.
//

#ifndef SUUPDATEDRIVER_H
#define SUUPDATEDRIVER_H

#import <Cocoa/Cocoa.h>

extern NSString *const SUUpdateDriverFinishedNotification;

@class SUHost, SUUpdater;
@interface SUUpdateDriver : NSObject <NSURLDownloadDelegate>

@property (readonly, weak) SUUpdater *updater;
@property (strong) SUHost *host;

- (instancetype)initWithUpdater:(SUUpdater *)updater;
- (void)checkForUpdatesAtURL:(NSURL *)URL host:(SUHost *)host;
- (void)abortUpdate;

- (void)showAlert:(NSAlert *)alert;

@property (getter=isInterruptible, readonly) BOOL interruptible;
@property (readonly) BOOL finished;
@property BOOL automaticallyInstallUpdates;

@end

#endif
