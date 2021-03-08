//
//  SUDSAVerifier.m
//  Sparkle
//
//  Created by Andy Matuschak on 3/16/06.
//  Copyright 2006 Andy Matuschak. All rights reserved.
//
//  Includes code by Zach Waldowski on 10/18/13.
//  Copyright 2014 Big Nerd Ranch. Licensed under MIT.
//
//  Includes code from Plop by Mark Hamlin.
//  Copyright 2011 Mark Hamlin. Licensed under BSD.
//

#import "SUDSAVerifier.h"
#import "SULog.h"
#include <CommonCrypto/CommonDigest.h>

@implementation SUDSAVerifier {
    SecKeyRef _secKey;
}

+ (BOOL)validatePath:(NSString *)path withEncodedDSASignature:(NSString *)encodedSignature withPublicDSAKey:(NSString *)pkeyString
{
    if (!encodedSignature) {
        SULog(@"There is no DSA signature to check");
        return NO;
    }

    if (!path) {
        return NO;
    }

    SUDSAVerifier *verifier = [[self alloc] initWithPublicKeyData:[pkeyString dataUsingEncoding:NSUTF8StringEncoding]];

    if (!verifier) {
        return NO;
    }

    NSString *strippedSignature = [encodedSignature stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    NSData *signature = [[NSData alloc] initWithBase64Encoding:strippedSignature];
    return [verifier verifyFileAtPath:path signature:signature];
}

- (instancetype)initWithPublicKeyData:(NSData *)data
{
    self = [super init];

    if (!self || !data.length) {
        SULog(@"Could not read public DSA key");
        return nil;
    }

    SecExternalFormat format = kSecFormatOpenSSL;
    SecExternalItemType itemType = kSecItemTypePublicKey;
    CFArrayRef items = NULL;

    OSStatus status = SecItemImport((__bridge CFDataRef)data, NULL, &format, &itemType, (SecItemImportExportFlags)0, NULL, NULL, &items);
    if (status != errSecSuccess || !items) {
        if (items) {
            CFRelease(items);
        }
        SULog(@"Public DSA key could not be imported: %d", status);
        return nil;
    }

    if (format == kSecFormatOpenSSL && itemType == kSecItemTypePublicKey && CFArrayGetCount(items) == 1) {
        // Seems silly, but we can't quiet the warning about dropping CFTypeRef's const qualifier through
        // any manner of casting I've tried, including interim explicit cast to void*. The -Wcast-qual
        // warning is on by default with -Weverything and apparently became more noisy as of Xcode 7.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wcast-qual"
        _secKey = (SecKeyRef)CFRetain(CFArrayGetValueAtIndex(items, 0));
#pragma clang diagnostic pop
    }

    CFRelease(items);

    return self;
}

- (void)dealloc
{
    if (_secKey) {
        CFRelease(_secKey);
    }
}

- (BOOL)verifyFileAtPath:(NSString *)path signature:(NSData *)signature
{
    if (!path.length) {
        return NO;
    }
    NSInputStream *dataInputStream = [NSInputStream inputStreamWithFileAtPath:path];
    return [self verifyStream:dataInputStream signature:signature];
}

- (BOOL)verifyStream:(NSInputStream *)stream signature:(NSData *)signature
{
    if (!stream || !signature) {
        return NO;
    }

    __block SecGroupTransformRef group = SecTransformCreateGroupTransform();
    __block SecTransformRef dataReadTransform = NULL;
    __block SecTransformRef dataDigestTransform = NULL;
    __block SecTransformRef dataVerifyTransform = NULL;
    __block CFErrorRef error = NULL;

    BOOL (^cleanup)(void) = ^{
		if (group) CFRelease(group);
		if (dataReadTransform) CFRelease(dataReadTransform);
		if (dataDigestTransform) CFRelease(dataDigestTransform);
		if (dataVerifyTransform) CFRelease(dataVerifyTransform);
		if (error) CFRelease(error);
		return NO;
    };

    dataReadTransform = SecTransformCreateReadTransformWithReadStream((__bridge CFReadStreamRef)stream);
    if (!dataReadTransform) {
        SULog(@"File containing update archive could not be read (failed to create SecTransform for input stream)");
        return cleanup();
    }

    dataDigestTransform = SecDigestTransformCreate(kSecDigestSHA1, CC_SHA1_DIGEST_LENGTH, NULL);
    if (!dataDigestTransform) {
        return cleanup();
    }

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdirect-ivar-access"
    dataVerifyTransform = SecVerifyTransformCreate(_secKey, (__bridge CFDataRef)signature, &error);
#pragma clang diagnostic pop
    if (!dataVerifyTransform || error) {
        SULog(@"Could not understand format of the signature: %@; Signature data: %@", error, signature);
        return cleanup();
    }

    SecTransformConnectTransforms(dataReadTransform, kSecTransformOutputAttributeName, dataDigestTransform, kSecTransformInputAttributeName, group, &error);
    if (error) {
        SULog(@"%@", error);
        return cleanup();
    }

    SecTransformConnectTransforms(dataDigestTransform, kSecTransformOutputAttributeName, dataVerifyTransform, kSecTransformInputAttributeName, group, &error);
    if (error) {
        SULog(@"%@", error);
        return cleanup();
    }

    NSNumber *result = CFBridgingRelease(SecTransformExecute(group, &error));
    if (error) {
        SULog(@"DSA signature verification failed: %@", error);
        return cleanup();
    }

    if (!result.boolValue) {
        SULog(@"DSA signature does not match. Data of the update file being checked is different than data that has been signed, or the public key and the private key are not from the same set.");
    }

    cleanup();
    return result.boolValue;
}

@end
