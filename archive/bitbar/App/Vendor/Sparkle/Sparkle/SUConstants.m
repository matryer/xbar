//
//  SUConstants.m
//  Sparkle
//
//  Created by Andy Matuschak on 3/16/06.
//  Copyright 2006 Andy Matuschak. All rights reserved.
//

#import "SUUpdater.h"

#import "SUAppcast.h"
#import "SUAppcastItem.h"
#import "SUVersionComparisonProtocol.h"
#import "SUConstants.h"

#ifndef DEBUG
#define DEBUG 0
#endif

// Define some minimum intervals to avoid DoS-like checking attacks
const NSTimeInterval SUMinimumUpdateCheckInterval = DEBUG ? 60 : (60 * 60);
const NSTimeInterval SUDefaultUpdateCheckInterval = DEBUG ? 60 : (60 * 60 * 24);

NSString *const SUBundleIdentifier = @SPARKLE_BUNDLE_IDENTIFIER;

NSString *const SUTechnicalErrorInformationKey = @"SUTechnicalErrorInformation";

NSString *const SUHasLaunchedBeforeKey = @"SUHasLaunchedBefore";
NSString *const SUFeedURLKey = @"SUFeedURL";
NSString *const SUShowReleaseNotesKey = @"SUShowReleaseNotes";
NSString *const SUSkippedVersionKey = @"SUSkippedVersion";
NSString *const SUScheduledCheckIntervalKey = @"SUScheduledCheckInterval";
NSString *const SULastCheckTimeKey = @"SULastCheckTime";
NSString *const SUExpectsDSASignatureKey = @"SUExpectsDSASignature";
NSString *const SUPublicDSAKeyKey = @"SUPublicDSAKey";
NSString *const SUPublicDSAKeyFileKey = @"SUPublicDSAKeyFile";
NSString *const SUAutomaticallyUpdateKey = @"SUAutomaticallyUpdate";
NSString *const SUAllowsAutomaticUpdatesKey = @"SUAllowsAutomaticUpdates";
NSString *const SUEnableSystemProfilingKey = @"SUEnableSystemProfiling";
NSString *const SUEnableAutomaticChecksKey = @"SUEnableAutomaticChecks";
NSString *const SUSendProfileInfoKey = @"SUSendProfileInfo";
NSString *const SULastProfileSubmitDateKey = @"SULastProfileSubmissionDate";
NSString *const SUPromptUserOnFirstLaunchKey = @"SUPromptUserOnFirstLaunch";
NSString *const SUEnableJavaScriptKey = @"SUEnableJavaScript";
NSString *const SUFixedHTMLDisplaySizeKey = @"SUFixedHTMLDisplaySize";
NSString *const SUKeepDownloadOnFailedInstallKey = @"SUKeepDownloadOnFailedInstall";
NSString *const SUDefaultsDomainKey = @"SUDefaultsDomain";
NSString *const SUSparkleErrorDomain = @"SUSparkleErrorDomain";

NSString *const SUAppendVersionNumberKey = @"SUAppendVersionNumber";
NSString *const SUEnableAutomatedDowngradesKey = @"SUEnableAutomatedDowngrades";
NSString *const SUNormalizeInstalledApplicationNameKey = @"SUNormalizeInstalledApplicationName";
NSString *const SURelaunchToolNameKey = @"SURelaunchToolName";

NSString *const SUAppcastAttributeDeltaFrom = @"sparkle:deltaFrom";
NSString *const SUAppcastAttributeDSASignature = @"sparkle:dsaSignature";
NSString *const SUAppcastAttributeShortVersionString = @"sparkle:shortVersionString";
NSString *const SUAppcastAttributeVersion = @"sparkle:version";

NSString *const SUAppcastElementCriticalUpdate = @"sparkle:criticalUpdate";
NSString *const SUAppcastElementDeltas = @"sparkle:deltas";
NSString *const SUAppcastElementMinimumSystemVersion = @"sparkle:minimumSystemVersion";
NSString *const SUAppcastElementMaximumSystemVersion = @"sparkle:maximumSystemVersion";
NSString *const SUAppcastElementReleaseNotesLink = @"sparkle:releaseNotesLink";
NSString *const SUAppcastElementTags = @"sparkle:tags";

NSString *const SURSSAttributeURL = @"url";

NSString *const SURSSElementDescription = @"description";
NSString *const SURSSElementEnclosure = @"enclosure";
NSString *const SURSSElementLink = @"link";
NSString *const SURSSElementPubDate = @"pubDate";
NSString *const SURSSElementTitle = @"title";
