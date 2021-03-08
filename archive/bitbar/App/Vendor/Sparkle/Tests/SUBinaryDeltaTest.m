//
//  SUBinaryDeltaTest.m
//  Sparkle
//
//  Created by Jake Petroules on 2014-08-22.
//  Copyright (c) 2014 Sparkle Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "SUBinaryDeltaCommon.h"
#import "SUBinaryDeltaCreate.h"
#import "SUBinaryDeltaApply.h"
#import <sys/stat.h>
#include <sys/xattr.h>

@interface SUBinaryDeltaTest : XCTestCase

@end

typedef void (^SUDeltaHandler)(NSFileManager *fileManager, NSString *sourceDirectory, NSString *destinationDirectory);

@implementation SUBinaryDeltaTest

- (void)testTemporaryDirectory
{
    NSString *tmp1 = temporaryDirectory(@"Sparkle");
    NSString *tmp2 = temporaryDirectory(@"Sparkle");
    NSLog(@"Temporary directories: %@, %@", tmp1, tmp2);
    XCTAssertNotEqualObjects(tmp1, tmp2);
    XCTAssert(YES, @"Pass");
}

- (void)testTemporaryFile
{
    NSString *tmp1 = temporaryFilename(@"Sparkle");
    NSString *tmp2 = temporaryFilename(@"Sparkle");
    NSLog(@"Temporary files: %@, %@", tmp1, tmp2);
    XCTAssertNotEqualObjects(tmp1, tmp2);
    XCTAssert(YES, @"Pass");
}

- (BOOL)createAndApplyPatchUsingVersion:(SUBinaryDeltaMajorVersion)majorVersion beforeDiffHandler:(SUDeltaHandler)beforeDiffHandler afterDiffHandler:(SUDeltaHandler)afterDiffHandler
{
    NSString *sourceDirectory = temporaryDirectory(@"Sparkle_temp1");
    NSString *destinationDirectory = temporaryDirectory(@"Sparkle_temp2");
    
    NSString *diffFile = temporaryFilename(@"Sparkle_diff");
    NSString *patchDirectory = temporaryDirectory(@"Sparkle_patch");
    
    XCTAssertNotNil(sourceDirectory);
    XCTAssertNotNil(destinationDirectory);
    XCTAssertNotNil(diffFile);
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    if (beforeDiffHandler != nil) {
        beforeDiffHandler(fileManager, sourceDirectory, destinationDirectory);
    }
    
    NSError *createDiffError = nil;
    BOOL createdDiff = createBinaryDelta(sourceDirectory, destinationDirectory, diffFile, majorVersion, NO, &createDiffError);
    if (!createdDiff) {
        NSLog(@"Creating binary diff failed with error: %@", createDiffError);
    } else if (afterDiffHandler != nil) {
        afterDiffHandler(fileManager, sourceDirectory, destinationDirectory);
    }
    
    NSError *applyDiffError = nil;
    BOOL appliedDiff = NO;
    if (createdDiff) {
        if (applyBinaryDelta(sourceDirectory, patchDirectory, diffFile, NO, &applyDiffError)) {
            appliedDiff = YES;
        } else {
            NSLog(@"Applying binary diff failed with error: %@", applyDiffError);
        }
    }
    
    XCTAssertTrue([fileManager removeItemAtPath:sourceDirectory error:nil]);
    XCTAssertTrue([fileManager removeItemAtPath:destinationDirectory error:nil]);
    XCTAssertTrue([fileManager removeItemAtPath:patchDirectory error:nil]);
    XCTAssertTrue([fileManager removeItemAtPath:diffFile error:nil]);
    
    return appliedDiff;
}

- (BOOL)createAndApplyPatchWithBeforeDiffHandler:(SUDeltaHandler)beforeDiffHandler afterDiffHandler:(SUDeltaHandler)afterDiffHandler
{
    return [self createAndApplyPatchUsingVersion:LATEST_DELTA_DIFF_MAJOR_VERSION beforeDiffHandler:beforeDiffHandler afterDiffHandler:afterDiffHandler];
}

- (void)createAndApplyPatchWithHandler:(SUDeltaHandler)handler
{
    BOOL success = [self createAndApplyPatchWithBeforeDiffHandler:handler afterDiffHandler:nil];
    XCTAssertTrue(success);
}

- (BOOL)testDirectoryHashEqualityWithSource:(NSString *)source destination:(NSString *)destination
{
    XCTAssertNotNil(source);
    XCTAssertNotNil(destination);
    
    NSString *beforeHash = hashOfTree(source);
    NSString *afterHash = hashOfTree(destination);
    
    XCTAssertNotNil(beforeHash);
    XCTAssertNotNil(afterHash);
    
    return [beforeHash isEqualToString:afterHash];
}

- (void)testNoFilesDiff
{
    [self createAndApplyPatchWithHandler:^(NSFileManager *__unused fileManager, NSString *sourceDirectory, NSString *destinationDirectory) {
        XCTAssertTrue([self testDirectoryHashEqualityWithSource:sourceDirectory destination:destinationDirectory]);
    }];
}

- (void)testEmptyDataDiff
{
    [self createAndApplyPatchWithHandler:^(NSFileManager *__unused fileManager, NSString *sourceDirectory, NSString *destinationDirectory) {
        NSData *emptyData = [NSData data];
        NSString *sourceFile = [sourceDirectory stringByAppendingPathComponent:@"A"];
        NSString *destinationFile = [destinationDirectory stringByAppendingPathComponent:@"A"];
        
        XCTAssertTrue([emptyData writeToFile:sourceFile atomically:YES]);
        XCTAssertTrue([emptyData writeToFile:destinationFile atomically:YES]);
        
        XCTAssertTrue([self testDirectoryHashEqualityWithSource:sourceDirectory destination:destinationDirectory]);
    }];
}

- (void)testDifferentlyNamedEmptyDataDiff
{
    [self createAndApplyPatchWithHandler:^(NSFileManager *__unused fileManager, NSString *sourceDirectory, NSString *destinationDirectory) {
        NSData *emptyData = [NSData data];
        NSString *sourceFile = [sourceDirectory stringByAppendingPathComponent:@"A"];
        NSString *destinationFile = [destinationDirectory stringByAppendingPathComponent:@"B"];
        
        XCTAssertTrue([emptyData writeToFile:sourceFile atomically:YES]);
        XCTAssertTrue([emptyData writeToFile:destinationFile atomically:YES]);
        
        XCTAssertFalse([self testDirectoryHashEqualityWithSource:sourceDirectory destination:destinationDirectory]);
    }];
}

