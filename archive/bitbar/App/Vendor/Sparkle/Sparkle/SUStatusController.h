//
//  SUStatusController.h
//  Sparkle
//
//  Created by Andy Matuschak on 3/14/06.
//  Copyright 2006 Andy Matuschak. All rights reserved.
//

#ifndef SUSTATUSCONTROLLER_H
#define SUSTATUSCONTROLLER_H

#import "SUWindowController.h"

@class SUHost;
@interface SUStatusController : SUWindowController
@property (weak) IBOutlet NSButton *actionButton;
@property (weak) IBOutlet NSProgressIndicator *progressBar;

@property (copy) NSString *statusText;
@property double progressValue;
@property (nonatomic) double maxProgressValue;
@property (getter=isButtonEnabled) BOOL buttonEnabled;

- (instancetype)initWithHost:(SUHost *)host;

// Pass 0 for the max progress value to get an indeterminate progress bar.
// Pass nil for the status text to not show it.
- (void)beginActionWithTitle:(NSString *)title maxProgressValue:(double)maxProgressValue statusText:(NSString *)statusText;

// If isDefault is YES, the button's key equivalent will be \r.
- (void)setButtonTitle:(NSString *)buttonTitle target:(id)target action:(SEL)action isDefault:(BOOL)isDefault;

@end

#endif
