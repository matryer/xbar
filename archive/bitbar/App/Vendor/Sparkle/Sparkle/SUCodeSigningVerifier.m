//
//  SUCodeSigningVerifier.m
//  Sparkle
//
//  Created by Andy Matuschak on 7/5/12.
//
//

#include <Security/CodeSigning.h>
#include <Security/SecCode.h>
#import "SUCodeSigningVerifier.h"
#import "SULog.h"

@implementation SUCodeSigningVerifier

+ (BOOL)codeSignatureMatchesHostAndIsValidAtPath:(NSString *)applicationPath error:(NSError *__autoreleasing *)error
{
    OSStatus result;
    SecRequirementRef requirement = NULL;
    SecStaticCodeRef staticCode = NULL;
    SecCodeRef hostCode = NULL;
    NSBundle *newBundle;
    CFErrorRef cfError = NULL;
    if (error) {
        *error = nil;
    }

    result = SecCodeCopySelf(kSecCSDefaultFlags, &hostCode);
    if (result != noErr) {
        SULog(@"Failed to copy host code %d", result);
        goto finally;
    }

    result = SecCodeCopyDesignatedRequirement(hostCode, kSecCSDefaultFlags, &requirement);
    if (result != noErr) {
        SULog(@"Failed to copy designated requirement. Code Signing OSStatus code: %d", result);
        goto finally;
    }

    newBundle = [NSBundle bundleWithPath:applicationPath];
    if (!newBundle) {
        SULog(@"Failed to load NSBundle for update");
        result = -1;
        goto finally;
    }

    result = SecStaticCodeCreateWithPath((__bridge CFURLRef)[newBundle bundleURL], kSecCSDefaultFlags, &staticCode);
    if (result != noErr) {
        SULog(@"Failed to get static code %d", result);
        goto finally;
    }

    // Note that kSecCSCheckNestedCode may not work with pre-Mavericks code signing.
    // See https://github.com/sparkle-project/Sparkle/issues/376#issuecomment-48824267 and https://developer.apple.com/library/mac/technotes/tn2206
	SecCSFlags flags = (SecCSFlags) (kSecCSDefaultFlags | kSecCSCheckAllArchitectures);
    result = SecStaticCodeCheckValidityWithErrors(staticCode, flags, requirement, &cfError);

    if (cfError) {
        NSError *tmpError = CFBridgingRelease(cfError);
        if (error) *error = tmpError;
    }

    if (result != noErr) {
        if (result == errSecCSUnsigned) {
            SULog(@"The host app is signed, but the new version of the app is not signed using Apple Code Signing. Please ensure that the new app is signed and that archiving did not corrupt the signature.");
        }
        if (result == errSecCSReqFailed) {
            CFStringRef requirementString = nil;
            if (SecRequirementCopyString(requirement, kSecCSDefaultFlags, &requirementString) == noErr) {
                SULog(@"Code signature of the new version doesn't match the old version: %@. Please ensure that old and new app is signed using exactly the same certificate.", requirementString);
                CFRelease(requirementString);
            }

            [self logSigningInfoForCode:hostCode label:@"host info"];
            [self logSigningInfoForCode:staticCode label:@"new info"];
        }
    }

finally:
    if (hostCode) CFRelease(hostCode);
    if (staticCode) CFRelease(staticCode);
    if (requirement) CFRelease(requirement);
    return (result == noErr);
}