- (void)testEmptyDirectoryDiff
{
    [self createAndApplyPatchWithHandler:^(NSFileManager *fileManager, NSString *sourceDirectory, NSString *destinationDirectory) {
        NSString *sourceFile = [sourceDirectory stringByAppendingPathComponent:@"A"];
        NSString *destinationFile = [destinationDirectory stringByAppendingPathComponent:@"A"];
        
        NSError *error = nil;
        if (![fileManager createDirectoryAtPath:sourceFile withIntermediateDirectories:NO attributes:nil error:&error]) {
            NSLog(@"Failed creating directory with error: %@", error);
            XCTFail("Failed to create directory");
        }
        
        if (![fileManager createDirectoryAtPath:destinationFile withIntermediateDirectories:NO attributes:nil error:&error]) {
            NSLog(@"Failed creating directory with error: %@", error);
            XCTFail("Failed to create directory");
        }
        
        XCTAssertTrue([self testDirectoryHashEqualityWithSource:sourceDirectory destination:destinationDirectory]);
    }];
}

- (void)testDifferentlyNamedEmptyDirectoryDiff
{
    [self createAndApplyPatchWithHandler:^(NSFileManager *fileManager, NSString *sourceDirectory, NSString *destinationDirectory) {
        NSString *sourceFile = [sourceDirectory stringByAppendingPathComponent:@"A"];
        NSString *destinationFile = [destinationDirectory stringByAppendingPathComponent:@"B"];
        
        NSError *error = nil;
        if (![fileManager createDirectoryAtPath:sourceFile withIntermediateDirectories:NO attributes:nil error:&error]) {
            NSLog(@"Failed creating directory with error: %@", error);
            XCTFail("Failed to create directory");
        }
        
        if (![fileManager createDirectoryAtPath:destinationFile withIntermediateDirectories:NO attributes:nil error:&error]) {
            NSLog(@"Failed creating directory with error: %@", error);
            XCTFail("Failed to create directory");
        }
        
        // This would fail for version 1.0
        XCTAssertFalse([self testDirectoryHashEqualityWithSource:sourceDirectory destination:destinationDirectory]);
    }];
}

- (void)testSameNonexistantSymlinkDiff
{
    [self createAndApplyPatchWithHandler:^(NSFileManager *fileManager, NSString *sourceDirectory, NSString *destinationDirectory) {
        NSString *sourceFile = [sourceDirectory stringByAppendingPathComponent:@"A"];
        NSString *destinationFile = [destinationDirectory stringByAppendingPathComponent:@"A"];
        
        NSError *error = nil;
        if (![fileManager createSymbolicLinkAtPath:sourceFile withDestinationPath:@"B" error:&error]) {
            NSLog(@"Failed creating empty symlink with error: %@", error);
            XCTFail("Failed to create empty symlink");
        }
        
        if (![fileManager createSymbolicLinkAtPath:destinationFile withDestinationPath:@"B" error:&error]) {
            NSLog(@"Failed creating empty symlink with error: %@", error);
            XCTFail("Failed to create empty symlink");
        }
        
        XCTAssertTrue([self testDirectoryHashEqualityWithSource:sourceDirectory destination:destinationDirectory]);
    }];
}

- (void)testDifferentNonexistantSymlinkDiff
{
    [self createAndApplyPatchWithHandler:^(NSFileManager *fileManager, NSString *sourceDirectory, NSString *destinationDirectory) {
        NSString *sourceFile = [sourceDirectory stringByAppendingPathComponent:@"A"];
        NSString *destinationFile = [destinationDirectory stringByAppendingPathComponent:@"A"];
        
        NSError *error = nil;
        if (![fileManager createSymbolicLinkAtPath:sourceFile withDestinationPath:@"B" error:&error]) {
            NSLog(@"Failed creating empty symlink with error: %@", error);
            XCTFail("Failed to create empty symlink");
        }
        
        if (![fileManager createSymbolicLinkAtPath:destinationFile withDestinationPath:@"C" error:&error]) {
            NSLog(@"Failed creating empty symlink with error: %@", error);
            XCTFail("Failed to create empty symlink");
        }
        
        XCTAssertFalse([self testDirectoryHashEqualityWithSource:sourceDirectory destination:destinationDirectory]);
    }];
}

- (void)testNonexistantSymlinkPermissionDiff
{
    [self createAndApplyPatchWithHandler:^(NSFileManager *fileManager, NSString *sourceDirectory, NSString *destinationDirectory) {
        NSString *sourceFile = [sourceDirectory stringByAppendingPathComponent:@"A"];
        NSString *destinationFile = [destinationDirectory stringByAppendingPathComponent:@"A"];
        
        NSError *error = nil;
        if (![fileManager createSymbolicLinkAtPath:sourceFile withDestinationPath:@"B" error:&error]) {
            NSLog(@"Failed creating empty symlink to source with error: %@", error);
            XCTFail("Failed to create empty symlink");
        }
        
        if (![fileManager createSymbolicLinkAtPath:destinationFile withDestinationPath:@"B" error:&error]) {
            NSLog(@"Failed creating empty symlink to destination with error: %@", error);
            XCTFail("Failed to create empty symlink");
        }
        
        if (lchmod([sourceFile fileSystemRepresentation], 0777) != 0) {
            NSLog(@"Change Permission Error..");
            XCTFail(@"Failed setting file permissions");
        }
        
        XCTAssertFalse([self testDirectoryHashEqualityWithSource:sourceDirectory destination:destinationDirectory]);
    }];
}

- (void)testSmallDataDiff
{
    [self createAndApplyPatchWithHandler:^(NSFileManager *__unused fileManager, NSString *sourceDirectory, NSString *destinationDirectory) {
        NSString *sourceFile = [sourceDirectory stringByAppendingPathComponent:@"A"];
        NSString *destinationFile = [destinationDirectory stringByAppendingPathComponent:@"A"];
        
        XCTAssertTrue([[NSData data] writeToFile:sourceFile atomically:YES]);
        XCTAssertTrue([[NSData dataWithBytes:"loltest" length:7] writeToFile:destinationFile atomically:YES]);
        
        XCTAssertFalse([self testDirectoryHashEqualityWithSource:sourceDirectory destination:destinationDirectory]);
    }];
}

