//
//  SUOperatingSystem.h
//  Sparkle
//
//  Copyright © 2015 Sparkle Project. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SUOperatingSystem : NSObject

+ (NSOperatingSystemVersion)operatingSystemVersion;
+ (BOOL)isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion)version;
+ (NSString *)systemVersionString;

@end
