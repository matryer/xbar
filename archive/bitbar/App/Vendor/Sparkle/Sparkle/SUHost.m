//
//  SUHost.m
//  Sparkle
//
//  Copyright 2008 Andy Matuschak. All rights reserved.
//

#import "SUHost.h"

#import "SUConstants.h"
#import "SUSystemProfiler.h"
#include <sys/mount.h> // For statfs for isRunningOnReadOnlyVolume
#import "SULog.h"

#if __MAC_OS_X_VERSION_MAX_ALLOWED < 101000
@interface NSProcessInfo ()
- (NSOperatingSystemVersion)operatingSystemVersion;
@end
#endif

@interface SUHost ()

@property (strong, readwrite) NSBundle *bundle;
@property (copy) NSString *defaultsDomain;
@property (assign) BOOL usesStandardUserDefaults;

@end

@implementation SUHost

@synthesize bundle;
@synthesize defaultsDomain;
@synthesize usesStandardUserDefaults;

- (instancetype)initWithBundle:(NSBundle *)aBundle
{
	if ((self = [super init]))
	{
        SUParameterAssert(aBundle);
        self.bundle = aBundle;
        if (![self.bundle bundleIdentifier]) {
            SULog(@"Error: the bundle being updated at %@ has no %@! This will cause preference read/write to not work properly.", self.bundle, kCFBundleIdentifierKey);
        }

        self.defaultsDomain = [self.bundle objectForInfoDictionaryKey:SUDefaultsDomainKey];
        if (!self.defaultsDomain) {
            self.defaultsDomain = [self.bundle bundleIdentifier];
        }

        // If we're using the main bundle's defaults we'll use the standard user defaults mechanism, otherwise we have to get CF-y.
        NSString *mainBundleIdentifier = NSBundle.mainBundle.bundleIdentifier;
        usesStandardUserDefaults = !self.defaultsDomain || [self.defaultsDomain isEqualToString:mainBundleIdentifier];
    }
    return self;
}


- (NSString *)description { return [NSString stringWithFormat:@"%@ <%@, %@>", [self class], [self bundlePath], [self installationPath]]; }

- (NSString *)bundlePath
{
    return [self.bundle bundlePath];
}

- (BOOL)allowsAutomaticUpdates
{
    // Does the developer want us to disable automatic updates?
    NSNumber *developerAllowsAutomaticUpdates = [self objectForInfoDictionaryKey:SUAllowsAutomaticUpdatesKey];
    if (developerAllowsAutomaticUpdates != nil && !developerAllowsAutomaticUpdates.boolValue) {
        return NO;
    }
    
    // Can we automatically update in the background without bugging the user (e.g, with a administrator password prompt)?
    // Note it's very well possible to have the bundle be writable but not be able to write into the parent directory
    // And if the bundle isn't writable, but we can write into the parent directory, we will still need to authorize to replace it
    NSString *bundlePath = [self bundlePath];
    return [[NSFileManager defaultManager] isWritableFileAtPath:bundlePath.stringByDeletingLastPathComponent] && [[NSFileManager defaultManager] isWritableFileAtPath:bundlePath];
}

