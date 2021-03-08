//
//  SUBasicUpdateDriver.m
//  Sparkle
//
//  Created by Andy Matuschak on 4/23/08.
//  Copyright 2008 Andy Matuschak. All rights reserved.
//

#import "SUBasicUpdateDriver.h"

#import "SUHost.h"
#import "SUOperatingSystem.h"
#import "SUDSAVerifier.h"
#import "SUInstaller.h"
#import "SUStandardVersionComparator.h"
#import "SUUnarchiver.h"
#import "SUConstants.h"
#import "SULog.h"
#import "SUBinaryDeltaCommon.h"
#import "SUCodeSigningVerifier.h"
#import "SUUpdater_Private.h"
#import "SUFileManager.h"

@interface SUBasicUpdateDriver ()

@property (strong) SUAppcastItem *updateItem;
@property (strong) NSURLDownload *download;
@property (copy) NSString *downloadPath;

@property (strong) SUAppcastItem *nonDeltaUpdateItem;
@property (copy) NSString *tempDir;
@property (copy) NSString *relaunchPath;

@end

@implementation SUBasicUpdateDriver

@synthesize updateItem;
@synthesize download;
@synthesize downloadPath;

@synthesize nonDeltaUpdateItem;
@synthesize tempDir;
@synthesize relaunchPath;

- (void)checkForUpdatesAtURL:(NSURL *)URL host:(SUHost *)aHost
{
    [super checkForUpdatesAtURL:URL host:aHost];
	if ([aHost isRunningOnReadOnlyVolume])
	{
        [self abortUpdateWithError:[NSError errorWithDomain:SUSparkleErrorDomain code:SURunningFromDiskImageError userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:SULocalizedString(@"%1$@ can't be updated when it's running from a read-only volume like a disk image or an optical drive. Move %1$@ to your Applications folder, relaunch it from there, and try again.", nil), [aHost name]] }]];
        return;
    }

    SUAppcast *appcast = [[SUAppcast alloc] init];

    [appcast setUserAgentString:[self.updater userAgentString]];
    [appcast setHttpHeaders:[self.updater httpHeaders]];
    [appcast fetchAppcastFromURL:URL completionBlock:^(NSError *error) {
        if (error) {
            [self abortUpdateWithError:error];
        } else {
            [self appcastDidFinishLoading:appcast];
        }
    }];
}

- (id<SUVersionComparison>)versionComparator
{
    id<SUVersionComparison> comparator = nil;

    // Give the delegate a chance to provide a custom version comparator
    if ([[self.updater delegate] respondsToSelector:@selector(versionComparatorForUpdater:)]) {
        comparator = [[self.updater delegate] versionComparatorForUpdater:self.updater];
    }

    // If we don't get a comparator from the delegate, use the default comparator
    if (!comparator) {
        comparator = [SUStandardVersionComparator defaultComparator];
    }

    return comparator;
}

+ (SUAppcastItem *)bestItemFromAppcastItems:(NSArray *)appcastItems getDeltaItem:(SUAppcastItem * __autoreleasing *)deltaItem withHostVersion:(NSString *)hostVersion comparator:(id<SUVersionComparison>)comparator
{
    SUAppcastItem *item = nil;
    for(SUAppcastItem *candidate in appcastItems) {
        if ([[self class] hostSupportsItem:candidate]) {
            if (!item || [comparator compareVersion:item.versionString toVersion:candidate.versionString] == NSOrderedAscending) {
                item = candidate;
            }
        }
    }
    
    if (item && deltaItem) {
        SUAppcastItem *deltaUpdateItem = [[item deltaUpdates] objectForKey:hostVersion];
        if (deltaUpdateItem && [[self class] hostSupportsItem:deltaUpdateItem]) {
            *deltaItem = deltaUpdateItem;
        }
    }
    
    return item;
}

