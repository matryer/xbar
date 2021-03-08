//
//  SUCodeSigningVerifier.h
//  Sparkle
//
//  Created by Andy Matuschak on 7/5/12.
//
//

#ifndef SUCODESIGNINGVERIFIER_H
#define SUCODESIGNINGVERIFIER_H

#import <Foundation/Foundation.h>

@interface SUCodeSigningVerifier : NSObject
+ (BOOL)codeSignatureMatchesHostAndIsValidAtPath:(NSString *)applicationPath error:(NSError **)error;
+ (BOOL)codeSignatureIsValidAtPath:(NSString *)applicationPath error:(NSError **)error;
+ (BOOL)hostApplicationIsCodeSigned;
+ (BOOL)applicationAtPathIsCodeSigned:(NSString *)applicationPath;
@end

#endif
