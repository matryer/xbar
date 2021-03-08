//
//  fileop.m
//  fileop
//
//  Created by Mayur Pawashe on 6/5/16.
//  Copyright © 2016 Sparkle Project. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SUFileManager.h"
#import "SUFileOperationConstants.h"

// If we fail, we exit with a unique status code
// We don't try to NSLog because the logs can't be seen anywhere,
// and we don't want to log to a file irresponsibly (especially as root),
// nor want to communicate to the parent forcing the parent to read from the stdout pipe
// (allowing us to avoid any sort of potential blocking issues?)
typedef NS_ENUM(uint8_t, SUFileOpError)
{
    SUWritePIDFailure = 0x02,
    SUFlushFailure = 0x03,
    SUInsufficientNumberOfArguments = 0x04,
    SUCommandNameUTF8ParseFailure = 0x05,
    SUPathUTF8ParseFailure = 0x06,
    SUQuarantineRemovalFailure = 0x07,
    SUCopyFailure = 0x08,
    SUMoveFailure = 0x09,
    SUChangeOwnerAndGroupFailure = 0x0A,
    SUTouchFailure = 0x0B,
    SUMakeDirectoryFailure = 0x0C,
    SURemoveFailure = 0x0D,
    SUPackageFailureStatusCode = 0x0E,
    SUPackageRaisedExceptionFailure = 0x0F,
    SUInvalidCommandFailure = 0x10,
    // This code can be OR'd with another one to produce a unique combination
    SUInvalidOrNoDestination = 0x80
};

int main(int argc, const char *argv[])
{
	@autoreleasepool {
        // Before we do anything, we should let the parent know our pid so they can wait() on us
        // We do this because AuthorizationExecuteWithPrivileges() has no way of reporting back the child pid,
        // but it does give us a communication pipe
        uint32_t pid = CFSwapInt32HostToLittle((uint32_t)getpid());
        if (fwrite(&pid, sizeof(pid), 1, stdout) < 1) {
            exit(SUWritePIDFailure);
        }
        
        if (fflush(stdout) != 0) {
            exit(SUFlushFailure);
        }
        
        // At least we need the command name and file path arguments
        if (argc < 3) {
            exit(SUInsufficientNumberOfArguments);
        }
        
        NSString *command = [[NSString alloc] initWithUTF8String:argv[1]];
        if (command == nil) {
            exit(SUCommandNameUTF8ParseFailure);
        }
        
        NSString *filepath = [[NSString alloc] initWithUTF8String:argv[2]];
        if (filepath == nil) {
            exit(SUPathUTF8ParseFailure);
        }
        
        NSURL *fileURL = [NSURL fileURLWithPath:filepath];
        if (fileURL == nil) {
            exit(SUPathUTF8ParseFailure);
        }
        
        NSURL *destinationURL = nil;
        if (argc >= 4) {
            NSString *destinationPath = [[NSString alloc] initWithUTF8String:argv[3]];
            if (destinationPath != nil) {
                destinationURL = [NSURL fileURLWithPath:destinationPath];
            }
        }
        
        // This tool should be executed as root, so we should not try to authorize
        SUFileManager *fileManager = [SUFileManager defaultManager];
        
        if ([command isEqualToString:@(SUFileOpRemoveQuarantineCommand)]) {
            if (![fileManager releaseItemFromQuarantineAtRootURL:fileURL error:NULL]) {
                exit(SUQuarantineRemovalFailure);
            }
        } else if ([command isEqualToString:@(SUFileOpCopyCommand)]) {
            if (destinationURL != nil) {
                if (![fileManager copyItemAtURL:fileURL toURL:destinationURL error:NULL]) {
                    exit(SUCopyFailure);
                }
            } else {
                exit(SUInvalidOrNoDestination | SUCopyFailure);
            }
        } else if ([command isEqualToString:@(SUFileOpMoveCommand)]) {
            if (destinationURL != nil) {
                if (![fileManager moveItemAtURL:fileURL toURL:destinationURL error:NULL]) {
                    exit(SUMoveFailure);
                }
            } else {
                exit(SUInvalidOrNoDestination | SUMoveFailure);
            }
        } else if ([command isEqualToString:@(SUFileOpChangeOwnerAndGroupCommand)]) {
            if (destinationURL != nil) {
                if (![fileManager changeOwnerAndGroupOfItemAtRootURL:fileURL toMatchURL:destinationURL error:NULL]) {
                    exit(SUChangeOwnerAndGroupFailure);
                }
            } else {
                exit(SUInvalidOrNoDestination | SUChangeOwnerAndGroupFailure);
            }
        } else if ([command isEqualToString:@(SUFileOpUpdateModificationAndAccessTimeCommand)]) {
            if (![fileManager updateModificationAndAccessTimeOfItemAtURL:fileURL error:NULL]) {
                exit(SUTouchFailure);
            }
        } else if ([command isEqualToString:@(SUFileOpMakeDirectoryCommand)]) {
            if (![fileManager makeDirectoryAtURL:fileURL error:NULL]) {
                exit(SUMakeDirectoryFailure);
            }
        } else if ([command isEqualToString:@(SUFileOpRemoveCommand)]) {
            if (![fileManager removeItemAtURL:fileURL error:NULL]) {
                exit(SURemoveFailure);
            }
        } else if ([command isEqualToString:@(SUFileOpInstallCommand)]) {
            // The one command that can *only* be run as the root user
            NSString *installerPath = @"/usr/sbin/installer";
            
            NSTask *task = [[NSTask alloc] init];
            task.launchPath = installerPath;
            task.arguments = @[@"-pkg", filepath, @"-target", @"/"];
            // Output won't show up anyway, so we may as well ignore it
            task.standardError = [NSPipe pipe];
            task.standardOutput = [NSPipe pipe];
            
            @try {
                [task launch];
                [task waitUntilExit];
                if (task.terminationStatus != EXIT_SUCCESS) {
                    exit(SUPackageFailureStatusCode);
                }
            } @catch (NSException *) {
                exit(SUPackageRaisedExceptionFailure);
            }
        } else {
            exit(SUInvalidCommandFailure);
        }
        
        return EXIT_SUCCESS;
	}
}
