//
//  SUUnarchiver.m
//  Sparkle
//
//  Created by Andy Matuschak on 3/16/06.
//  Copyright 2006 Andy Matuschak. All rights reserved.
//


#import "SUUpdater.h"

#import "SUAppcast.h"
#import "SUAppcastItem.h"
#import "SUVersionComparisonProtocol.h"
#import "SUUnarchiver.h"
#import "SUUnarchiver_Private.h"

@implementation SUUnarchiver

@synthesize archivePath;
@synthesize updateHostBundlePath;
@synthesize delegate;
@synthesize decryptionPassword;

+ (SUUnarchiver *)unarchiverForPath:(NSString *)path updatingHostBundlePath:(NSString *)hostPath withPassword:(NSString *)decryptionPassword
{
    for (id current in [self unarchiverImplementations]) {
        if ([current canUnarchivePath:path]) {
            return [[current alloc] initWithPath:path hostBundlePath:hostPath password:decryptionPassword];
        }
    }
    return nil;
}

- (NSString *)description { return [NSString stringWithFormat:@"%@ <%@>", [self class], self.archivePath]; }

- (void)start
{
    // No-op
}

- (instancetype)initWithPath:(NSString *)path hostBundlePath:(NSString *)hostPath password:(NSString *)password
{
    if ((self = [super init]))
    {
        archivePath = [path copy];
        updateHostBundlePath = hostPath;
        decryptionPassword = password;
    }
    return self;
}

+ (BOOL)canUnarchivePath:(NSString *)__unused path
{
    return NO;
}

- (void)notifyDelegateOfProgress:(double)progress
{
    if ([self.delegate respondsToSelector:@selector(unarchiver:extractedProgress:)]) {
        [self.delegate unarchiver:self extractedProgress:progress];
    }
}

- (void)notifyDelegateOfSuccess
{
    if ([self.delegate respondsToSelector:@selector(unarchiverDidFinish:)]) {
        [self.delegate unarchiverDidFinish:self];
    }
}

- (void)notifyDelegateOfFailure
{
    if ([self.delegate respondsToSelector:@selector(unarchiverDidFail:)]) {
        [self.delegate unarchiverDidFail:self];
    }
}

static NSMutableArray *gUnarchiverImplementations;

+ (void)registerImplementation:(Class)implementation
{
    if (!gUnarchiverImplementations) {
        gUnarchiverImplementations = [[NSMutableArray alloc] init];
    }
    [gUnarchiverImplementations addObject:implementation];
}

+ (NSArray *)unarchiverImplementations
{
    return [NSArray arrayWithArray:gUnarchiverImplementations];
}

@end
