//
//  SUPipedUnarchiver.m
//  Sparkle
//
//  Created by Andy Matuschak on 6/16/08.
//  Copyright 2008 Andy Matuschak. All rights reserved.
//

#import "SUPipedUnarchiver.h"
#import "SUUnarchiver_Private.h"
#import "SULog.h"


@implementation SUPipedUnarchiver

+ (SEL)selectorConformingToTypeOfPath:(NSString *)path
{
    static NSDictionary *typeSelectorDictionary;
    if (!typeSelectorDictionary)
        typeSelectorDictionary = @{ @".zip": @"extractZIP",
                                    @".tar": @"extractTAR",
                                    @".tar.gz": @"extractTGZ",
                                    @".tgz": @"extractTGZ",
                                    @".tar.bz2": @"extractTBZ",
                                    @".tbz": @"extractTBZ",
                                    @".tar.xz": @"extractTXZ",
                                    @".txz": @"extractTXZ",
                                    @".tar.lzma": @"extractTXZ"};

    NSString *lastPathComponent = [path lastPathComponent];
	for (NSString *currentType in typeSelectorDictionary)
	{
        NSString *value = [typeSelectorDictionary objectForKey:currentType];
        assert(value);

		if ([currentType length] > [lastPathComponent length]) continue;
        if ([[lastPathComponent substringFromIndex:[lastPathComponent length] - [currentType length]] isEqualToString:currentType]) {
            return NSSelectorFromString(value);
        }
    }
    return NULL;
}

- (void)start
{
    [NSThread detachNewThreadSelector:[[self class] selectorConformingToTypeOfPath:self.archivePath] toTarget:self withObject:nil];
}

+ (BOOL)canUnarchivePath:(NSString *)path
{
    return ([self selectorConformingToTypeOfPath:path] != nil);
}

// This method abstracts the types that use a command line tool piping data from stdin.
- (void)extractArchivePipingDataToCommand:(NSString *)command args:(NSArray*)args
{
    // *** GETS CALLED ON NON-MAIN THREAD!!!
	@autoreleasepool {

        NSString *destination = [self.archivePath stringByDeletingLastPathComponent];
        
        SULog(@"Extracting using '%@' '%@' < '%@' '%@'", command, [args componentsJoinedByString:@"' '"], self.archivePath, destination);

        // Get the file size.
        NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:self.archivePath error:nil];
        NSUInteger expectedLength = [[attributes objectForKey:NSFileSize] unsignedIntegerValue];
        if (expectedLength > 0) {
            NSFileHandle *archiveInput = [NSFileHandle fileHandleForReadingAtPath:self.archivePath];

            NSPipe *pipe = [NSPipe pipe];
            NSFileHandle *archiveOutput = [pipe fileHandleForWriting];

            NSTask *task = [[NSTask alloc] init];
            [task setStandardInput:[pipe fileHandleForReading]];
            [task setStandardError:[NSFileHandle fileHandleWithStandardError]];
            [task setStandardOutput:[NSFileHandle fileHandleWithStandardOutput]];
            [task setLaunchPath:command];
            [task setArguments:[args arrayByAddingObject:destination]];
            [task launch];

            NSUInteger bytesRead = 0;
            do {
                NSData *data = [archiveInput readDataOfLength:256*1024];
                NSUInteger len = [data length];
                if (!len) {
                    break;
                }
                bytesRead += len;
                [archiveOutput writeData:data];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self notifyDelegateOfProgress:(double)bytesRead / (double)expectedLength];
                });
            }
            while(bytesRead < expectedLength);
            
            [archiveOutput closeFile];

            [task waitUntilExit];
            
            if ([task terminationStatus] == 0) {
                if (bytesRead == expectedLength) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self notifyDelegateOfSuccess];
                    });
                    return;
                } else {
                    SULog(@"Extraction failed, command '%@' got only %ld of %ld bytes", command, (long)bytesRead, (long)expectedLength);
                }
            } else {
                SULog(@"Extraction failed, command '%@' returned %d", command, [task terminationStatus]);
            }
        } else {
            SULog(@"Extraction failed, archive '%@' is empty", self.archivePath);
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [self notifyDelegateOfFailure];
        });
    }
}

- (void)extractTAR
{
    // *** GETS CALLED ON NON-MAIN THREAD!!!

    [self extractArchivePipingDataToCommand:@"/usr/bin/tar" args:@[@"-xC"]];
}

- (void)extractTGZ
{
    // *** GETS CALLED ON NON-MAIN THREAD!!!

    [self extractArchivePipingDataToCommand:@"/usr/bin/tar" args:@[@"-zxC"]];
}

- (void)extractTBZ
{
    // *** GETS CALLED ON NON-MAIN THREAD!!!

    [self extractArchivePipingDataToCommand:@"/usr/bin/tar" args:@[@"-jxC"]];
}

- (void)extractZIP
{
    // *** GETS CALLED ON NON-MAIN THREAD!!!

    [self extractArchivePipingDataToCommand:@"/usr/bin/ditto" args:@[@"-x",@"-k",@"-"]];
}

- (void)extractTXZ
{
    // *** GETS CALLED ON NON-MAIN THREAD!!!

    [self extractArchivePipingDataToCommand:@"/usr/bin/tar" args:@[@"-zxC"]];
}

+ (void)load
{
    [self registerImplementation:self];
}

@end
