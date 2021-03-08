//
//  SUBinaryDeltaCommon.m
//  Sparkle
//
//  Created by Mark Rowe on 2009-06-01.
//  Copyright 2009 Mark Rowe. All rights reserved.
//

#include "SUBinaryDeltaCommon.h"
#import "SUFileManager.h"
#include <CommonCrypto/CommonDigest.h>
#include <Foundation/Foundation.h>
#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/param.h>
#include <sys/stat.h>
#include <xar/xar.h>

int compareFiles(const FTSENT **a, const FTSENT **b)
{
    return strcoll((*a)->fts_name, (*b)->fts_name);
}

NSString *pathRelativeToDirectory(NSString *directory, NSString *path)
{
    NSUInteger directoryLength = [directory length];
    if ([path hasPrefix:directory])
        return [path substringFromIndex:directoryLength];

    return path;
}

NSString *stringWithFileSystemRepresentation(const char *input) {
    return [[NSFileManager defaultManager] stringWithFileSystemRepresentation:input length:strlen(input)];
}

SUBinaryDeltaMinorVersion latestMinorVersionForMajorVersion(SUBinaryDeltaMajorVersion majorVersion)
{
    switch (majorVersion) {
        case SUAzureMajorVersion:
            return SUAzureMinorVersion;
        case SUBeigeMajorVersion:
            return SUBeigeMinorVersion;
    }
    return (SUBinaryDeltaMinorVersion)0;
}

NSString *temporaryFilename(NSString *base)
{
    NSString *template = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.XXXXXXXXXX", base]];
    NSMutableData *data = [NSMutableData data];
    [data appendBytes:template.fileSystemRepresentation length:strlen(template.fileSystemRepresentation) + 1];

    char *buffer = data.mutableBytes;
    int fd = mkstemp(buffer);
    if (fd == -1) {
        perror("mkstemp");
        return nil;
    }

    if (close(fd) != 0) {
        perror("close");
        return nil;
    }

    return stringWithFileSystemRepresentation(buffer);
}

NSString *temporaryDirectory(NSString *base)
{
    NSString *template = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.XXXXXXXXXX", base]];
    NSMutableData *data = [NSMutableData data];
    [data appendBytes:template.fileSystemRepresentation length:strlen(template.fileSystemRepresentation) + 1];
    
    char *buffer = data.mutableBytes;
    char *templateResult = mkdtemp(buffer);
    if (templateResult == NULL) {
        perror("mkdtemp");
        return nil;
    }
    
    return stringWithFileSystemRepresentation(templateResult);
}

static void _hashOfBuffer(unsigned char *hash, const char* buffer, ssize_t bufferLength)
{
    assert(bufferLength >= 0 && bufferLength <= UINT32_MAX);
    CC_SHA1_CTX hashContext;
    CC_SHA1_Init(&hashContext);
    CC_SHA1_Update(&hashContext, buffer, (CC_LONG)bufferLength);
    CC_SHA1_Final(hash, &hashContext);
}

static BOOL _hashOfFileContents(unsigned char* hash, FTSENT *ent)
{
    if (ent->fts_info == FTS_SL) {
        char linkDestination[MAXPATHLEN + 1];
        ssize_t linkDestinationLength = readlink(ent->fts_path, linkDestination, MAXPATHLEN);
        if (linkDestinationLength < 0) {
            perror("readlink");
            return NO;
        }

        _hashOfBuffer(hash, linkDestination, linkDestinationLength);
    } else if (ent->fts_info == FTS_F) {
        int fileDescriptor = open(ent->fts_path, O_RDONLY);
        if (fileDescriptor == -1) {
            perror("open");
            return NO;
        }

        ssize_t fileSize = ent->fts_statp->st_size;
        if (fileSize == 0) {
            _hashOfBuffer(hash, NULL, 0);
        } else {
            void *buffer = mmap(0, (size_t)fileSize, PROT_READ, MAP_FILE | MAP_PRIVATE, fileDescriptor, 0);
            if (buffer == (void*)-1) {
                close(fileDescriptor);
                perror("mmap");
                return NO;
            }
            
            _hashOfBuffer(hash, buffer, fileSize);
            munmap(buffer, (size_t)fileSize);
        }
        close(fileDescriptor);
    } else if (ent->fts_info == FTS_D) {
        memset(hash, 0xdd, CC_SHA1_DIGEST_LENGTH);
    } else {
        return NO;
    }
    return YES;
}

