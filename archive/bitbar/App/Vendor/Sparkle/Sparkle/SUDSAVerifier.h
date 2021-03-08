//
//  SUDSAVerifier.h
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

#ifndef SUDSAVERIFIER_H
#define SUDSAVERIFIER_H

#import <Foundation/Foundation.h>

#if __MAC_OS_X_VERSION_MAX_ALLOWED < 1090
@interface NSData (SUDSAVerifier)
- (id)initWithBase64Encoding:(NSString *)base64String;
@end
#endif

@interface SUDSAVerifier : NSObject

+ (BOOL)validatePath:(NSString *)path withEncodedDSASignature:(NSString *)encodedSignature withPublicDSAKey:(NSString *)pkeyString;

- (instancetype)initWithPublicKeyData:(NSData *)data;

- (BOOL)verifyFileAtPath:(NSString *)path signature:(NSData *)signature;
- (BOOL)verifyStream:(NSInputStream *)stream signature:(NSData *)signature;

@end

#endif
