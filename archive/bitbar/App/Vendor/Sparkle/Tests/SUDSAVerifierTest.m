//
//  SUDSAVerifierTest.m
//  Sparkle
//
//  Created by Kornel on 25/07/2014.
//  Copyright (c) 2014 Sparkle Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "SUDSAVerifier.h"

@interface SUDSAVerifierTest : XCTestCase
@property NSString *testFile, *pubKeyFile;
@end

@implementation SUDSAVerifierTest
@synthesize testFile, pubKeyFile;

- (void)setUp
{
    [super setUp];

    self.testFile = [[NSBundle bundleForClass:[self class]] pathForResource:@"signed-test-file" ofType:@"txt"];
    self.pubKeyFile = [[NSBundle bundleForClass:[self class]] pathForResource:@"test-pubkey" ofType:@"pem"];
}

- (void)testVerifyFileAtPath
{
    NSData *pubKey = [NSData dataWithContentsOfFile:self.pubKeyFile];
    XCTAssertNotNil(pubKey, @"Public key must be readable");

    NSString *validSig = @"MCwCFCIHCIYYkfZavNzTitTW5tlRp/k5AhQ40poFytqcVhIYdCxQznaXeJPJDQ==";

    XCTAssertTrue([self checkFile:self.testFile
                       withPubKey:pubKey
                        signature:validSig],
                  @"Expected valid signature");

    XCTAssertFalse([self checkFile:self.testFile
                        withPubKey:[NSData dataWithBytes:"lol" length:3]
                         signature:validSig],
                   @"Invalid pubkey");

    XCTAssertFalse([self checkFile:self.pubKeyFile
                        withPubKey:pubKey
                         signature:validSig],
                   @"Wrong file checked");

    XCTAssertFalse([self checkFile:self.testFile
                        withPubKey:pubKey
                         signature:@"MCwCFCIHCiYYkfZavNzTitTW5tlRp/k5AhQ40poFytqcVhIYdCxQznaXeJPJDQ=="],
                   @"Expected invalid signature");

    XCTAssertTrue([self checkFile:self.testFile
                       withPubKey:pubKey
                        signature:@"MC0CFAsKO7cq2q7L5/FWe6ybVIQkwAwSAhUA2Q8GKsE309eugi/v3Kh1W3w3N8c="],
                  @"Expected valid signature");

    XCTAssertFalse([self checkFile:self.testFile
                        withPubKey:pubKey
                         signature:@"MC0CFAsKO7cq2q7L5/FWe6ybVIQkwAwSAhUA2Q8GKsE309eugi/v3Kh1W3w3N8"],
                   @"Expected invalid signature");
}

- (BOOL)checkFile:(NSString *)aFile withPubKey:(NSData *)pubKey signature:(NSString *)sigString
{
    SUDSAVerifier *v = [[SUDSAVerifier alloc] initWithPublicKeyData:pubKey];

    NSData *sig = [[NSData alloc] initWithBase64EncodedString:sigString options:(NSDataBase64DecodingOptions)0];

    return [v verifyFileAtPath:aFile signature:sig];
}

- (void)testValidatePath
{
    NSString *pubkey = [NSString stringWithContentsOfFile:self.pubKeyFile encoding:NSASCIIStringEncoding error:nil];

    XCTAssertTrue([SUDSAVerifier validatePath:self.testFile
                      withEncodedDSASignature:@"MC0CFFMF3ha5kjvrJ9JTpTR8BenPN9QUAhUAzY06JRdtP17MJewxhK0twhvbKIE="
                             withPublicDSAKey:pubkey],
                  @"Expected valid signature");
}

@end
