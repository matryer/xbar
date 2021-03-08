//
//  SUPlainInstaller.h
//  Sparkle
//
//  Created by Andy Matuschak on 4/10/08.
//  Copyright 2008 Andy Matuschak. All rights reserved.
//

#ifndef SUPLAININSTALLER_H
#define SUPLAININSTALLER_H

#import <Foundation/Foundation.h>

#import "SUUpdater.h"

#import "SUAppcast.h"
#import "SUAppcastItem.h"
#import "SUVersionComparisonProtocol.h"
#import "SUInstaller.h"
#import "SUVersionComparisonProtocol.h"

@class SUHost;

@interface SUPlainInstaller : SUInstaller

+ (void)performInstallationToPath:(NSString *)installationPath fromPath:(NSString *)path host:(SUHost *)host fileOperationToolPath:(NSString *)fileOperationToolPath versionComparator:(id<SUVersionComparison>)comparator completionHandler:(void (^)(NSError *))completionHandler;

@end

#endif
