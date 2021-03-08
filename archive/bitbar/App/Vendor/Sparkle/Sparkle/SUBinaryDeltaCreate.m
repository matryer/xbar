//
//  SUBinaryDeltaCreate.m
//  Sparkle
//
//  Created by Mayur Pawashe on 4/9/15.
//  Copyright (c) 2015 Sparkle Project. All rights reserved.
//

#import "SUBinaryDeltaCreate.h"
#import <Foundation/Foundation.h>
#include "SUBinaryDeltaCommon.h"
#import <CommonCrypto/CommonDigest.h>
#include <fcntl.h>
#include <fts.h>
#include <libgen.h>
#include <stdio.h>
#include <sys/mman.h>
#include <sys/param.h>
#include <sys/stat.h>
#include <unistd.h>
#include <sys/xattr.h>
#include <xar/xar.h>

extern int bsdiff(int argc, const char **argv);

@interface CreateBinaryDeltaOperation : NSOperation
@property (copy) NSString *relativePath;
@property (strong) NSString *resultPath;
@property (strong) NSNumber *oldPermissions;
@property (strong) NSNumber *permissions;
@property (strong) NSString *_fromPath;
@property (strong) NSString *_toPath;
- (id)initWithRelativePath:(NSString *)relativePath oldTree:(NSString *)oldTree newTree:(NSString *)newTree oldPermissions:(NSNumber *)oldPermissions newPermissions:(NSNumber *)permissions;
@end

@implementation CreateBinaryDeltaOperation
@synthesize relativePath = _relativePath;
@synthesize resultPath = _resultPath;
@synthesize oldPermissions = _oldPermissions;
@synthesize permissions = _permissions;
@synthesize _fromPath = _fromPath;
@synthesize _toPath = _toPath;

- (id)initWithRelativePath:(NSString *)relativePath oldTree:(NSString *)oldTree newTree:(NSString *)newTree oldPermissions:(NSNumber *)oldPermissions newPermissions:(NSNumber *)permissions
{
    if ((self = [super init])) {
        self.relativePath = relativePath;
        self.oldPermissions = oldPermissions;
        self.permissions = permissions;
        self._fromPath = [oldTree stringByAppendingPathComponent:relativePath];
        self._toPath = [newTree stringByAppendingPathComponent:relativePath];
    }
    return self;
}

- (void)main
{
    NSString *temporaryFile = temporaryFilename(@"BinaryDelta");
    const char *argv[] = {"/usr/bin/bsdiff", [self._fromPath fileSystemRepresentation], [self._toPath fileSystemRepresentation], [temporaryFile fileSystemRepresentation]};
    int result = bsdiff(4, argv);
    if (!result)
        self.resultPath = temporaryFile;
}

@end

#define INFO_HASH_KEY @"hash"
#define INFO_TYPE_KEY @"type"
#define INFO_PERMISSIONS_KEY @"permissions"
#define INFO_SIZE_KEY @"size"

static NSDictionary *infoForFile(FTSENT *ent)
{
    NSData *hash = hashOfFileContents(ent);
    if (!hash) {
        return nil;
    }
    
    off_t size = (ent->fts_info != FTS_D) ? ent->fts_statp->st_size : 0;
    
    assert(ent->fts_statp != NULL);
    
    mode_t permissions = ent->fts_statp->st_mode & PERMISSION_FLAGS;
    
    return @{INFO_HASH_KEY: hash, INFO_TYPE_KEY: @(ent->fts_info), INFO_PERMISSIONS_KEY : @(permissions), INFO_SIZE_KEY: @(size)};
}

static bool aclExists(const FTSENT *ent)
{
    // macOS does not currently support ACLs for symlinks
    if (ent->fts_info == FTS_SL) {
        return NO;
    }
    
    acl_t acl = acl_get_link_np(ent->fts_path, ACL_TYPE_EXTENDED);
    if (acl != NULL) {
        acl_entry_t entry;
        int result = acl_get_entry(acl, ACL_FIRST_ENTRY, &entry);
        assert(acl_free((void *)acl) == 0);
        return (result == 0);
    }
    return false;
}