- (void)testInvalidSource
{
    BOOL success = [self createAndApplyPatchWithBeforeDiffHandler:^(NSFileManager *__unused fileManager, NSString *sourceDirectory, NSString *destinationDirectory) {
        NSString *sourceFile = [sourceDirectory stringByAppendingPathComponent:@"A"];
        NSString *destinationFile = [destinationDirectory stringByAppendingPathComponent:@"A"];
        
        XCTAssertTrue([[NSData data] writeToFile:sourceFile atomically:YES]);
        XCTAssertTrue([[NSData dataWithBytes:"loltest" length:7] writeToFile:destinationFile atomically:YES]);
        
        XCTAssertFalse([self testDirectoryHashEqualityWithSource:sourceDirectory destination:destinationDirectory]);
    } afterDiffHandler:^(NSFileManager *__unused fileManager, NSString *sourceDirectory, NSString *__unused destinationDirectory) {
        NSString *sourceFile = [sourceDirectory stringByAppendingPathComponent:@"A"];
        
        XCTAssertTrue([[NSData dataWithBytes:"testt" length:5] writeToFile:sourceFile atomically:YES]);
    }];
    XCTAssertFalse(success);
}

- (NSData *)bigData1
{
    const size_t bufferSize = 4096*10;
    uint8_t *buffer = calloc(1, bufferSize);
    XCTAssertTrue(buffer != NULL);
    
    return [NSData dataWithBytesNoCopy:buffer length:bufferSize];
}

- (NSData *)bigData2
{
    const size_t bufferSize = 4096*10;
    uint8_t *buffer = calloc(1, bufferSize);
    XCTAssertTrue(buffer != NULL);
    
    for (size_t bufferIndex = 0; bufferIndex < bufferSize; ++bufferIndex) {
        buffer[bufferIndex] = 1;
    }
    
    return [NSData dataWithBytesNoCopy:buffer length:bufferSize];
}

- (void)testBigDataSameDiff
{
    [self createAndApplyPatchWithHandler:^(NSFileManager *__unused fileManager, NSString *sourceDirectory, NSString *destinationDirectory) {
        NSString *sourceFile = [sourceDirectory stringByAppendingPathComponent:@"A"];
        NSString *destinationFile = [destinationDirectory stringByAppendingPathComponent:@"A"];

        XCTAssertTrue([[self bigData1] writeToFile:sourceFile atomically:YES]);
        XCTAssertTrue([[self bigData1] writeToFile:destinationFile atomically:YES]);
        
        XCTAssertTrue([self testDirectoryHashEqualityWithSource:sourceDirectory destination:destinationDirectory]);
    }];
}

- (void)testBigDataDifferentDiff
{
    [self createAndApplyPatchWithHandler:^(NSFileManager *__unused fileManager, NSString *sourceDirectory, NSString *destinationDirectory) {
        NSString *sourceFile = [sourceDirectory stringByAppendingPathComponent:@"A"];
        NSString *destinationFile = [destinationDirectory stringByAppendingPathComponent:@"A"];
        
        XCTAssertTrue([[self bigData1] writeToFile:sourceFile atomically:YES]);
        XCTAssertTrue([[self bigData2] writeToFile:destinationFile atomically:YES]);
        
        XCTAssertFalse([self testDirectoryHashEqualityWithSource:sourceDirectory destination:destinationDirectory]);
    }];
}

- (void)testRegularFileAdded
{
    [self createAndApplyPatchWithHandler:^(NSFileManager *__unused fileManager, NSString *sourceDirectory, NSString *destinationDirectory) {
        NSString *sourceFile = [sourceDirectory stringByAppendingPathComponent:@"A"];
        NSString *destinationFile = [destinationDirectory stringByAppendingPathComponent:@"A"];
        NSString *destinationFile2 = [destinationDirectory stringByAppendingPathComponent:@"B"];
        
        XCTAssertTrue([[NSData data] writeToFile:sourceFile atomically:YES]);
        XCTAssertTrue([[NSData dataWithBytes:"loltest" length:7] writeToFile:destinationFile atomically:YES]);
        XCTAssertTrue([[NSData dataWithBytes:"lol" length:3] writeToFile:destinationFile2 atomically:YES]);
        
        XCTAssertFalse([self testDirectoryHashEqualityWithSource:sourceDirectory destination:destinationDirectory]);
    }];
}

// Make sure old version patches still work for simple cases
- (void)testRegularFileAddedWithAzureVersion
{
    XCTAssertTrue([self createAndApplyPatchUsingVersion:SUAzureMajorVersion beforeDiffHandler:^(NSFileManager *__unused fileManager, NSString *sourceDirectory, NSString *destinationDirectory) {
        NSString *sourceFile = [sourceDirectory stringByAppendingPathComponent:@"A"];
        NSString *destinationFile = [destinationDirectory stringByAppendingPathComponent:@"A"];
        NSString *destinationFile2 = [destinationDirectory stringByAppendingPathComponent:@"B"];
        
        XCTAssertTrue([[NSData data] writeToFile:sourceFile atomically:YES]);
        XCTAssertTrue([[NSData dataWithBytes:"loltest" length:7] writeToFile:destinationFile atomically:YES]);
        XCTAssertTrue([[NSData dataWithBytes:"lol" length:3] writeToFile:destinationFile2 atomically:YES]);
        
        XCTAssertFalse([self testDirectoryHashEqualityWithSource:sourceDirectory destination:destinationDirectory]);
    } afterDiffHandler:nil]);
}

- (void)testDirectoryAdded
{
    [self createAndApplyPatchWithHandler:^(NSFileManager *fileManager, NSString *sourceDirectory, NSString *destinationDirectory) {
        NSString *sourceFile = [sourceDirectory stringByAppendingPathComponent:@"A"];
        
        NSString *destinationFile1 = [destinationDirectory stringByAppendingPathComponent:@"A"];
        NSString *destinationFile2 = [destinationDirectory stringByAppendingPathComponent:@"B"];
        NSString *destinationFile3 = [destinationFile2 stringByAppendingPathComponent:@"C"];
        
        XCTAssertTrue([[NSData data] writeToFile:sourceFile atomically:YES]);
        XCTAssertTrue([[NSData dataWithBytes:"loltest" length:7] writeToFile:destinationFile1 atomically:YES]);
        
        NSError *error = nil;
        if (![fileManager createDirectoryAtPath:destinationFile2 withIntermediateDirectories:NO attributes:nil error:&error]) {
            NSLog(@"Failed creating directory with error: %@", error);
            XCTFail("Failed to create directory");
        }
        
        XCTAssertTrue([[self bigData2] writeToFile:destinationFile3 atomically:YES]);
        XCTAssertFalse([self testDirectoryHashEqualityWithSource:sourceDirectory destination:destinationDirectory]);
    }];
}