+ (BOOL)codeSignatureIsValidAtPath:(NSString *)applicationPath error:(NSError *__autoreleasing *)error
{
    OSStatus result;
    SecStaticCodeRef staticCode = NULL;
    NSBundle *newBundle;
    CFErrorRef cfError = NULL;
    if (error) {
        *error = nil;
    }

    newBundle = [NSBundle bundleWithPath:applicationPath];
    if (!newBundle) {
        SULog(@"Failed to load NSBundle");
        result = -1;
        goto finally;
    }

    result = SecStaticCodeCreateWithPath((__bridge CFURLRef)[newBundle bundleURL], kSecCSDefaultFlags, &staticCode);
    if (result != noErr) {
        SULog(@"Failed to get static code %d", result);
        goto finally;
    }

    // Note that kSecCSCheckNestedCode may not work with pre-Mavericks code signing.
    // See https://github.com/sparkle-project/Sparkle/issues/376#issuecomment-48824267 and https://developer.apple.com/library/mac/technotes/tn2206
	SecCSFlags flags = (SecCSFlags) (kSecCSDefaultFlags | kSecCSCheckAllArchitectures);
    result = SecStaticCodeCheckValidityWithErrors(staticCode, flags, NULL, &cfError);

    if (cfError) {
        NSError *tmpError = CFBridgingRelease(cfError);
        if (error) *error = tmpError;
    }

    if (result != noErr) {
        if (result == errSecCSUnsigned) {
            SULog(@"Error: The app is not signed using Apple Code Signing. %@", applicationPath);
        }
        if (result == errSecCSReqFailed) {
            [self logSigningInfoForCode:staticCode label:@"new info"];
        }
    }

finally:
    if (staticCode) CFRelease(staticCode);
    return (result == noErr);
}

static id valueOrNSNull(id value) {
    return value ? value : [NSNull null];
}

+ (void)logSigningInfoForCode:(SecStaticCodeRef)code label:(NSString*)label {
    CFDictionaryRef signingInfo = nil;
    const SecCSFlags flags = (SecCSFlags) (kSecCSSigningInformation | kSecCSRequirementInformation | kSecCSDynamicInformation | kSecCSContentInformation);
    if (SecCodeCopySigningInformation(code, flags, &signingInfo) == noErr) {
        NSDictionary *signingDict = CFBridgingRelease(signingInfo);
        NSMutableDictionary *relevantInfo = [NSMutableDictionary dictionary];
        for (NSString *key in @[@"format", @"identifier", @"requirements", @"teamid", @"signing-time"]) {
            [relevantInfo setObject:valueOrNSNull([signingDict objectForKey:key]) forKey:key];
        }
        NSDictionary *infoPlist = [signingDict objectForKey:@"info-plist"];
        [relevantInfo setObject:valueOrNSNull([infoPlist objectForKey:@"CFBundleShortVersionString"]) forKey:@"version"];
        [relevantInfo setObject:valueOrNSNull([infoPlist objectForKey:(__bridge NSString *)kCFBundleVersionKey]) forKey:@"build"];
        SULog(@"%@: %@", label, relevantInfo);
    }
}

+ (BOOL)hostApplicationIsCodeSigned
{
    OSStatus result;
    SecCodeRef hostCode = NULL;
    result = SecCodeCopySelf(kSecCSDefaultFlags, &hostCode);
    if (result != 0) return NO;

    SecRequirementRef requirement = NULL;
    result = SecCodeCopyDesignatedRequirement(hostCode, kSecCSDefaultFlags, &requirement);
    if (hostCode) CFRelease(hostCode);
    if (requirement) CFRelease(requirement);
    return (result == 0);
}

+ (BOOL)applicationAtPathIsCodeSigned:(NSString *)applicationPath
{
    OSStatus result;
    SecStaticCodeRef staticCode = NULL;
    NSBundle *newBundle;

    newBundle = [NSBundle bundleWithPath:applicationPath];
    if (!newBundle) {
        SULog(@"Failed to load NSBundle");
    	return NO;
    }

    result = SecStaticCodeCreateWithPath((__bridge CFURLRef)[newBundle bundleURL], kSecCSDefaultFlags, &staticCode);
    if (result == errSecCSUnsigned) {
    	return NO;
    }

    SecRequirementRef requirement = NULL;
    result = SecCodeCopyDesignatedRequirement(staticCode, kSecCSDefaultFlags, &requirement);
    if (staticCode) {
        CFRelease(staticCode);
    }
    if (requirement) {
        CFRelease(requirement);
    }
    if (result == errSecCSUnsigned) {
    	return NO;
    }
    return (result == 0);
}

@end