static bool codeSignatureExtendedAttributeExists(const FTSENT *ent)
{
    const int options = XATTR_NOFOLLOW;
    ssize_t listSize = listxattr(ent->fts_path, NULL, 0, options);
    if (listSize == -1) {
        return false;
    }
    
    char *buffer = malloc((size_t)listSize);
    assert(buffer != NULL);
    
    ssize_t sizeBack = listxattr(ent->fts_path, buffer, (size_t)listSize, options);
    assert(sizeBack == listSize);
    
    size_t startCharacterIndex = 0;
    for (size_t characterIndex = 0; characterIndex < (size_t)listSize; characterIndex++) {
        if (buffer[characterIndex] == '\0') {
            char *attribute = &buffer[startCharacterIndex];
            size_t length = characterIndex - startCharacterIndex;
            if (strncmp(APPLE_CODE_SIGN_XATTR_CODE_DIRECTORY_KEY, attribute, length) == 0 ||
                strncmp(APPLE_CODE_SIGN_XATTR_CODE_REQUIREMENTS_KEY, attribute, length) == 0 ||
                strncmp(APPLE_CODE_SIGN_XATTR_CODE_SIGNATURE_KEY, attribute, length) == 0) {
                free(buffer);
                return true;
            }
            startCharacterIndex = characterIndex + 1;
        }
    }
    
    free(buffer);
    return false;
}

static NSString *absolutePath(NSString *path)
{
    NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
    return  [[url absoluteURL] path];
}

static NSString *temporaryPatchFile(NSString *patchFile)
{
    NSString *path = absolutePath(patchFile);
    NSString *directory = [path stringByDeletingLastPathComponent];
    NSString *file = [path lastPathComponent];
    return [NSString stringWithFormat:@"%@/.%@.tmp", directory, file];
}

#define MIN_FILE_SIZE_FOR_CREATING_DELTA 4096

static BOOL shouldSkipDeltaCompression(NSDictionary* originalInfo, NSDictionary *newInfo)
{
    unsigned long long fileSize = [newInfo[INFO_SIZE_KEY] unsignedLongLongValue];
    if (fileSize < MIN_FILE_SIZE_FOR_CREATING_DELTA) {
        return YES;
    }

    if (!originalInfo) {
        return YES;
    }

    if ([originalInfo[INFO_TYPE_KEY] unsignedShortValue] != [newInfo[INFO_TYPE_KEY] unsignedShortValue]) {
        return YES;
    }
    
    if ([originalInfo[INFO_HASH_KEY] isEqual:newInfo[INFO_HASH_KEY]]) {
        // this is possible if just the permissions have changed
        return YES;
    }

    return NO;
}

static BOOL shouldDeleteThenExtract(NSDictionary* originalInfo, NSDictionary *newInfo)
{
    if (!originalInfo) {
        return NO;
    }

    if ([originalInfo[INFO_TYPE_KEY] unsignedShortValue] != [newInfo[INFO_TYPE_KEY] unsignedShortValue]) {
        return YES;
    }

    return NO;
}

static BOOL shouldSkipExtracting(NSDictionary *originalInfo, NSDictionary *newInfo)
{
    if (!originalInfo) {
        return NO;
    }
    
    if ([originalInfo[INFO_TYPE_KEY] unsignedShortValue] != [newInfo[INFO_TYPE_KEY] unsignedShortValue]) {
        return NO;
    }
    
    if (![originalInfo[INFO_HASH_KEY] isEqual:newInfo[INFO_HASH_KEY]]) {
        return NO;
    }
    
    return YES;
}