- (void)testRegularFileRemoved
{
    [self createAndApplyPatchWithHandler:^(NSFileManager *__unused fileManager, NSString *sourceDirectory, NSString *destinationDirectory) {
        NSString *sourceFile = [sourceDirectory stringByAppendingPathComponent:@"A"];
        NSString *sourceFile2 = [destinationDirectory stringByAppendingPathComponent:@"B"];
        NSString *destinationFile = [destinationDirectory stringByAppendingPathComponent:@"A"];
        
        XCTAssertTrue([[NSData data] writeToFile:sourceFile atomically:YES]);
        XCTAssertTrue([[NSData dataWithBytes:"lol" length:3] writeToFile:sourceFile2 atomically:YES]);
        XCTAssertTrue([[NSData dataWithBytes:"loltest" length:7] writeToFile:destinationFile atomically:YES]);
        
        XCTAssertFalse([self testDirectoryHashEqualityWithSource:sourceDirectory destination:destinationDirectory]);
    }];
}

- (void)testDirectoryRemoved
{
    [self createAndApplyPatchWithHandler:^(NSFileManager *fileManager, NSString *sourceDirectory, NSString *destinationDirectory) {
        NSString *destinationFile = [destinationDirectory stringByAppendingPathComponent:@"A"];
        
        NSString *sourceFile1 = [sourceDirectory stringByAppendingPathComponent:@"A"];
        NSString *sourceFile2 = [sourceDirectory stringByAppendingPathComponent:@"B"];
        NSString *sourceFile3 = [sourceFile2 stringByAppendingPathComponent:@"C"];
        
        XCTAssertTrue([[NSData data] writeToFile:destinationFile atomically:YES]);
        XCTAssertTrue([[NSData dataWithBytes:"loltest" length:7] writeToFile:sourceFile1 atomically:YES]);
        
        NSError *error = nil;
        if (![fileManager createDirectoryAtPath:sourceFile2 withIntermediateDirectories:NO attributes:nil error:&error]) {
            NSLog(@"Failed creating directory with error: %@", error);
            XCTFail("Failed to create directory");
        }
        
        XCTAssertTrue([[self bigData2] writeToFile:sourceFile3 atomically:YES]);
        XCTAssertFalse([self testDirectoryHashEqualityWithSource:sourceDirectory destination:destinationDirectory]);
    }];
}

- (void)testRegularFileMove
{
    [self createAndApplyPatchWithHandler:^(NSFileManager *__unused fileManager, NSString *sourceDirectory, NSString *destinationDirectory) {
        NSString *sourceFile = [sourceDirectory stringByAppendingPathComponent:@"A"];
        NSString *destinationFile = [destinationDirectory stringByAppendingPathComponent:@"B"];
        
        NSData *data = [NSData dataWithBytes:"loltest" length:7];
        XCTAssertTrue([data writeToFile:sourceFile atomically:YES]);
        XCTAssertTrue([data writeToFile:destinationFile atomically:YES]);
        
        XCTAssertFalse([self testDirectoryHashEqualityWithSource:sourceDirectory destination:destinationDirectory]);
    }];
}

- (void)testCaseSensitiveRegularFileMove
{
    [self createAndApplyPatchWithHandler:^(NSFileManager *__unused fileManager, NSString *sourceDirectory, NSString *destinationDirectory) {
        NSString *sourceFile1 = [sourceDirectory stringByAppendingPathComponent:@"A"];
        NSString *sourceFile2 = [sourceDirectory stringByAppendingPathComponent:@"b"];
        
        NSString *destinationFile1 = [destinationDirectory stringByAppendingPathComponent:@"a"];
        NSString *destinationFile2 = [destinationDirectory stringByAppendingPathComponent:@"B"];
        
        NSData *data = [NSData dataWithBytes:"loltest" length:7];
        
        XCTAssertTrue([data writeToFile:sourceFile1 atomically:YES]);
        XCTAssertTrue([data writeToFile:sourceFile2 atomically:YES]);
        
        XCTAssertTrue([data writeToFile:destinationFile1 atomically:YES]);
        XCTAssertTrue([data writeToFile:destinationFile2 atomically:YES]);
        
        XCTAssertFalse([self testDirectoryHashEqualityWithSource:sourceDirectory destination:destinationDirectory]);
    }];
}

- (void)testRemovingSymlink
{
    [self createAndApplyPatchWithHandler:^(NSFileManager *fileManager, NSString *sourceDirectory, NSString *destinationDirectory) {
        NSString *sourceFile = [sourceDirectory stringByAppendingPathComponent:@"A"];
        
        NSError *error = nil;
        if (![fileManager createSymbolicLinkAtPath:sourceFile withDestinationPath:@"B" error:&error]) {
            NSLog(@"Error in creating symlink: %@", error);
            XCTFail(@"Failed to create symlink");
        }
        
        XCTAssertFalse([self testDirectoryHashEqualityWithSource:sourceDirectory destination:destinationDirectory]);
    }];
}

- (void)testAddingSymlink
{
    [self createAndApplyPatchWithHandler:^(NSFileManager *fileManager, NSString *sourceDirectory, NSString *destinationDirectory) {
        NSString *destinationFile = [destinationDirectory stringByAppendingPathComponent:@"A"];
        
        NSError *error = nil;
        if (![fileManager createSymbolicLinkAtPath:destinationFile withDestinationPath:@"B" error:&error]) {
            NSLog(@"Error in creating symlink: %@", error);
            XCTFail(@"Failed to create symlink");
        }
        
        XCTAssertFalse([self testDirectoryHashEqualityWithSource:sourceDirectory destination:destinationDirectory]);
    }];
}