- (NSString *)installationPath
{
    if (SPARKLE_NORMALIZE_INSTALLED_APPLICATION_NAME) {
        // We'll install to "#{CFBundleName}.app", but only if that path doesn't already exist. If we're "Foo 4.2.app," and there's a "Foo.app" in this directory, we don't want to overwrite it! But if there's no "Foo.app," we'll take that name.
        NSString *normalizedAppPath = [[[self.bundle bundlePath] stringByDeletingLastPathComponent] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", [self.bundle objectForInfoDictionaryKey:(__bridge NSString *)kCFBundleNameKey], [[self.bundle bundlePath] pathExtension]]];

        if (![[NSFileManager defaultManager] fileExistsAtPath:normalizedAppPath]) {
            return normalizedAppPath;
        }
    }
    return [self.bundle bundlePath];
}

- (NSString *__nonnull)name
{
    NSString *name;

    // Allow host bundle to provide a custom name
    name = [self objectForInfoDictionaryKey:@"SUBundleName"];
    if (name && name.length > 0) return name;

    name = [self.bundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];
	if (name && name.length > 0) return name;

    name = [self objectForInfoDictionaryKey:(__bridge NSString *)kCFBundleNameKey];
	if (name && name.length > 0) return name;

    return [[[NSFileManager defaultManager] displayNameAtPath:[self.bundle bundlePath]] stringByDeletingPathExtension];
}

- (NSString *__nonnull)version
{
    NSString *version = [self.bundle objectForInfoDictionaryKey:(__bridge NSString *)kCFBundleVersionKey];
    if (!version || [version isEqualToString:@""])
        [NSException raise:@"SUNoVersionException" format:@"This host (%@) has no %@! This attribute is required.", [self bundlePath], (__bridge NSString *)kCFBundleVersionKey];
    return version;
}

- (NSString *__nonnull)displayVersion
{
    NSString *shortVersionString = [self.bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    if (shortVersionString)
        return shortVersionString;
    else
        return [self version]; // Fall back on the normal version string.
}

- (NSImage *__nonnull)icon
{
    // Cache the application icon.
    NSString *iconPath = [self.bundle pathForResource:[self.bundle objectForInfoDictionaryKey:@"CFBundleIconFile"] ofType:@"icns"];
    // According to the macOS docs, "CFBundleIconFile - This key identifies the file containing
    // the icon for the bundle. The filename you specify does not need to include the .icns
    // extension, although it may."
    //
    // However, if it *does* include the '.icns' the above method fails (tested on macOS 10.3.9) so we'll also try:
    if (!iconPath) {
        iconPath = [self.bundle pathForResource:[self.bundle objectForInfoDictionaryKey:@"CFBundleIconFile"] ofType:nil];
    }
    NSImage *icon = [[NSImage alloc] initWithContentsOfFile:iconPath];
    // Use a default icon if none is defined.
    if (!icon) {
        BOOL isMainBundle = (self.bundle == [NSBundle mainBundle]);

        NSString *fileType = isMainBundle ? (__bridge NSString *)kUTTypeApplication : (__bridge NSString *)kUTTypeBundle;
        icon = [[NSWorkspace sharedWorkspace] iconForFileType:fileType];
    }
    return icon;
}

- (BOOL)isRunningOnReadOnlyVolume
{
    struct statfs statfs_info;
    statfs([[self.bundle bundlePath] fileSystemRepresentation], &statfs_info);
    return (statfs_info.f_flags & MNT_RDONLY) != 0;
}

- (BOOL)isBackgroundApplication
{
    return ([[NSApplication sharedApplication] activationPolicy] == NSApplicationActivationPolicyAccessory);
}

- (NSString *__nullable)publicDSAKey
{
    // Maybe the key is just a string in the Info.plist.
    NSString *key = [self.bundle objectForInfoDictionaryKey:SUPublicDSAKeyKey];
	if (key) {
        return key;
    }

    // More likely, we've got a reference to a Resources file by filename:
    NSString *keyFilename = [self objectForInfoDictionaryKey:SUPublicDSAKeyFileKey];
	if (!keyFilename) {
        return nil;
    }

    NSString *keyPath = [self.bundle pathForResource:keyFilename ofType:nil];
    if (!keyPath) {
        return nil;
    }
    return [NSString stringWithContentsOfFile:keyPath encoding:NSASCIIStringEncoding error:nil];
}

- (NSArray *)systemProfile
{
    return [[SUSystemProfiler sharedSystemProfiler] systemProfileArrayForHost:self];
}

- (id)objectForInfoDictionaryKey:(NSString *)key
{
    return [self.bundle objectForInfoDictionaryKey:key];
}

- (BOOL)boolForInfoDictionaryKey:(NSString *)key
{
    return [[self objectForInfoDictionaryKey:key] boolValue];
}

- (id)objectForUserDefaultsKey:(NSString *)defaultName
{
    if (!defaultName || !self.defaultsDomain) {
        return nil;
    }

    // Under Tiger, CFPreferencesCopyAppValue doesn't get values from NSRegistrationDomain, so anything
    // passed into -[NSUserDefaults registerDefaults:] is ignored.  The following line falls
    // back to using NSUserDefaults, but only if the host bundle is the main bundle.
    if (self.usesStandardUserDefaults) {
        return [[NSUserDefaults standardUserDefaults] objectForKey:defaultName];
    }

    CFPropertyListRef obj = CFPreferencesCopyAppValue((__bridge CFStringRef)defaultName, (__bridge CFStringRef)self.defaultsDomain);
    return CFBridgingRelease(obj);
}

- (void)setObject:(id)value forUserDefaultsKey:(NSString *)defaultName
{
	if (self.usesStandardUserDefaults)
	{
        [[NSUserDefaults standardUserDefaults] setObject:value forKey:defaultName];
	}
	else
	{
        CFPreferencesSetValue((__bridge CFStringRef)defaultName, (__bridge CFPropertyListRef)(value), (__bridge CFStringRef)self.defaultsDomain, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
        CFPreferencesSynchronize((__bridge CFStringRef)self.defaultsDomain, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    }
}

- (BOOL)boolForUserDefaultsKey:(NSString *)defaultName
{
    if (self.usesStandardUserDefaults) {
        return [[NSUserDefaults standardUserDefaults] boolForKey:defaultName];
    }

    BOOL value;
    CFPropertyListRef plr = CFPreferencesCopyAppValue((__bridge CFStringRef)defaultName, (__bridge CFStringRef)self.defaultsDomain);
    if (plr == NULL) {
        value = NO;
	}
	else
	{
        value = (BOOL)CFBooleanGetValue((CFBooleanRef)plr);
        CFRelease(plr);
    }
    return value;
}

- (void)setBool:(BOOL)value forUserDefaultsKey:(NSString *)defaultName
{
	if (self.usesStandardUserDefaults)
	{
        [[NSUserDefaults standardUserDefaults] setBool:value forKey:defaultName];
	}
	else
	{
        CFPreferencesSetValue((__bridge CFStringRef)defaultName, (__bridge CFBooleanRef) @(value), (__bridge CFStringRef)self.defaultsDomain, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
        CFPreferencesSynchronize((__bridge CFStringRef)self.defaultsDomain, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    }
}

- (id)objectForKey:(NSString *)key {
    return [self objectForUserDefaultsKey:key] ? [self objectForUserDefaultsKey:key] : [self objectForInfoDictionaryKey:key];
}

- (BOOL)boolForKey:(NSString *)key {
    return [self objectForUserDefaultsKey:key] ? [self boolForUserDefaultsKey:key] : [self boolForInfoDictionaryKey:key];
}

@end