static BOOL shouldChangePermissions(NSDictionary *originalInfo, NSDictionary *newInfo)
{
    if (!originalInfo) {
        return NO;
    }
    
    if ([originalInfo[INFO_TYPE_KEY] unsignedShortValue] != [newInfo[INFO_TYPE_KEY] unsignedShortValue]) {
        return NO;
    }
    
    if ([originalInfo[INFO_PERMISSIONS_KEY] unsignedShortValue] == [newInfo[INFO_PERMISSIONS_KEY] unsignedShortValue]) {
        return NO;
    }
    
    return YES;
}

BOOL createBinaryDelta(NSString *source, NSString *destination, NSString *patchFile, SUBinaryDeltaMajorVersion majorVersion, BOOL verbose, NSError * __autoreleasing *error)
{
    assert(source);
    assert(destination);
    assert(patchFile);
    assert(majorVersion >= FIRST_DELTA_DIFF_MAJOR_VERSION && majorVersion <= LATEST_DELTA_DIFF_MAJOR_VERSION);
    
    SUBinaryDeltaMinorVersion minorVersion = latestMinorVersionForMajorVersion(majorVersion);
    
    NSMutableDictionary *originalTreeState = [NSMutableDictionary dictionary];

    char pathBuffer[PATH_MAX] = {0};
    if (![source getFileSystemRepresentation:pathBuffer maxLength:sizeof(pathBuffer)]) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadInvalidFileNameError userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Failed to retrieve file system path representation from source %@", source] }];
        }
        return NO;
    }

    char *sourcePaths[] = {pathBuffer, 0};
    FTS *fts = fts_open(sourcePaths, FTS_PHYSICAL | FTS_NOCHDIR, compareFiles);
    if (!fts) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"fts_open failed on source: %@", @(strerror(errno))] }];
        }
        return NO;
    }

    if (verbose) {
        fprintf(stderr, "Creating version %u.%u patch...\n", majorVersion, minorVersion);
        fprintf(stderr, "Processing %s...", [source fileSystemRepresentation]);
    }
    
    FTSENT *ent = 0;
    while ((ent = fts_read(fts))) {
        if (ent->fts_info != FTS_F && ent->fts_info != FTS_SL && ent->fts_info != FTS_D) {
            continue;
        }

        NSString *key = pathRelativeToDirectory(source, stringWithFileSystemRepresentation(ent->fts_path));
        if (![key length]) {
            continue;
        }

        NSDictionary *info = infoForFile(ent);
        if (!info) {
            if (verbose) {
                fprintf(stderr, "\n");
            }
            if (error != NULL) {
                *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadUnknownError userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Failed to retrieve info for file %@", @(ent->fts_path)] }];
            }
            return NO;
        }
        originalTreeState[key] = info;
        
        if (aclExists(ent)) {
            if (verbose) {
                fprintf(stderr, "\n");
            }
            if (error != NULL) {
                *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadUnknownError userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Diffing ACLs are not supported. Detected ACL in before-tree on file %@", @(ent->fts_path)] }];
            }
            return NO;
        }
        
        if (codeSignatureExtendedAttributeExists(ent)) {
            if (verbose) {
                fprintf(stderr, "\n");
            }
            if (error != NULL) {
                *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadUnknownError userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Diffing code signed extended attributes are not supported. Detected extended attribute in before-tree on file %@", @(ent->fts_path)] }];
            }
            return NO;
        }
    }
    fts_close(fts);
    
    NSString *beforeHash = hashOfTreeWithVersion(source, majorVersion);

    if (!beforeHash) {
        if (verbose) {
            fprintf(stderr, "\n");
        }
        if (error != NULL) {
            *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadUnknownError userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Failed to generate hash for tree %@", source] }];
        }
        return NO;
    }

    NSMutableDictionary *newTreeState = [NSMutableDictionary dictionary];
    for (NSString *key in originalTreeState)
    {
        newTreeState[key] = [NSNull null];
    }

    if (verbose) {
        fprintf(stderr, "\nProcessing %s...", [destination fileSystemRepresentation]);
    }

    pathBuffer[0] = 0;
    if (![destination getFileSystemRepresentation:pathBuffer maxLength:sizeof(pathBuffer)]) {
        if (verbose) {
            fprintf(stderr, "\n");
        }
        if (error != NULL) {
            *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadInvalidFileNameError userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Failed to retrieve file system path representation from destination %@", destination] }];
        }
        return NO;
    }
    
    sourcePaths[0] = pathBuffer;
    fts = fts_open(sourcePaths, FTS_PHYSICAL | FTS_NOCHDIR, compareFiles);
    if (!fts) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"fts_open failed on destination: %@", @(strerror(errno))] }];
        }
        return NO;
    }


    while ((ent = fts_read(fts))) {
        if (ent->fts_info != FTS_F && ent->fts_info != FTS_SL && ent->fts_info != FTS_D) {
            continue;
        }

        NSString *key = pathRelativeToDirectory(destination, stringWithFileSystemRepresentation(ent->fts_path));
        if (![key length]) {
            continue;
        }

        NSDictionary *info = infoForFile(ent);
        if (!info) {
            if (verbose) {
                fprintf(stderr, "\n");
            }
            if (error != NULL) {
                *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadUnknownError userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Failed to retrieve info from file %@", @(ent->fts_path)] }];
            }
            return NO;
        }
        
        // We should validate permissions and ACLs even if we don't store the info in the diff in the case of ACLs,
        // or in the case of permissions if the patch version is 1
        
        // We should also not allow files with code signed extended attributes since Apple doesn't recommend inserting these
        // inside an application, and since we don't preserve extended attribitutes anyway
        
        mode_t permissions = [info[INFO_PERMISSIONS_KEY] unsignedShortValue];
        if (!IS_VALID_PERMISSIONS(permissions)) {
            if (verbose) {
                fprintf(stderr, "\n");
            }
            if (error != NULL) {
                *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadUnknownError userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Invalid file permissions after-tree on file %@ (only permissions with modes 0755 and 0644 are supported)", @(ent->fts_path)] }];
            }
            return NO;
        }
        
        if (aclExists(ent)) {
            if (verbose) {
                fprintf(stderr, "\n");
            }
            if (error != NULL) {
                *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadUnknownError userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Diffing ACLs are not supported. Detected ACL in after-tree on file %@", @(ent->fts_path)] }];
            }
            return NO;
        }
        
        if (codeSignatureExtendedAttributeExists(ent)) {
            if (verbose) {
                fprintf(stderr, "\n");
            }
            if (error != NULL) {
                *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadUnknownError userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Diffing code signed extended attributes are not supported. Detected extended attribute in after-tree on file %@", @(ent->fts_path)] }];
            }
            return NO;
        }
        
        NSDictionary *oldInfo = originalTreeState[key];

        if ([info isEqual:oldInfo]) {
            [newTreeState removeObjectForKey:key];
        } else {
            newTreeState[key] = info;
            
            if (oldInfo && [oldInfo[INFO_TYPE_KEY] unsignedShortValue] == FTS_D && [info[INFO_TYPE_KEY] unsignedShortValue] != FTS_D) {
                NSArray *parentPathComponents = key.pathComponents;

                for (NSString *childPath in originalTreeState) {
                    NSArray *childPathComponents = childPath.pathComponents;
                    if (childPathComponents.count > parentPathComponents.count &&
                        [parentPathComponents isEqualToArray:[childPathComponents subarrayWithRange:NSMakeRange(0, parentPathComponents.count)]]) {
                        [newTreeState removeObjectForKey:childPath];
                    }
                }
            }
        }
    }
    fts_close(fts);

    NSString *afterHash = hashOfTreeWithVersion(destination, majorVersion);
    if (!afterHash) {
        if (verbose) {
            fprintf(stderr, "\n");
        }
        if (error != NULL) {
            *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadUnknownError userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Failed to generate hash for tree %@", destination] }];
        }
        return NO;
    }
    
    if (verbose) {
        fprintf(stderr, "\nGenerating delta...");
    }

    NSString *temporaryFile = temporaryPatchFile(patchFile);
    xar_t x = xar_open([temporaryFile fileSystemRepresentation], WRITE);
    if (!x) {
        if (verbose) {
            fprintf(stderr, "\n");
        }
        if (error != NULL) {
            *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteUnknownError userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Failed to write to %@", temporaryFile] }];
        }
        return NO;
    }
    
    xar_opt_set(x, XAR_OPT_COMPRESSION, "bzip2");
    
    xar_subdoc_t attributes = xar_subdoc_new(x, BINARY_DELTA_ATTRIBUTES_KEY);
    
    xar_subdoc_prop_set(attributes, MAJOR_DIFF_VERSION_KEY, [[NSString stringWithFormat:@"%u", majorVersion] UTF8String]);
    xar_subdoc_prop_set(attributes, MINOR_DIFF_VERSION_KEY, [[NSString stringWithFormat:@"%u", minorVersion] UTF8String]);
    
    // Version 1 patches don't have a major or minor version field, so we need to differentiate between the hash keys
    const char *beforeHashKey =
        MAJOR_VERSION_IS_AT_LEAST(majorVersion, SUBeigeMajorVersion) ? BEFORE_TREE_SHA1_KEY : BEFORE_TREE_SHA1_OLD_KEY;
    const char *afterHashKey =
        MAJOR_VERSION_IS_AT_LEAST(majorVersion, SUBeigeMajorVersion) ? AFTER_TREE_SHA1_KEY : AFTER_TREE_SHA1_OLD_KEY;
    
    xar_subdoc_prop_set(attributes, beforeHashKey, [beforeHash UTF8String]);
    xar_subdoc_prop_set(attributes, afterHashKey, [afterHash UTF8String]);

    NSOperationQueue *deltaQueue = [[NSOperationQueue alloc] init];
    NSMutableArray *deltaOperations = [NSMutableArray array];

    // Sort the keys by preferring the ones from the original tree to appear first
    // We want to enforce deleting before extracting in the case paths differ only by case
    NSArray *keys = [[newTreeState allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSString *key1, NSString *key2) {
        NSComparisonResult insensitiveCompareResult = [key1 caseInsensitiveCompare:key2];
        if (insensitiveCompareResult != NSOrderedSame) {
            return insensitiveCompareResult;
        }

        return originalTreeState[key1] ? NSOrderedAscending : NSOrderedDescending;
    }];
    for (NSString* key in keys) {
        id value = [newTreeState valueForKey:key];

        if ([value isEqual:[NSNull null]]) {
            xar_file_t newFile = xar_add_frombuffer(x, 0, [key fileSystemRepresentation], (char *)"", 1);
            assert(newFile);
            xar_prop_set(newFile, DELETE_KEY, "true");
            
            if (verbose) {
                fprintf(stderr, "\n❌  %s %s", VERBOSE_REMOVED, [key fileSystemRepresentation]);
            }
            continue;
        }

        NSDictionary *originalInfo = originalTreeState[key];
        NSDictionary *newInfo = newTreeState[key];
        if (shouldSkipDeltaCompression(originalInfo, newInfo)) {
            if (MAJOR_VERSION_IS_AT_LEAST(majorVersion, SUBeigeMajorVersion) && shouldSkipExtracting(originalInfo, newInfo)) {
                if (shouldChangePermissions(originalInfo, newInfo)) {
                    xar_file_t newFile = xar_add_frombuffer(x, 0, [key fileSystemRepresentation], (char *)"", 1);
                    assert(newFile);
                    xar_prop_set(newFile, MODIFY_PERMISSIONS_KEY, [[NSString stringWithFormat:@"%u", [newInfo[INFO_PERMISSIONS_KEY] unsignedShortValue]] UTF8String]);
                    
                    if (verbose) {
                        fprintf(stderr, "\n👮  %s %s (0%o -> 0%o)", VERBOSE_MODIFIED, [key fileSystemRepresentation], [originalInfo[INFO_PERMISSIONS_KEY] unsignedShortValue], [newInfo[INFO_PERMISSIONS_KEY] unsignedShortValue]);
                    }
                }
            } else {
                NSString *path = [destination stringByAppendingPathComponent:key];
                xar_file_t newFile = xar_add_frompath(x, 0, [key fileSystemRepresentation], [path fileSystemRepresentation]);
                assert(newFile);
                
                if (shouldDeleteThenExtract(originalInfo, newInfo)) {
                    if (MAJOR_VERSION_IS_AT_LEAST(majorVersion, SUBeigeMajorVersion)) {
                        xar_prop_set(newFile, DELETE_KEY, "true");
                    } else {
                        xar_prop_set(newFile, DELETE_THEN_EXTRACT_OLD_KEY, "true");
                    }
                }
                
                if (MAJOR_VERSION_IS_AT_LEAST(majorVersion, SUBeigeMajorVersion)) {
                    xar_prop_set(newFile, EXTRACT_KEY, "true");
                }
                
                if (verbose) {
                    if (originalInfo) {
                        fprintf(stderr, "\n✏️  %s %s", VERBOSE_UPDATED, [key fileSystemRepresentation]);
                    } else {
                        fprintf(stderr, "\n✅  %s %s", VERBOSE_ADDED, [key fileSystemRepresentation]);
                    }
                }
            }
        } else {
            NSNumber *permissions =
                (MAJOR_VERSION_IS_AT_LEAST(majorVersion, SUBeigeMajorVersion) && shouldChangePermissions(originalInfo, newInfo)) ?
                newInfo[INFO_PERMISSIONS_KEY] :
                nil;
            CreateBinaryDeltaOperation *operation = [[CreateBinaryDeltaOperation alloc] initWithRelativePath:key oldTree:source newTree:destination oldPermissions:originalInfo[INFO_PERMISSIONS_KEY] newPermissions:permissions];
            [deltaQueue addOperation:operation];
            [deltaOperations addObject:operation];
        }
    }

    [deltaQueue waitUntilAllOperationsAreFinished];

    for (CreateBinaryDeltaOperation *operation in deltaOperations) {
        NSString *resultPath = [operation resultPath];
        if (!resultPath) {
            if (verbose) {
                fprintf(stderr, "\n");
            }
            if (error != NULL) {
                *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteUnknownError userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Failed to create patch from source %@ and destination %@", operation.relativePath, resultPath] }];
            }
            return NO;
        }
        
        if (verbose) {
            fprintf(stderr, "\n🔨  %s %s", VERBOSE_DIFFED, [[operation relativePath] fileSystemRepresentation]);
        }
        
        xar_file_t newFile = xar_add_frompath(x, 0, [[operation relativePath] fileSystemRepresentation], [resultPath fileSystemRepresentation]);
        assert(newFile);
        xar_prop_set(newFile, BINARY_DELTA_KEY, "true");
        unlink([resultPath fileSystemRepresentation]);
        
        if (operation.permissions) {
            xar_prop_set(newFile, MODIFY_PERMISSIONS_KEY, [[NSString stringWithFormat:@"%u", [operation.permissions unsignedShortValue]] UTF8String]);
            
            if (verbose) {
                fprintf(stderr, "\n👮  %s %s (0%o -> 0%o)", VERBOSE_MODIFIED, [[operation relativePath] fileSystemRepresentation], operation.oldPermissions.unsignedShortValue, operation.permissions.unsignedShortValue);
            }
        }
    }

    xar_close(x);

    unlink([patchFile fileSystemRepresentation]);
    link([temporaryFile fileSystemRepresentation], [patchFile fileSystemRepresentation]);
    unlink([temporaryFile fileSystemRepresentation]);
    
    if (verbose) {
        fprintf(stderr, "\nDone!\n");
    }

    return YES;
}