+ (BOOL)hostSupportsItem:(SUAppcastItem *)ui
{
	if (([ui minimumSystemVersion] == nil || [[ui minimumSystemVersion] isEqualToString:@""]) &&
        ([ui maximumSystemVersion] == nil || [[ui maximumSystemVersion] isEqualToString:@""])) { return YES; }

    BOOL minimumVersionOK = TRUE;
    BOOL maximumVersionOK = TRUE;

    // Check minimum and maximum System Version
    if ([ui minimumSystemVersion] != nil && ![[ui minimumSystemVersion] isEqualToString:@""]) {
        minimumVersionOK = [[SUStandardVersionComparator defaultComparator] compareVersion:[ui minimumSystemVersion] toVersion:[SUOperatingSystem systemVersionString]] != NSOrderedDescending;
    }
    if ([ui maximumSystemVersion] != nil && ![[ui maximumSystemVersion] isEqualToString:@""]) {
        maximumVersionOK = [[SUStandardVersionComparator defaultComparator] compareVersion:[ui maximumSystemVersion] toVersion:[SUOperatingSystem systemVersionString]] != NSOrderedAscending;
    }

    return minimumVersionOK && maximumVersionOK;
}

- (BOOL)isItemNewer:(SUAppcastItem *)ui
{
    return [[self versionComparator] compareVersion:[self.host version] toVersion:[ui versionString]] == NSOrderedAscending;
}

- (BOOL)itemContainsSkippedVersion:(SUAppcastItem *)ui
{
    NSString *skippedVersion = [self.host objectForUserDefaultsKey:SUSkippedVersionKey];
	if (skippedVersion == nil) { return NO; }
    return [[self versionComparator] compareVersion:[ui versionString] toVersion:skippedVersion] != NSOrderedDescending;
}

- (BOOL)itemContainsValidUpdate:(SUAppcastItem *)ui
{
    return ui && [[self class] hostSupportsItem:ui] && [self isItemNewer:ui] && ![self itemContainsSkippedVersion:ui];
}

- (void)appcastDidFinishLoading:(SUAppcast *)ac
{
    if ([[self.updater delegate] respondsToSelector:@selector(updater:didFinishLoadingAppcast:)]) {
        [[self.updater delegate] updater:self.updater didFinishLoadingAppcast:ac];
    }

    NSDictionary *userInfo = (ac != nil) ? @{ SUUpdaterAppcastNotificationKey: ac } : nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:SUUpdaterDidFinishLoadingAppCastNotification object:self.updater userInfo:userInfo];

    SUAppcastItem *item = nil;

    // Now we have to find the best valid update in the appcast.
    if ([[self.updater delegate] respondsToSelector:@selector(bestValidUpdateInAppcast:forUpdater:)]) // Does the delegate want to handle it?
    {
        item = [[self.updater delegate] bestValidUpdateInAppcast:ac forUpdater:self.updater];
        if ([item isDeltaUpdate]) {
            self.nonDeltaUpdateItem = [[self.updater delegate] bestValidUpdateInAppcast:[ac copyWithoutDeltaUpdates] forUpdater:self.updater];
        }
	}
	else // If not, we'll take care of it ourselves.
    {
        // Find the best supported update
        SUAppcastItem *deltaUpdateItem = nil;
        item = [[self class] bestItemFromAppcastItems:ac.items getDeltaItem:&deltaUpdateItem withHostVersion:self.host.version comparator:[self versionComparator]];
        
        if (item && deltaUpdateItem) {
            self.nonDeltaUpdateItem = item;
            item = deltaUpdateItem;
        }
    }

    if ([self itemContainsValidUpdate:item]) {
        self.updateItem = item;
        [self didFindValidUpdate];
    } else {
        self.updateItem = nil;
        [self didNotFindUpdate];
    }
}

- (void)didFindValidUpdate
{
    assert(self.updateItem);

    if ([[self.updater delegate] respondsToSelector:@selector(updater:didFindValidUpdate:)]) {
        [[self.updater delegate] updater:self.updater didFindValidUpdate:self.updateItem];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:SUUpdaterDidFindValidUpdateNotification
                                                        object:self.updater
                                                      userInfo:@{ SUUpdaterAppcastItemNotificationKey: self.updateItem }];
    [self downloadUpdate];
}