- (void)testSmallFilePermissionChangeWithNoContentChange
{
    [self createAndApplyPatchWithHandler:^(NSFileManager *fileManager, NSString *sourceDirectory, NSString *destinationDirectory) {
        NSString *sourceFile = [sourceDirectory stringByAppendingPathComponent:@"A"];
        NSString *destinationFile = [destinationDirectory stringByAppendingPathComponent:@"A"];
        
        NSData *data = [NSData dataWithBytes:"loltest" length:7];
        XCTAssertTrue([data writeToFile:sourceFile atomically:YES]);
        XCTAssertTrue([data writeToFile:destinationFile atomically:YES]);
        
        NSError *error = nil;
        if (![fileManager setAttributes:@{NSFilePosixPermissions : @0755} ofItemAtPath:destinationFile error:&error]) {
            NSLog(@"Change Permission Error: %@", error);
            XCTFail(@"Failed setting file permissions");
        }
        
        // This would fail for version 1.0
        XCTAssertFalse([self testDirectoryHashEqualityWithSource:sourceDirectory destination:destinationDirectory]);
    }];
}

- (void)testBigFilePermissionChangeWithNoContentChange
{
    [self createAndApplyPatchWithHandler:^(NSFileManager *fileManager, NSString *sourceDirectory, NSString *destinationDirectory) {
        NSString *sourceFile = [sourceDirectory stringByAppendingPathComponent:@"A"];
        NSString *destinationFile = [destinationDirectory stringByAppendingPathComponent:@"A"];
        
        NSData *data = [self bigData1];
        XCTAssertTrue([data writeToFile:sourceFile atomically:YES]);
        XCTAssertTrue([data writeToFile:destinationFile atomically:YES]);
        
        NSError *error = nil;
        if (![fileManager setAttributes:@{NSFilePosixPermissions : @0755} ofItemAtPath:destinationFile error:&error]) {
            NSLog(@"Change Permission Error: %@", error);
            XCTFail(@"Failed setting file permissions");
        }
        
        // This would fail for version 1.0
        XCTAssertFalse([self testDirectoryHashEqualityWithSource:sourceDirectory destination:destinationDirectory]);
    }];
}

- (void)testSmallFilePermissionChangeWithContentChange
{
    [self createAndApplyPatchWithHandler:^(NSFileManager *fileManager, NSString *sourceDirectory, NSString *destinationDirectory) {
        NSString *sourceFile = [sourceDirectory stringByAppendingPathComponent:@"A"];
        NSString *destinationFile = [destinationDirectory stringByAppendingPathComponent:@"A"];
        
        XCTAssertTrue([[NSData data] writeToFile:sourceFile atomically:YES]);
        XCTAssertTrue([[NSData dataWithBytes:@"lawl" length:4] writeToFile:destinationFile atomically:YES]);
        
        NSError *error = nil;
        if (![fileManager setAttributes:@{NSFilePosixPermissions : @0755} ofItemAtPath:destinationFile error:&error]) {
            NSLog(@"Change Permission Error: %@", error);
            XCTFail(@"Failed setting file permissions");
        }
        
        // This would fail for version 1.0
        XCTAssertFalse([self testDirectoryHashEqualityWithSource:sourceDirectory destination:destinationDirectory]);
    }];
}

- (void)testBigFilePermissionChangeWithContentChange
{
    [self createAndApplyPatchWithHandler:^(NSFileManager *fileManager, NSString *sourceDirectory, NSString *destinationDirectory) {
        NSString *sourceFile = [sourceDirectory stringByAppendingPathComponent:@"A"];
        NSString *destinationFile = [destinationDirectory stringByAppendingPathComponent:@"A"];
        
        XCTAssertTrue([[self bigData1] writeToFile:sourceFile atomically:YES]);
        XCTAssertTrue([[self bigData2] writeToFile:destinationFile atomically:YES]);
        
        NSError *error = nil;
        if (![fileManager setAttributes:@{NSFilePosixPermissions : @0755} ofItemAtPath:destinationFile error:&error]) {
            NSLog(@"Change Permission Error: %@", error);
            XCTFail(@"Failed setting file permissions");
        }
        
        // This would fail for version 1.0
        XCTAssertFalse([self testDirectoryHashEqualityWithSource:sourceDirectory destination:destinationDirectory]);
    }];
}

- (void)testDirectoryPermissionChangeWithContentChange
{
    [self createAndApplyPatchWithHandler:^(NSFileManager *fileManager, NSString *sourceDirectory, NSString *destinationDirectory) {
        NSString *sourceFile1 = [sourceDirectory stringByAppendingPathComponent:@"A"];
        NSString *sourceFile2 = [sourceFile1 stringByAppendingPathComponent:@"B"];
        
        NSString *destinationFile1 = [destinationDirectory stringByAppendingPathComponent:@"A"];
        NSString *destinationFile2 = [destinationFile1 stringByAppendingPathComponent:@"B"];
        
        NSError *error = nil;
        if (![fileManager createDirectoryAtPath:sourceFile1 withIntermediateDirectories:NO attributes:nil error:&error]) {
            NSLog(@"Failed creating directory with error: %@", error);
            XCTFail("Failed to create directory");
        }
        
        if (![fileManager createDirectoryAtPath:destinationFile1 withIntermediateDirectories:NO attributes:nil error:&error]) {
            NSLog(@"Failed creating directory with error: %@", error);
            XCTFail("Failed to create directory");
        }
        
        XCTAssertTrue([[self bigData1] writeToFile:sourceFile2 atomically:YES]);
        XCTAssertTrue([[self bigData1] writeToFile:destinationFile2 atomically:YES]);
        
        if (![fileManager setAttributes:@{NSFilePosixPermissions : @0766} ofItemAtPath:sourceFile1 error:&error]) {
            NSLog(@"Change Permission Error: %@", error);
            XCTFail(@"Failed setting file permissions");
        }
        
        if (![fileManager setAttributes:@{NSFilePosixPermissions : @0755} ofItemAtPath:destinationFile1 error:&error]) {
            NSLog(@"Change Permission Error: %@", error);
            XCTFail(@"Failed setting file permissions");
        }
        
        // This would fail for version 1.0
        XCTAssertFalse([self testDirectoryHashEqualityWithSource:sourceDirectory destination:destinationDirectory]);
    }];
}