NSData *hashOfFileContents(FTSENT *ent)
{
    unsigned char fileHash[CC_SHA1_DIGEST_LENGTH];
    if (!_hashOfFileContents(fileHash, ent)) {
        return nil;
    }
    return [NSData dataWithBytes:fileHash length:CC_SHA1_DIGEST_LENGTH];
}

NSString *hashOfTreeWithVersion(NSString *path, uint16_t majorVersion)
{
    char pathBuffer[PATH_MAX] = {0};
    if (![path getFileSystemRepresentation:pathBuffer maxLength:sizeof(pathBuffer)]) {
        return nil;
    }

    char * const sourcePaths[] = {pathBuffer, 0};
    FTS *fts = fts_open(sourcePaths, FTS_PHYSICAL | FTS_NOCHDIR, compareFiles);
    if (!fts) {
        perror("fts_open");
        return nil;
    }

    CC_SHA1_CTX hashContext;
    CC_SHA1_Init(&hashContext);

    FTSENT *ent = 0;
    while ((ent = fts_read(fts))) {
        if (ent->fts_info != FTS_F && ent->fts_info != FTS_SL && ent->fts_info != FTS_D)
            continue;
        
        if (ent->fts_info == FTS_D && !MAJOR_VERSION_IS_AT_LEAST(majorVersion, SUBeigeMajorVersion)) {
            continue;
        }
        
        NSString *relativePath = pathRelativeToDirectory(path, stringWithFileSystemRepresentation(ent->fts_path));
        if (relativePath.length == 0)
            continue;

        unsigned char fileHash[CC_SHA1_DIGEST_LENGTH];
        if (!_hashOfFileContents(fileHash, ent)) {
            return nil;
        }
        CC_SHA1_Update(&hashContext, fileHash, sizeof(fileHash));

        const char *relativePathBytes = [relativePath fileSystemRepresentation];
        CC_SHA1_Update(&hashContext, relativePathBytes, (CC_LONG)strlen(relativePathBytes));
        
        if (MAJOR_VERSION_IS_AT_LEAST(majorVersion, SUBeigeMajorVersion)) {
            uint16_t mode = ent->fts_statp->st_mode;
            uint16_t type = ent->fts_info;
            uint16_t permissions = mode & PERMISSION_FLAGS;
            
            CC_SHA1_Update(&hashContext, &type, sizeof(type));
            CC_SHA1_Update(&hashContext, &permissions, sizeof(permissions));
        }
    }
    fts_close(fts);

    unsigned char hash[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1_Final(hash, &hashContext);

    char hexHash[CC_SHA1_DIGEST_LENGTH * 2 + 1];
    size_t i;
    for (i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        sprintf(hexHash + i * 2, "%02x", hash[i]);

    return @(hexHash);
}

extern NSString *hashOfTree(NSString *path)
{
    return hashOfTreeWithVersion(path, LATEST_DELTA_DIFF_MAJOR_VERSION);
}

BOOL removeTree(NSString *path)
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // Don't use fileExistsForPath: because it will try to follow symbolic links
    if (![fileManager attributesOfItemAtPath:path error:nil]) {
        return YES;
    }
    return [fileManager removeItemAtPath:path error:nil];
}

BOOL copyTree(NSString *source, NSString *dest)
{
    return [[SUFileManager defaultManager] copyItemAtURL:[NSURL fileURLWithPath:source] toURL:[NSURL fileURLWithPath:dest] error:NULL];
}

BOOL modifyPermissions(NSString *path, mode_t desiredPermissions)
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *attributes = [fileManager attributesOfItemAtPath:path error:nil];
    if (!attributes) {
        return NO;
    }
    NSNumber *permissions = [attributes objectForKey:NSFilePosixPermissions];
    if (!permissions) {
        return NO;
    }
    mode_t newMode = ([permissions unsignedShortValue] & ~PERMISSION_FLAGS) | desiredPermissions;
    int (*changeModeFunc)(const char *, mode_t) = [[attributes objectForKey:NSFileType] isEqualToString:NSFileTypeSymbolicLink] ? lchmod : chmod;
    if (changeModeFunc([path fileSystemRepresentation], newMode) != 0) {
        return NO;
    }
    return YES;
}
