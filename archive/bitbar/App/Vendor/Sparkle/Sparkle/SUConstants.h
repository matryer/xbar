//
//  SUConstants.h
//  Sparkle
//
//  Created by Andy Matuschak on 3/16/06.
//  Copyright 2006 Andy Matuschak. All rights reserved.
//


#ifndef SUCONSTANTS_H
#define SUCONSTANTS_H

#import <Foundation/Foundation.h>

// -----------------------------------------------------------------------------
//	Misc:
// -----------------------------------------------------------------------------

extern const NSTimeInterval SUMinimumUpdateCheckInterval;
extern const NSTimeInterval SUDefaultUpdateCheckInterval;

extern NSString *const SUBundleIdentifier;

// -----------------------------------------------------------------------------
//	Notifications:
// -----------------------------------------------------------------------------

extern NSString *const SUTechnicalErrorInformationKey;

// -----------------------------------------------------------------------------
//	PList keys::
// -----------------------------------------------------------------------------

extern NSString *const SUFeedURLKey;
extern NSString *const SUHasLaunchedBeforeKey;
extern NSString *const SUShowReleaseNotesKey;
extern NSString *const SUSkippedVersionKey;
extern NSString *const SUScheduledCheckIntervalKey;
extern NSString *const SULastCheckTimeKey;
extern NSString *const SUExpectsDSASignatureKey;
extern NSString *const SUPublicDSAKeyKey;
extern NSString *const SUPublicDSAKeyFileKey;
extern NSString *const SUAutomaticallyUpdateKey;
extern NSString *const SUAllowsAutomaticUpdatesKey;
extern NSString *const SUEnableAutomaticChecksKey;
extern NSString *const SUEnableSystemProfilingKey;
extern NSString *const SUSendProfileInfoKey;
extern NSString *const SULastProfileSubmitDateKey;
extern NSString *const SUPromptUserOnFirstLaunchKey;
extern NSString *const SUKeepDownloadOnFailedInstallKey;
extern NSString *const SUDefaultsDomainKey;
extern NSString *const SUEnableJavaScriptKey;
extern NSString *const SUFixedHTMLDisplaySizeKey __attribute__((deprecated("This key is obsolete and has no effect.")));
extern NSString *const SUAppendVersionNumberKey __attribute__((deprecated("This key is obsolete. See SPARKLE_APPEND_VERSION_NUMBER.")));
extern NSString *const SUEnableAutomatedDowngradesKey __attribute__((deprecated("This key is obsolete. See SPARKLE_AUTOMATED_DOWNGRADES.")));
extern NSString *const SUNormalizeInstalledApplicationNameKey __attribute__((deprecated("This key is obsolete. SPARKLE_NORMALIZE_INSTALLED_APPLICATION_NAME.")));
extern NSString *const SURelaunchToolNameKey __attribute__((deprecated("This key is obsolete. SPARKLE_RELAUNCH_TOOL_NAME.")));

// -----------------------------------------------------------------------------
//	Appcast keys::
// -----------------------------------------------------------------------------

extern NSString *const SUAppcastAttributeDeltaFrom;
extern NSString *const SUAppcastAttributeDSASignature;
extern NSString *const SUAppcastAttributeShortVersionString;
extern NSString *const SUAppcastAttributeVersion;

extern NSString *const SUAppcastElementCriticalUpdate;
extern NSString *const SUAppcastElementDeltas;
extern NSString *const SUAppcastElementMinimumSystemVersion;
extern NSString *const SUAppcastElementMaximumSystemVersion;
extern NSString *const SUAppcastElementReleaseNotesLink;
extern NSString *const SUAppcastElementTags;

extern NSString *const SURSSAttributeURL;

extern NSString *const SURSSElementDescription;
extern NSString *const SURSSElementEnclosure;
extern NSString *const SURSSElementLink;
extern NSString *const SURSSElementPubDate;
extern NSString *const SURSSElementTitle;

#endif