- (void)testInvalidPermissionsInAfterTree
{
    BOOL success = [self createAndApplyPatchWithBeforeDiffHandler:^(NSFileManager *fileManager, NSString *sourceDirectory, NSString *destinationDirectory) {
        NSString *sourceFile = [sourceDirectory stringByAppendingPathComponent:@"A"];
        NSString *destinationFile = [destinationDirectory stringByAppendingPathComponent:@"A"];
        
        NSData *data = [NSData dataWithBytes:"loltest" length:7];
        XCTAssertTrue([data writeToFile:sourceFile atomically:YES]);
        XCTAssertTrue([data writeToFile:destinationFile atomically:YES]);
        
        NSError *error = nil;
        if (![fileManager setAttributes:@{NSFilePosixPermissions : @0777} ofItemAtPath:destinationFile error:&error]) {
            NSLog(@"Change Permission Error: %@", error);
            XCTFail(@"Failed setting file permissions");
        }
        
        // This would fail for version 1.0
        XCTAssertFalse([self testDirectoryHashEqualityWithSource:sourceDirectory destination:destinationDirectory]);
    } afterDiffHandler:nil];
    XCTAssertFalse(success);
}

- (void)testBadPermissionsInBeforeTree
{
    [self createAndApplyPatchWithHandler:^(NSFileManager *fileManager, NSString *sourceDirectory, NSString *destinationDirectory) {
        NSString *sourceFile = [sourceDirectory stringByAppendingPathComponent:@"A"];
        NSString *destinationFile = [destinationDirectory stringByAppendingPathComponent:@"A"];
        
        NSData *data = [NSData dataWithBytes:"loltest" length:7];
        XCTAssertTrue([data writeToFile:sourceFile atomically:YES]);
        XCTAssertTrue([data writeToFile:destinationFile atomically:YES]);
        
        NSError *error = nil;
        if (![fileManager setAttributes:@{NSFilePosixPermissions : @0777} ofItemAtPath:sourceFile error:&error]) {
            NSLog(@"Change Permission Error: %@", error);
            XCTFail(@"Failed setting file permissions");
        }
        
        // This would fail for version 1.0
        XCTAssertFalse([self testDirectoryHashEqualityWithSource:sourceDirectory destination:destinationDirectory]);
    }];
}

- (void)testInvalidRegularFileWithACLInBeforeTree
{
    BOOL success = [self createAndApplyPatchWithBeforeDiffHandler:^(NSFileManager *__unused fileManager, NSString *sourceDirectory, NSString * __unused destinationDirectory) {
        NSString *sourceFile = [sourceDirectory stringByAppendingPathComponent:@"A"];
        
        XCTAssertTrue([[NSData dataWithBytes:"loltest" length:7] writeToFile:sourceFile atomically:YES]);
        
        acl_t acl = acl_init(1);
        
        acl_entry_t entry;
        XCTAssertEqual(0, acl_create_entry(&acl, &entry));
        
        acl_permset_t permset;
        XCTAssertEqual(0, acl_get_permset(entry, &permset));
        
        XCTAssertEqual(0, acl_add_perm(permset, ACL_SEARCH));
        
        XCTAssertEqual(0, acl_set_link_np([sourceFile fileSystemRepresentation], ACL_TYPE_EXTENDED, acl));
        
        XCTAssertEqual(0, acl_free(acl));
    } afterDiffHandler:nil];
    
    XCTAssertFalse(success);
}

- (void)testInvalidRegularFileWithACLInAfterTree
{
    BOOL success = [self createAndApplyPatchWithBeforeDiffHandler:^(NSFileManager *__unused fileManager, NSString *__unused sourceDirectory, NSString *destinationDirectory) {
        NSString *destinationFile = [destinationDirectory stringByAppendingPathComponent:@"A"];
        
        XCTAssertTrue([[NSData dataWithBytes:"loltest" length:7] writeToFile:destinationFile atomically:YES]);
        
        acl_t acl = acl_init(1);
        
        acl_entry_t entry;
        XCTAssertEqual(0, acl_create_entry(&acl, &entry));
        
        acl_permset_t permset;
        XCTAssertEqual(0, acl_get_permset(entry, &permset));
        
        XCTAssertEqual(0, acl_add_perm(permset, ACL_SEARCH));
        
        XCTAssertEqual(0, acl_set_link_np([destinationFile fileSystemRepresentation], ACL_TYPE_EXTENDED, acl));
        
        XCTAssertEqual(0, acl_free(acl));
        
    } afterDiffHandler:nil];
    
    XCTAssertFalse(success);
}

- (void)testInvalidDirectoryWithACLInBeforeTree
{
    BOOL success = [self createAndApplyPatchWithBeforeDiffHandler:^(NSFileManager *fileManager, NSString *sourceDirectory, NSString * __unused destinationDirectory) {
        NSString *sourceFile = [sourceDirectory stringByAppendingPathComponent:@"A"];
        
        XCTAssertTrue([fileManager createDirectoryAtPath:sourceFile withIntermediateDirectories:NO attributes:nil error:nil]);
        
        acl_t acl = acl_init(1);
        
        acl_entry_t entry;
        XCTAssertEqual(0, acl_create_entry(&acl, &entry));
        
        acl_permset_t permset;
        XCTAssertEqual(0, acl_get_permset(entry, &permset));
        
        XCTAssertEqual(0, acl_add_perm(permset, ACL_SEARCH));
        
        XCTAssertEqual(0, acl_set_link_np([sourceFile fileSystemRepresentation], ACL_TYPE_EXTENDED, acl));
        
        XCTAssertEqual(0, acl_free(acl));
    } afterDiffHandler:nil];
    
    XCTAssertFalse(success);
}

- (void)testInvalidDirectoryWithACLInAfterTree
{
    BOOL success = [self createAndApplyPatchWithBeforeDiffHandler:^(NSFileManager *fileManager, NSString * __unused sourceDirectory, NSString *destinationDirectory) {
        NSString *destinationFile = [destinationDirectory stringByAppendingPathComponent:@"A"];
        
        XCTAssertTrue([fileManager createDirectoryAtPath:destinationFile withIntermediateDirectories:NO attributes:nil error:nil]);
        
        acl_t acl = acl_init(1);
        
        acl_entry_t entry;
        XCTAssertEqual(0, acl_create_entry(&acl, &entry));
        
        acl_permset_t permset;
        XCTAssertEqual(0, acl_get_permset(entry, &permset));
        
        XCTAssertEqual(0, acl_add_perm(permset, ACL_SEARCH));
        
        XCTAssertEqual(0, acl_set_link_np([destinationFile fileSystemRepresentation], ACL_TYPE_EXTENDED, acl));
        
        XCTAssertEqual(0, acl_free(acl));
    } afterDiffHandler:nil];
    
    XCTAssertFalse(success);
}