- (void)didNotFindUpdate
{
    if ([[self.updater delegate] respondsToSelector:@selector(updaterDidNotFindUpdate:)]) {
        [[self.updater delegate] updaterDidNotFindUpdate:self.updater];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:SUUpdaterDidNotFindUpdateNotification object:self.updater];

    [self abortUpdateWithError:[NSError errorWithDomain:SUSparkleErrorDomain
                                                   code:SUNoUpdateError
                                               userInfo:@{
                                                   NSLocalizedDescriptionKey: [NSString stringWithFormat:SULocalizedString(@"You already have the newest version of %@.", "'Error' message when the user checks for updates but is already current or the feed doesn't contain any updates. (not necessarily shown in UI)"), self.host.name]
                                               }]];
}

- (NSString *)appCachePath
{
    NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = nil;
    if ([cachePaths count]) {
        cachePath = [cachePaths objectAtIndex:0];
    }
    if (!cachePath) {
        SULog(@"Failed to find user's cache directory! Using system default");
        cachePath = NSTemporaryDirectory();
    }
    
    NSString *name = [self.host.bundle bundleIdentifier];
    if (!name) {
        name = [self.host name];
    }
    
    cachePath = [cachePath stringByAppendingPathComponent:name];
    cachePath = [cachePath stringByAppendingPathComponent:@SPARKLE_BUNDLE_IDENTIFIER];
    return cachePath;
}

- (void)downloadUpdate
{
    // Clear cache directory so that downloads can't possibly accumulate inside
    NSString *appCachePath = [self appCachePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:appCachePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:appCachePath error:NULL];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[self.updateItem fileURL]];
    [request setValue:[self.updater userAgentString] forHTTPHeaderField:@"User-Agent"];
    if ([[self.updater delegate] respondsToSelector:@selector(updater:willDownloadUpdate:withRequest:)]) {
        [[self.updater delegate] updater:self.updater
                      willDownloadUpdate:self.updateItem
                             withRequest:request];
    }
    self.download = [[NSURLDownload alloc] initWithRequest:request delegate:self];
}

