//
//  SUInstaller.m
//  Sparkle
//
//  Created by Andy Matuschak on 4/10/08.
//  Copyright 2008 Andy Matuschak. All rights reserved.
//

#import "SUInstaller.h"
#import "SUPlainInstaller.h"
#import "SUPackageInstaller.h"
#import "SUGuidedPackageInstaller.h"
#import "SUHost.h"
#import "SUConstants.h"
#import "SULog.h"

@implementation SUInstaller

+ (BOOL)isAliasFolderAtPath:(NSString *)path
{
    NSNumber *aliasFlag = nil;
    [[NSURL fileURLWithPath:path] getResourceValue:&aliasFlag forKey:NSURLIsAliasFileKey error:nil];
    NSNumber *directoryFlag = nil;
    [[NSURL fileURLWithPath:path] getResourceValue:&directoryFlag forKey:NSURLIsDirectoryKey error:nil];
    return aliasFlag.boolValue && directoryFlag.boolValue;
}

+ (NSString *)installSourcePathInUpdateFolder:(NSString *)inUpdateFolder forHost:(SUHost *)host isPackage:(BOOL *)isPackagePtr isGuided:(BOOL *)isGuidedPtr
{
    SUParameterAssert(inUpdateFolder);
    SUParameterAssert(host);

    // Search subdirectories for the application
    NSString *currentFile,
        *newAppDownloadPath = nil,
        *bundleFileName = [[host bundlePath] lastPathComponent],
        *alternateBundleFileName = [[host name] stringByAppendingPathExtension:[[host bundlePath] pathExtension]];
    BOOL isPackage = NO;
    BOOL isGuided = NO;
    NSString *fallbackPackagePath = nil;
    NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:inUpdateFolder];
    NSString *bundleFileNameNoExtension = [bundleFileName stringByDeletingPathExtension];

    while ((currentFile = [dirEnum nextObject])) {
        NSString *currentPath = [inUpdateFolder stringByAppendingPathComponent:currentFile];
        NSString *currentFilename = [currentFile lastPathComponent];
        NSString *currentExtension = [currentFile pathExtension];
        NSString *currentFilenameNoExtension = [currentFilename stringByDeletingPathExtension];
        if ([currentFilename isEqualToString:bundleFileName] ||
            [currentFilename isEqualToString:alternateBundleFileName]) // We found one!
        {
            isPackage = NO;
            newAppDownloadPath = currentPath;
            break;
        } else if ([currentExtension isEqualToString:@"pkg"] ||
                   [currentExtension isEqualToString:@"mpkg"]) {
            if ([currentFilenameNoExtension isEqualToString:bundleFileNameNoExtension]) {
                isPackage = YES;
                newAppDownloadPath = currentPath;
                break;
            } else {
                // Remember any other non-matching packages we have seen should we need to use one of them as a fallback.
                fallbackPackagePath = currentPath;
            }
        } else {
            // Try matching on bundle identifiers in case the user has changed the name of the host app
            NSBundle *incomingBundle = [NSBundle bundleWithPath:currentPath];
            NSString *hostBundleIdentifier = host.bundle.bundleIdentifier;
            if (incomingBundle && [incomingBundle.bundleIdentifier isEqualToString:hostBundleIdentifier]) {
                isPackage = NO;
                newAppDownloadPath = currentPath;
                break;
            }
        }

        // Some DMGs have symlinks into /Applications! That's no good!
        if ([self isAliasFolderAtPath:currentPath])
            [dirEnum skipDescendents];
    }

    // We don't have a valid path. Try to use the fallback package.

    if (newAppDownloadPath == nil && fallbackPackagePath != nil) {
        isPackage = YES;
        newAppDownloadPath = fallbackPackagePath;
    }

    if (isPackage) {
        // foo.app -> foo.sparkle_guided.pkg or foo.sparkle_guided.mpkg
        if ([[[newAppDownloadPath stringByDeletingPathExtension] pathExtension] isEqualToString:@"sparkle_guided"]) {
            isGuided = YES;
        }
    }

    if (isPackagePtr)
        *isPackagePtr = isPackage;
    if (isGuidedPtr)
        *isGuidedPtr = isGuided;

    if (!newAppDownloadPath) {
        SULog(@"Searched %@ for %@.(app|pkg)", inUpdateFolder, bundleFileNameNoExtension);
    }
    return newAppDownloadPath;
}

+ (void)installFromUpdateFolder:(NSString *)inUpdateFolder overHost:(SUHost *)host installationPath:(NSString *)installationPath fileOperationToolPath:(NSString *)fileOperationToolPath versionComparator:(id<SUVersionComparison>)comparator completionHandler:(void (^)(NSError *))completionHandler
{
    BOOL isPackage = NO;
    BOOL isGuided = NO;
    NSString *newAppDownloadPath = [self installSourcePathInUpdateFolder:inUpdateFolder forHost:host isPackage:&isPackage isGuided:&isGuided];

    if (newAppDownloadPath == nil) {
        [self finishInstallationToPath:installationPath withResult:NO error:[NSError errorWithDomain:SUSparkleErrorDomain code:SUMissingUpdateError userInfo:@{ NSLocalizedDescriptionKey: @"Couldn't find an appropriate update in the downloaded package." }] completionHandler:completionHandler];
    } else {
        if (isPackage && isGuided) {
            [SUGuidedPackageInstaller performInstallationToPath:installationPath fromPath:newAppDownloadPath host:host fileOperationToolPath:fileOperationToolPath versionComparator:comparator completionHandler:completionHandler];
        } else if (isPackage) {
            [SUPackageInstaller performInstallationToPath:installationPath fromPath:newAppDownloadPath host:host fileOperationToolPath:fileOperationToolPath versionComparator:comparator completionHandler:completionHandler];
        } else {
            [SUPlainInstaller performInstallationToPath:installationPath fromPath:newAppDownloadPath host:host fileOperationToolPath:fileOperationToolPath versionComparator:comparator completionHandler:completionHandler];
        }
    }
}

+ (void)mdimportInstallationPath:(NSString *)installationPath
{
    // *** GETS CALLED ON NON-MAIN THREAD!

    SULog(@"mdimporting");

    NSTask *mdimport = [[NSTask alloc] init];
    [mdimport setLaunchPath:@"/usr/bin/mdimport"];
    [mdimport setArguments:@[installationPath]];
    @try {
        [mdimport launch];
        [mdimport waitUntilExit];
    }
    @catch (NSException *launchException)
    {
        // No big deal.
        SULog(@"Error: %@", [launchException description]);
    }
}

+ (void)finishInstallationToPath:(NSString *)installationPath withResult:(BOOL)result error:(NSError *)error completionHandler:(void (^)(NSError *))completionHandler
{
    if (result) {
        [self mdimportInstallationPath:installationPath];
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(nil);
        });
    } else {
        if (!error) {
            error = [NSError errorWithDomain:SUSparkleErrorDomain code:SUInstallationError userInfo:nil];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(error);
        });
    }
}

@end
