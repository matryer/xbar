//
//  SUAutomaticUpdateDriver.h
//  Sparkle
//
//  Created by Andy Matuschak on 5/6/08.
//  Copyright 2008 Andy Matuschak. All rights reserved.
//

#ifndef SUAUTOMATICUPDATEDRIVER_H
#define SUAUTOMATICUPDATEDRIVER_H

#import <Cocoa/Cocoa.h>
#import "SUBasicUpdateDriver.h"
#import "SUAutomaticUpdateAlert.h"

@interface SUAutomaticUpdateDriver : SUBasicUpdateDriver <SUUnarchiverDelegate>

@end

#endif