- (void)download:(NSURLDownload *)__unused d decideDestinationWithSuggestedFilename:(NSString *)name
{
    NSString *downloadFileName = [NSString stringWithFormat:@"%@ %@", [self.host name], [self.updateItem versionString]];
    
    NSString *appCachePath = [self appCachePath];
    
    self.tempDir = [appCachePath stringByAppendingPathComponent:downloadFileName];
    int cnt = 1;
	while ([[NSFileManager defaultManager] fileExistsAtPath:self.tempDir] && cnt <= 999)
	{
        self.tempDir = [appCachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ %d", downloadFileName, cnt++]];
    }

    // Create the temporary directory if necessary.
    BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:self.tempDir withIntermediateDirectories:YES attributes:nil error:NULL];
	if (!success)
	{
        // Okay, something's really broken with this user's file structure.
        [self.download cancel];
        [self abortUpdateWithError:[NSError errorWithDomain:SUSparkleErrorDomain code:SUTemporaryDirectoryError userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Can't make a temporary directory for the update download at %@.", self.tempDir] }]];
    }

    self.downloadPath = [self.tempDir stringByAppendingPathComponent:name];
    [self.download setDestination:self.downloadPath allowOverwrite:YES];
}

/**
 * If the update is a package, then it must be signed using DSA. No other verification is done.
 *
 * If the update is a bundle, then it must meet any one of:
 *
 *  * old and new DSA public keys are the same and valid (it allows change of Code Signing identity), or
 *
 *  * old and new Code Signing identity are the same and valid
 *
 */
- (BOOL)validateUpdateDownloadedToPath:(NSString *)downloadedPath extractedToPath:(NSString *)extractedPath DSASignature:(NSString *)DSASignature publicDSAKey:(NSString *)publicDSAKey
{
    BOOL isPackage = NO;
    NSString *installSourcePath = [SUInstaller installSourcePathInUpdateFolder:extractedPath forHost:self.host isPackage:&isPackage isGuided:NULL];
    if (installSourcePath == nil) {
        SULog(@"No suitable install is found in the update. The update will be rejected.");
        return NO;
    }
    
    // Modern packages are not distributed as bundles and are code signed differently than regular applications
    if (isPackage) {
        if (nil == publicDSAKey) {
            SULog(@"The existing app bundle does not have a DSA key, so it can't verify installer packages.");
        }

        BOOL packageValidated = [SUDSAVerifier validatePath:downloadedPath withEncodedDSASignature:DSASignature withPublicDSAKey:publicDSAKey];

        if (!packageValidated) {
            SULog(@"DSA signature validation of the package failed. The update contains an installer package, and valid DSA signatures are mandatory for all installer packages. The update will be rejected. Sign the installer with a valid DSA key or use an .app bundle update instead.");
        }
        
        return packageValidated;
    }
    
    NSBundle *newBundle = [NSBundle bundleWithPath:installSourcePath];
    if (newBundle == nil) {
        SULog(@"No suitable bundle is found in the update. The update will be rejected.");
        return NO;
    }
    
    SUHost *newHost = [[SUHost alloc] initWithBundle:newBundle];
    NSString *newPublicDSAKey = newHost.publicDSAKey;
    
    BOOL dsaKeysMatch = (publicDSAKey == nil || newPublicDSAKey == nil) ? NO : [publicDSAKey isEqualToString:newPublicDSAKey];
    
    // If the new DSA key differs from the old, then this check is not a security measure, because the new key is not trusted.
    // In that case, the check ensures that the app author has correctly used DSA keys, so that the app will be updateable in the next version.
    // However if the new and old DSA keys are the same, then this is a security measure.
    if (newPublicDSAKey != nil) {
        if (![SUDSAVerifier validatePath:downloadedPath withEncodedDSASignature:DSASignature withPublicDSAKey:newPublicDSAKey]) {
            SULog(@"DSA signature validation failed. The update has a public DSA key and is signed with a DSA key, but the %@ doesn't match the signature. The update will be rejected.",
                  dsaKeysMatch ? @"public key" : @"new public key shipped with the update");
            return NO;
        }
    }
    
    BOOL updateIsCodeSigned = [SUCodeSigningVerifier applicationAtPathIsCodeSigned:installSourcePath];

    if (dsaKeysMatch) {
        NSError *error = nil;
        if (updateIsCodeSigned && ![SUCodeSigningVerifier codeSignatureIsValidAtPath:installSourcePath error:&error]) {
            SULog(@"The update archive has a valid DSA signature, but the app is also signed with Code Signing, which is corrupted: %@. The update will be rejected.", error);
            return NO;
        }
    } else {
        BOOL hostIsCodeSigned = [SUCodeSigningVerifier hostApplicationIsCodeSigned];

        NSString *dsaStatus = newPublicDSAKey ? @"has a new DSA key that doesn't match the previous one" : (publicDSAKey ? @"removes the DSA key" : @"isn't signed with a DSA key");
        if (!hostIsCodeSigned || !updateIsCodeSigned) {
            NSString *acsStatus = !hostIsCodeSigned ? @"old app hasn't been signed with app Code Signing" : @"new app isn't signed with app Code Signing";
            SULog(@"The update archive %@, and the %@. At least one method of signature verification must be valid. The update will be rejected.", dsaStatus, acsStatus);
            return NO;
        }

        NSError *error = nil;
        if (![SUCodeSigningVerifier codeSignatureMatchesHostAndIsValidAtPath:installSourcePath error:&error]) {
            SULog(@"The update archive %@, and the app is signed with a new Code Signing identity that doesn't match code signing of the original app: %@. At least one method of signature verification must be valid. The update will be rejected.", dsaStatus, error);
            return NO;
        }
    }

    return YES;
}

- (void)downloadDidFinish:(NSURLDownload *)__unused d
{
    assert(self.updateItem);

    [self extractUpdate];
}

- (void)download:(NSURLDownload *)__unused download didFailWithError:(NSError *)error
{
    NSURL *failingUrl = [error.userInfo objectForKey:NSURLErrorFailingURLErrorKey];
    if (!failingUrl) {
        failingUrl = [self.updateItem fileURL];
    }

    if ([[self.updater delegate] respondsToSelector:@selector(updater:failedToDownloadUpdate:error:)]) {
        [[self.updater delegate] updater:self.updater
                  failedToDownloadUpdate:self.updateItem
                                   error:error];
    }

    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:@{
        NSLocalizedDescriptionKey: SULocalizedString(@"An error occurred while downloading the update. Please try again later.", nil),
        NSUnderlyingErrorKey: error,
    }];
    if (failingUrl) {
        [userInfo setObject:failingUrl forKey:NSURLErrorFailingURLErrorKey];
    }

    [self abortUpdateWithError:[NSError errorWithDomain:SUSparkleErrorDomain code:SUDownloadError userInfo:userInfo]];
}

- (BOOL)download:(NSURLDownload *)__unused download shouldDecodeSourceDataOfMIMEType:(NSString *)encodingType
{
    // We don't want the download system to extract our gzips.
    // Note that we use a substring matching here instead of direct comparison because the docs say "application/gzip" but the system *uses* "application/x-gzip". This is a documentation bug.
    return ([encodingType rangeOfString:@"gzip"].location == NSNotFound);
}

- (void)extractUpdate
{
    SUUnarchiver *unarchiver = [SUUnarchiver unarchiverForPath:self.downloadPath updatingHostBundlePath:[[self.host bundle] bundlePath] withPassword:self.updater.decryptionPassword];
    if (!unarchiver) {
        SULog(@"Error: No valid unarchiver for %@!", self.downloadPath);
        [self unarchiverDidFail:nil];
        return;
    }
    unarchiver.delegate = self;
    [unarchiver start];
}

- (void)failedToApplyDeltaUpdate
{
    // When a delta update fails to apply we fall back on updating via a full install.
    self.updateItem = self.nonDeltaUpdateItem;
    self.nonDeltaUpdateItem = nil;

    [self downloadUpdate];
}

- (void)unarchiverDidFinish:(SUUnarchiver *)__unused ua
{
    assert(self.updateItem);

    [self installWithToolAndRelaunch:YES];
}

- (void)unarchiverDidFail:(SUUnarchiver *)__unused ua
{
    if ([self.updateItem isDeltaUpdate]) {
        [self failedToApplyDeltaUpdate];
        return;
    }

    [self abortUpdateWithError:[NSError errorWithDomain:SUSparkleErrorDomain code:SUUnarchivingError userInfo:@{ NSLocalizedDescriptionKey: SULocalizedString(@"An error occurred while extracting the archive. Please try again later.", nil) }]];
}

- (void)installWithToolAndRelaunch:(BOOL)relaunch
{
    // Perhaps a poor assumption but: if we're not relaunching, we assume we shouldn't be showing any UI either. Because non-relaunching installations are kicked off without any user interaction, we shouldn't be interrupting them.
    [self installWithToolAndRelaunch:relaunch displayingUserInterface:relaunch];
}

// Creates intermediate directories up until targetPath if they don't already exist,
// and removes the directory at targetPath if one already exists there
- (BOOL)preparePathForRelaunchTool:(NSString *)targetPath error:(NSError * __autoreleasing *)error
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    if ([fileManager fileExistsAtPath:targetPath]) {
        NSError *removeError = nil;
        if (![fileManager removeItemAtPath:targetPath error:&removeError]) {
            if (error != NULL) {
                *error = removeError;
            }
            return NO;
        }
    } else {
        NSError *createDirectoryError = nil;
        if (![fileManager createDirectoryAtPath:[targetPath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:@{} error:&createDirectoryError]) {
            if (error != NULL) {
                *error = createDirectoryError;
            }
            return NO;
        }
    }
    return YES;
}

- (void)installWithToolAndRelaunch:(BOOL)relaunch displayingUserInterface:(BOOL)showUI
{
    assert(self.updateItem);

    if (![self validateUpdateDownloadedToPath:self.downloadPath extractedToPath:self.tempDir DSASignature:self.updateItem.DSASignature publicDSAKey:self.host.publicDSAKey])
    {
        NSDictionary *userInfo = @{
            NSLocalizedDescriptionKey: SULocalizedString(@"An error occurred while extracting the archive. Please try again later.", nil),
            NSLocalizedFailureReasonErrorKey: SULocalizedString(@"The update is improperly signed.", nil),
        };
        [self abortUpdateWithError:[NSError errorWithDomain:SUSparkleErrorDomain code:SUSignatureError userInfo:userInfo]];
        return;
    }

    if (![self.updater mayUpdateAndRestart])
    {
        [self abortUpdate];
        return;
    }

    // Give the host app an opportunity to postpone the install and relaunch.
    static BOOL postponedOnce = NO;
    id<SUUpdaterDelegate> updaterDelegate = [self.updater delegate];
    if (!postponedOnce && [updaterDelegate respondsToSelector:@selector(updater:shouldPostponeRelaunchForUpdate:untilInvoking:)])
    {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[[self class] instanceMethodSignatureForSelector:@selector(installWithToolAndRelaunch:)]];
        [invocation setSelector:@selector(installWithToolAndRelaunch:)];
        [invocation setArgument:&relaunch atIndex:2];
        [invocation setTarget:self];
        postponedOnce = YES;
        if ([updaterDelegate updater:self.updater shouldPostponeRelaunchForUpdate:self.updateItem untilInvoking:invocation]) {
            return;
        }
    }


    if ([updaterDelegate respondsToSelector:@selector(updater:willInstallUpdate:)]) {
        [updaterDelegate updater:self.updater willInstallUpdate:self.updateItem];
    }

    NSBundle *sparkleBundle = self.updater.sparkleBundle;

    // Copy the relauncher into a temporary directory so we can get to it after the new version's installed.
    // Only the paranoid survive: if there's already a stray copy of relaunch there, we would have problems.
    NSString *const relaunchToolName = @"" SPARKLE_RELAUNCH_TOOL_NAME;
    NSString *const relaunchPathToCopy = [sparkleBundle pathForResource:relaunchToolName ofType:@"app"];
    if (relaunchPathToCopy != nil) {
        NSString *targetPath = [[self appCachePath] stringByAppendingPathComponent:[relaunchPathToCopy lastPathComponent]];
        
        SUFileManager *fileManager = [SUFileManager defaultManager];
        NSError *error = nil;
        
        NSURL *relaunchURLToCopy = [NSURL fileURLWithPath:relaunchPathToCopy];
        NSURL *targetURL = [NSURL fileURLWithPath:targetPath];
        
        // We only need to run our copy of the app by spawning a task
        // Since we are copying the app to a directory that is write-accessible, we don't need to muck with owner/group IDs
        if ([self preparePathForRelaunchTool:targetPath error:&error] && [fileManager copyItemAtURL:relaunchURLToCopy toURL:targetURL error:&error]) {
            // We probably don't need to release the quarantine, but we'll do it just in case it's necessary.
            // Perhaps in a sandboxed environment this matters more. Note that this may not be a fatal error.
            NSError *quarantineError = nil;
            if (![fileManager releaseItemFromQuarantineAtRootURL:targetURL error:&quarantineError]) {
                SULog(@"Failed to release quarantine on %@ with error %@", targetPath, quarantineError);
            }
            self.relaunchPath = targetPath;
        } else {
            [self abortUpdateWithError:[NSError errorWithDomain:SUSparkleErrorDomain code:SURelaunchError userInfo:@{
                NSLocalizedDescriptionKey: SULocalizedString(@"An error occurred while extracting the archive. Please try again later.", nil),
                NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Couldn't copy relauncher (%@) to temporary path (%@)! %@", relaunchPathToCopy, targetPath, (error ? [error localizedDescription] : @"")]
            }]];
        }
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:SUUpdaterWillRestartNotification object:self];
    if ([updaterDelegate respondsToSelector:@selector(updaterWillRelaunchApplication:)])
        [updaterDelegate updaterWillRelaunchApplication:self.updater];

    NSString *relaunchToolPath = [[NSBundle bundleWithPath:self.relaunchPath] executablePath];
    if (!relaunchToolPath || ![[NSFileManager defaultManager] fileExistsAtPath:self.relaunchPath]) {
        // Note that we explicitly use the host app's name here, since updating plugin for Mail relaunches Mail, not just the plugin.
        [self abortUpdateWithError:[NSError errorWithDomain:SUSparkleErrorDomain code:SURelaunchError userInfo:@{
            NSLocalizedDescriptionKey: [NSString stringWithFormat:SULocalizedString(@"An error occurred while relaunching %1$@, but the new version will be available next time you run %1$@.", nil), [self.host name]],
            NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Couldn't find the relauncher (expected to find it at %@)", self.relaunchPath]
        }]];
        // We intentionally don't abandon the update here so that the host won't initiate another.
        return;
    }

    NSString *pathToRelaunch = [self.host bundlePath];
    if ([updaterDelegate respondsToSelector:@selector(pathToRelaunchForUpdater:)]) {
        pathToRelaunch = [updaterDelegate pathToRelaunchForUpdater:self.updater];
    }
    
    [NSTask launchedTaskWithLaunchPath:relaunchToolPath arguments:@[[self.host bundlePath],
                                                                    pathToRelaunch,
                                                                    [NSString stringWithFormat:@"%d", [[NSProcessInfo processInfo] processIdentifier]],
                                                                    self.tempDir,
                                                                    relaunch ? @"1" : @"0",
                                                                    showUI ? @"1" : @"0"]];
    [self terminateApp];
}

