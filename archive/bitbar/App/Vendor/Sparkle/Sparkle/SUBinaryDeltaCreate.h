//
//  SUBinaryDeltaCreate.m
//  Sparkle
//
//  Created by Mayur Pawashe on 4/9/15.
//  Copyright (c) 2015 Sparkle Project. All rights reserved.
//

#ifndef SUBINARYDELTACREATE_H
#define SUBINARYDELTACREATE_H

#import "SUBinaryDeltaCommon.h"

@class NSString;
BOOL createBinaryDelta(NSString *source, NSString *destination, NSString *patchFile, SUBinaryDeltaMajorVersion majorVersion, BOOL verbose, NSError * __autoreleasing *error);

#endif