- (void)testRegularFileToSymlinkChange
{
    [self createAndApplyPatchWithHandler:^(NSFileManager *fileManager, NSString *sourceDirectory, NSString *destinationDirectory) {
        NSString *sourceFile1 = [sourceDirectory stringByAppendingPathComponent:@"A"];
        NSString *sourceFile2 = [sourceDirectory stringByAppendingPathComponent:@"B"];
        
        NSString *destinationFile1 = [destinationDirectory stringByAppendingPathComponent:@"A"];
        NSString *destinationFile2 = [destinationDirectory stringByAppendingPathComponent:@"B"];
        
        NSData *data = [NSData dataWithBytes:"A" length:1];
        
        XCTAssertTrue([data writeToFile:sourceFile1 atomically:YES]);
        XCTAssertTrue([data writeToFile:sourceFile2 atomically:YES]);
        
        XCTAssertTrue([data writeToFile:destinationFile1 atomically:YES]);
        
        NSError *error = nil;
        if (![fileManager createSymbolicLinkAtPath:destinationFile2 withDestinationPath:@"A" error:&error]) {
            NSLog(@"Error in creating symlink: %@", error);
            XCTFail(@"Failed to create symlink");
        }
        
        // This would fail with version 1.0
        XCTAssertFalse([self testDirectoryHashEqualityWithSource:sourceDirectory destination:destinationDirectory]);
    }];
}

- (void)testSymlinkToRegularFileChange
{
    [self createAndApplyPatchWithHandler:^(NSFileManager *fileManager, NSString *sourceDirectory, NSString *destinationDirectory) {
        NSString *sourceFile1 = [sourceDirectory stringByAppendingPathComponent:@"A"];
        NSString *sourceFile2 = [sourceDirectory stringByAppendingPathComponent:@"B"];
        
        NSString *destinationFile1 = [destinationDirectory stringByAppendingPathComponent:@"A"];
        NSString *destinationFile2 = [destinationDirectory stringByAppendingPathComponent:@"B"];
        
        NSData *data = [NSData dataWithBytes:"loltest" length:7];
        
        XCTAssertTrue([data writeToFile:sourceFile1 atomically:YES]);
        
        XCTAssertTrue([data writeToFile:destinationFile1 atomically:YES]);
        XCTAssertTrue([data writeToFile:destinationFile2 atomically:YES]);
        
        NSError *error = nil;
        if (![fileManager createSymbolicLinkAtPath:sourceFile2 withDestinationPath:@"A" error:&error]) {
            NSLog(@"Error in creating symlink: %@", error);
            XCTFail(@"Failed to create symlink");
        }
        
        XCTAssertFalse([self testDirectoryHashEqualityWithSource:sourceDirectory destination:destinationDirectory]);
    }];
}

- (void)testRegularFileToDirectoryChange
{
    [self createAndApplyPatchWithHandler:^(NSFileManager *fileManager, NSString *sourceDirectory, NSString *destinationDirectory) {
        NSString *sourceFile = [sourceDirectory stringByAppendingPathComponent:@"A"];
        NSString *destinationFile = [destinationDirectory stringByAppendingPathComponent:@"A"];
        
        NSData *data = [NSData dataWithBytes:"loltest" length:7];
        XCTAssertTrue([data writeToFile:sourceFile atomically:YES]);
        
        NSError *error = nil;
        if (![fileManager createDirectoryAtPath:destinationFile withIntermediateDirectories:NO attributes:nil error:&error]) {
            NSLog(@"Failed creating directory with error: %@", error);
            XCTFail("Failed to create directory");
        }
        
        XCTAssertFalse([self testDirectoryHashEqualityWithSource:sourceDirectory destination:destinationDirectory]);
    }];
}

- (void)testDirectoryToRegularFileChange
{
    [self createAndApplyPatchWithHandler:^(NSFileManager *fileManager, NSString *sourceDirectory, NSString *destinationDirectory) {
        NSString *sourceFile = [sourceDirectory stringByAppendingPathComponent:@"A"];
        NSString *destinationFile = [destinationDirectory stringByAppendingPathComponent:@"A"];
        
        NSError *error = nil;
        if (![fileManager createDirectoryAtPath:sourceFile withIntermediateDirectories:NO attributes:nil error:&error]) {
            NSLog(@"Failed creating directory with error: %@", error);
            XCTFail("Failed to create directory");
        }
        
        NSData *data = [NSData dataWithBytes:"loltest" length:7];
        XCTAssertTrue([data writeToFile:destinationFile atomically:YES]);
        
        XCTAssertFalse([self testDirectoryHashEqualityWithSource:sourceDirectory destination:destinationDirectory]);
    }];
}

// See issue #514 for more info
- (void)testDirectoryToSymlinkChange
{
    [self createAndApplyPatchWithHandler:^(NSFileManager *fileManager, NSString *sourceDirectory, NSString *destinationDirectory) {
        NSString *sourceFile1 = [sourceDirectory stringByAppendingPathComponent:@"A"];
        NSString *sourceFile2 = [sourceDirectory stringByAppendingPathComponent:@"Current"];
        NSString *sourceFile3 = [sourceFile2 stringByAppendingPathComponent:@"B"];
        
        NSString *destinationFile1 = [destinationDirectory stringByAppendingPathComponent:@"A"];
        NSString *destinationFile2 = [destinationFile1 stringByAppendingPathComponent:@"B"];
        NSString *destinationFile3 = [destinationDirectory stringByAppendingPathComponent:@"Current"];
        
        NSError *error = nil;
        if (![fileManager createDirectoryAtPath:sourceFile1 withIntermediateDirectories:NO attributes:nil error:&error]) {
            NSLog(@"Failed creating directory with error: %@", error);
            XCTFail("Failed to create directory A in source");
        }
        
        if (![fileManager createDirectoryAtPath:sourceFile2 withIntermediateDirectories:NO attributes:nil error:&error]) {
            NSLog(@"Failed creating directory with error: %@", error);
            XCTFail("Failed to create directory Current in source");
        }
        
        if (![fileManager createDirectoryAtPath:destinationFile1 withIntermediateDirectories:NO attributes:nil error:&error]) {
            NSLog(@"Failed creating directory with error: %@", error);
            XCTFail("Failed to create directory A in destination");
        }
        
        if (![fileManager createSymbolicLinkAtPath:destinationFile3 withDestinationPath:@"A/" error:&error]) {
            NSLog(@"Error in creating symlink: %@", error);
            XCTFail(@"Failed to create symlink");
        }
        
        XCTAssertTrue([[self bigData1] writeToFile:sourceFile3 atomically:YES]);
        XCTAssertTrue([[self bigData1] writeToFile:destinationFile2 atomically:YES]);
        
        XCTAssertFalse([self testDirectoryHashEqualityWithSource:sourceDirectory destination:destinationDirectory]);
    }];
}

