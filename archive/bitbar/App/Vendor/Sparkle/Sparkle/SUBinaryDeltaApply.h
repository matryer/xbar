//
//  SUBinaryDeltaApply.h
//  Sparkle
//
//  Created by Mark Rowe on 2009-06-01.
//  Copyright 2009 Mark Rowe. All rights reserved.
//

#ifndef SUBINARYDELTAAPPLY_H
#define SUBINARYDELTAAPPLY_H

@class NSString;
BOOL applyBinaryDelta(NSString *source, NSString *destination, NSString *patchFile, BOOL verbose, NSError * __autoreleasing *error);

#endif