// Note: this is overridden by the automatic update driver to not terminate in some cases
- (void)terminateApp
{
    [NSApp terminate:self];
}

- (void)cleanUpDownload
{
    if (self.tempDir != nil) // tempDir contains downloadPath, so we implicitly delete both here.
    {
        BOOL success = NO;
        NSError *error = nil;
        success = [[NSFileManager defaultManager] removeItemAtPath:self.tempDir error:&error]; // Clean up the copied relauncher
        if (!success)
            [[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceRecycleOperation source:[self.tempDir stringByDeletingLastPathComponent] destination:@"" files:@[[self.tempDir lastPathComponent]] tag:NULL];
    }
}

- (void)installerForHost:(SUHost *)aHost failedWithError:(NSError *)error
{
    if (aHost != self.host) {
        return;
    }
    NSError *dontThrow = nil;
    [[NSFileManager defaultManager] removeItemAtPath:self.relaunchPath error:&dontThrow]; // Clean up the copied relauncher
    [self abortUpdateWithError:[NSError errorWithDomain:SUSparkleErrorDomain code:SUInstallationError userInfo:@{
        NSLocalizedDescriptionKey: SULocalizedString(@"An error occurred while installing the update. Please try again later.", nil),
        NSLocalizedFailureReasonErrorKey: [error localizedDescription],
        NSUnderlyingErrorKey: error,
    }]];
}

- (void)abortUpdate
{
    [self cleanUpDownload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.updateItem = nil;
    [super abortUpdate];
}

- (void)abortUpdateWithError:(NSError *)error
{
    if ([error code] != SUNoUpdateError) { // Let's not bother logging this.
        NSError *errorToDisplay = error;
        int finiteRecursion=5;
        do {
            SULog(@"Error: %@ %@ (URL %@)", errorToDisplay.localizedDescription, errorToDisplay.localizedFailureReason, [errorToDisplay.userInfo objectForKey:NSURLErrorFailingURLErrorKey]);
            errorToDisplay = [errorToDisplay.userInfo objectForKey:NSUnderlyingErrorKey];
        } while(--finiteRecursion && errorToDisplay);
    }
    if (self.download) {
        [self.download cancel];
    }

    // Notify host app that update has aborted
    id<SUUpdaterDelegate> updaterDelegate = [self.updater delegate];
    if ([updaterDelegate respondsToSelector:@selector(updater:didAbortWithError:)]) {
        [updaterDelegate updater:self.updater didAbortWithError:error];
    }

    [self abortUpdate];
}

@end
