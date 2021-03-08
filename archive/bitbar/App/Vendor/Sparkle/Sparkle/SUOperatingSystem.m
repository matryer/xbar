//
//  SUOperatingSystem.m
//  Sparkle
//
//  Copyright © 2015 Sparkle Project. All rights reserved.
//

#import "SUOperatingSystem.h"

@implementation SUOperatingSystem

+ (NSOperatingSystemVersion)operatingSystemVersion
{
#if __MAC_OS_X_VERSION_MIN_REQUIRED < 101000
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wselector"
    // Xcode 5.1.1: operatingSystemVersion is clearly declared, must warn due to a compiler bug?
    if (![NSProcessInfo instancesRespondToSelector:@selector(operatingSystemVersion)])
#pragma clang diagnostic pop
    {
        NSOperatingSystemVersion version = { 0, 0, 0 };
        NSURL *coreServices = [[NSFileManager defaultManager] URLForDirectory:NSCoreServiceDirectory inDomain:NSSystemDomainMask appropriateForURL:nil create:NO error:nil];
        NSURL *url = [coreServices URLByAppendingPathComponent:@"SystemVersion.plist"];
        assert(url != nil);
        NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfURL:url];
        NSArray *components = [ [dictionary objectForKey: @"ProductVersion"] componentsSeparatedByString:@"."];
        version.majorVersion = components.count > 0 ? [ [components objectAtIndex:0] integerValue] : 0;
        version.minorVersion = components.count > 1 ? [ [components objectAtIndex:1] integerValue] : 0;
        version.patchVersion = components.count > 2 ? [ [components objectAtIndex:2] integerValue] : 0;
        return version;
    }
#endif
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wpartial-availability"
    return [[NSProcessInfo processInfo] operatingSystemVersion];
#pragma clang diagnostic pop
}

+ (BOOL)isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion)version
{
    const NSOperatingSystemVersion systemVersion = self.operatingSystemVersion;
    if (systemVersion.majorVersion == version.majorVersion) {
        if (systemVersion.minorVersion == version.minorVersion) {
            return systemVersion.patchVersion >= version.patchVersion;
        }
        return systemVersion.minorVersion >= version.minorVersion;
    }
    return systemVersion.majorVersion >= version.majorVersion;
}

+ (NSString *)systemVersionString
{
    NSOperatingSystemVersion version = self.operatingSystemVersion;
    return [NSString stringWithFormat:@"%ld.%ld.%ld", (long)version.majorVersion, (long)version.minorVersion, (long)version.patchVersion];
}

@end
