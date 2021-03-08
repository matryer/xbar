//
//  SUWindowController.h
//  Sparkle
//
//  Created by Andy Matuschak on 2/13/08.
//  Copyright 2008 Andy Matuschak. All rights reserved.
//

#ifndef SUWINDOWCONTROLLER_H
#define SUWINDOWCONTROLLER_H

#import <Cocoa/Cocoa.h>

@class SUHost;
@interface SUWindowController : NSWindowController
// We use this instead of plain old NSWindowController initWithWindowNibName so that we'll be able to find the right path when running in a bundle loaded from another app.
- (instancetype)initWithWindowNibName:(NSString *)nibName;
@end

#endif