// Opposite of the test method testDirectoryToSymlinkChange
- (void)testSymlinkToDirectoryChange
{
    [self createAndApplyPatchWithHandler:^(NSFileManager *fileManager, NSString *sourceDirectory, NSString *destinationDirectory) {
        NSString *sourceFile1 = [sourceDirectory stringByAppendingPathComponent:@"A"];
        NSString *sourceFile2 = [sourceFile1 stringByAppendingPathComponent:@"B"];
        NSString *sourceFile3 = [sourceDirectory stringByAppendingPathComponent:@"Current"];
        
        NSString *destinationFile1 = [destinationDirectory stringByAppendingPathComponent:@"A"];
        NSString *destinationFile2 = [destinationDirectory stringByAppendingPathComponent:@"Current"];
        NSString *destinationFile3 = [destinationFile2 stringByAppendingPathComponent:@"B"];
        
        NSError *error = nil;
        if (![fileManager createDirectoryAtPath:sourceFile1 withIntermediateDirectories:NO attributes:nil error:&error]) {
            NSLog(@"Failed creating directory with error: %@", error);
            XCTFail("Failed to create directory A in source");
        }
        
        if (![fileManager createDirectoryAtPath:destinationFile1 withIntermediateDirectories:NO attributes:nil error:&error]) {
            NSLog(@"Failed creating directory with error: %@", error);
            XCTFail("Failed to create directory A in destination");
        }
        
        if (![fileManager createDirectoryAtPath:destinationFile2 withIntermediateDirectories:NO attributes:nil error:&error]) {
            NSLog(@"Failed creating directory with error: %@", error);
            XCTFail("Failed to create directory Current in destination");
        }
        
        if (![fileManager createSymbolicLinkAtPath:sourceFile3 withDestinationPath:@"A/" error:&error]) {
            NSLog(@"Error in creating symlink: %@", error);
            XCTFail(@"Failed to create symlink");
        }
        
        XCTAssertTrue([[self bigData1] writeToFile:sourceFile2 atomically:YES]);
        XCTAssertTrue([[self bigData1] writeToFile:destinationFile3 atomically:YES]);
        
        XCTAssertFalse([self testDirectoryHashEqualityWithSource:sourceDirectory destination:destinationDirectory]);
    }];
}

- (void)testInvalidCodeSignatureExtendedAttributeInBeforeTree
{
    BOOL success = [self createAndApplyPatchWithBeforeDiffHandler:^(NSFileManager *__unused fileManager, NSString *sourceDirectory, NSString *destinationDirectory) {
        NSString *sourceFile = [sourceDirectory stringByAppendingPathComponent:@"A"];
        NSString *destinationFile = [destinationDirectory stringByAppendingPathComponent:@"A"];
        
        XCTAssertTrue([[NSData data] writeToFile:sourceFile atomically:YES]);
        XCTAssertTrue([[NSData dataWithBytes:"loltest" length:7] writeToFile:destinationFile atomically:YES]);
        
        // the actual data doesn't matter for testing purposes
        const char xattrValue[] = "hello";
        
        XCTAssertEqual(0, setxattr([sourceFile fileSystemRepresentation], APPLE_CODE_SIGN_XATTR_CODE_DIRECTORY_KEY, xattrValue, sizeof(xattrValue), 0, XATTR_CREATE));
        XCTAssertEqual(0, setxattr([sourceFile fileSystemRepresentation], APPLE_CODE_SIGN_XATTR_CODE_REQUIREMENTS_KEY, xattrValue, sizeof(xattrValue), 0, XATTR_CREATE));
        XCTAssertEqual(0, setxattr([sourceFile fileSystemRepresentation], APPLE_CODE_SIGN_XATTR_CODE_SIGNATURE_KEY, xattrValue, sizeof(xattrValue), 0, XATTR_CREATE));
    } afterDiffHandler:nil];
    XCTAssertFalse(success);
}

- (void)testInvalidCodeSignatureExtendedAttributeInAfterTree
{
    BOOL success = [self createAndApplyPatchWithBeforeDiffHandler:^(NSFileManager *__unused fileManager, NSString *sourceDirectory, NSString *destinationDirectory) {
        NSString *sourceFile = [sourceDirectory stringByAppendingPathComponent:@"A"];
        NSString *destinationFile = [destinationDirectory stringByAppendingPathComponent:@"A"];
        
        XCTAssertTrue([[NSData data] writeToFile:sourceFile atomically:YES]);
        XCTAssertTrue([[NSData dataWithBytes:"loltest" length:7] writeToFile:destinationFile atomically:YES]);
        
        // the actual data doesn't matter for testing purposes
        const char xattrValue[] = "hello";
        
        XCTAssertEqual(0, setxattr([destinationFile fileSystemRepresentation], APPLE_CODE_SIGN_XATTR_CODE_DIRECTORY_KEY, xattrValue, sizeof(xattrValue), 0, XATTR_CREATE));
        XCTAssertEqual(0, setxattr([destinationFile fileSystemRepresentation], APPLE_CODE_SIGN_XATTR_CODE_REQUIREMENTS_KEY, xattrValue, sizeof(xattrValue), 0, XATTR_CREATE));
        XCTAssertEqual(0, setxattr([destinationFile fileSystemRepresentation], APPLE_CODE_SIGN_XATTR_CODE_SIGNATURE_KEY, xattrValue, sizeof(xattrValue), 0, XATTR_CREATE));
    } afterDiffHandler:nil];
    XCTAssertFalse(success);
}

@end
