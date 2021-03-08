//
//  SUGuidedPackageInstaller.m
//  Sparkle
//
//  Created by Graham Miln on 14/05/2010.
//  Copyright 2010 Dragon Systems Software Limited. All rights reserved.
//

#import "SUGuidedPackageInstaller.h"
#import "SUFileManager.h"

@implementation SUGuidedPackageInstaller

+ (void)performInstallationToPath:(NSString *)destinationPath fromPath:(NSString *)packagePath host:(SUHost *)__unused host fileOperationToolPath:(NSString *)fileOperationToolPath versionComparator:(id<SUVersionComparison>)__unused comparator completionHandler:(void (^)(NSError *))completionHandler
{
    SUParameterAssert(packagePath);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        SUFileManager *fileManager = [SUFileManager fileManagerWithAuthorizationToolPath:fileOperationToolPath];
        
        NSError *error = nil;
        BOOL validInstallation = [fileManager executePackageAtURL:[NSURL fileURLWithPath:packagePath] error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self finishInstallationToPath:destinationPath
                                withResult:validInstallation
                                     error:error
                         completionHandler:completionHandler];
            
        });
    });
}

@end
