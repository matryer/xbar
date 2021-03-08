//
//  SUBinaryDeltaUnarchiver.m
//  Sparkle
//
//  Created by Mark Rowe on 2009-06-03.
//  Copyright 2009 Mark Rowe. All rights reserved.
//

#import "SUBinaryDeltaCommon.h"
#import "SUBinaryDeltaUnarchiver.h"
#import "SUBinaryDeltaApply.h"
#import "SUUnarchiver_Private.h"
#import "SUHost.h"
#import "SULog.h"
#import "NTSynchronousTask.h"

@implementation SUBinaryDeltaUnarchiver

+ (BOOL)canUnarchivePath:(NSString *)path
{
    return [[path pathExtension] isEqualToString:@"delta"];
}

- (void)applyBinaryDelta
{
    @autoreleasepool {
        NSString *sourcePath = self.updateHostBundlePath;
        NSString *targetPath = [[self.archivePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:[sourcePath lastPathComponent]];

        NSError *applyDiffError = nil;
        BOOL success = applyBinaryDelta(sourcePath, targetPath, self.archivePath, NO, &applyDiffError);
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self notifyDelegateOfSuccess];
            });
        }
        else {
            SULog(@"Applying delta patch failed with error: %@", applyDiffError);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self notifyDelegateOfFailure];
            });
        }
    }
}

- (void)start
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self applyBinaryDelta];
    });
}

+ (void)load
{
    [self registerImplementation:self];
}

@end
