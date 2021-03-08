//
//  SUSystemProfiler.m
//  Sparkle
//
//  Created by Andy Matuschak on 12/22/07.
//  Copyright 2007 Andy Matuschak. All rights reserved.
//  Adapted from Sparkle+, by Tom Harrington.
//

#import <Cocoa/Cocoa.h>
#import "SUSystemProfiler.h"

#import "SUHost.h"
#import "SUOperatingSystem.h"
#include <sys/sysctl.h>

static NSString *const SUSystemProfilerApplicationNameKey = @"appName";
static NSString *const SUSystemProfilerApplicationVersionKey = @"appVersion";
static NSString *const SUSystemProfilerCPU64bitKey = @"cpu64bit";
static NSString *const SUSystemProfilerCPUCountKey = @"ncpu";
static NSString *const SUSystemProfilerCPUFrequencyKey = @"cpuFreqMHz";
static NSString *const SUSystemProfilerCPUTypeKey = @"cputype";
static NSString *const SUSystemProfilerCPUSubtypeKey = @"cpusubtype";
static NSString *const SUSystemProfilerHardwareModelKey = @"model";
static NSString *const SUSystemProfilerMemoryKey = @"ramMB";
static NSString *const SUSystemProfilerOperatingSystemVersionKey = @"osVersion";
static NSString *const SUSystemProfilerPreferredLanguageKey = @"lang";

@implementation SUSystemProfiler
+ (SUSystemProfiler *)sharedSystemProfiler
{
    static SUSystemProfiler *sharedSystemProfiler = nil;
    if (!sharedSystemProfiler) {
        sharedSystemProfiler = [[self alloc] init];
    }
    return sharedSystemProfiler;
}

- (NSDictionary *)modelTranslationTable
{
    // Use explicit class to use the correct bundle even when subclassed
    NSString *path = [[NSBundle bundleForClass:[SUSystemProfiler class]] pathForResource:@"SUModelTranslation" ofType:@"plist"];
    return [[NSDictionary alloc] initWithContentsOfFile:path];
}

- (NSMutableArray *)systemProfileArrayForHost:(SUHost *)host
{
    NSDictionary *modelTranslation = [self modelTranslationTable];

    // Gather profile information and append it to the URL.
    NSMutableArray *profileArray = [NSMutableArray array];
    NSArray *profileDictKeys = @[@"key", @"displayKey", @"value", @"displayValue"];
    int error = 0;
    int value = 0;
    size_t length = sizeof(value);

    // OS version
    NSString *currentSystemVersion = [SUOperatingSystem systemVersionString];
    if (currentSystemVersion != nil) {
        [profileArray addObject:[NSDictionary dictionaryWithObjects:@[SUSystemProfilerOperatingSystemVersionKey, @"OS Version", currentSystemVersion, currentSystemVersion] forKeys:profileDictKeys]];
    }

    // CPU type (decoder info for values found here is in mach/machine.h)
    error = sysctlbyname("hw.cputype", &value, &length, NULL, 0);
    int cpuType = -1;
    if (error == 0) {
        cpuType = value;
        NSString *visibleCPUType;
        switch (value) {
            case CPU_TYPE_ARM:      visibleCPUType = @"ARM";        break;
			case CPU_TYPE_X86:		visibleCPUType = @"Intel";		break;
			case CPU_TYPE_POWERPC:	visibleCPUType = @"PowerPC";	break;
			default:				visibleCPUType = @"Unknown";	break;
        }
        [profileArray addObject:[NSDictionary dictionaryWithObjects:@[SUSystemProfilerCPUTypeKey, @"CPU Type", @(value), visibleCPUType] forKeys:profileDictKeys]];
    }
    error = sysctlbyname("hw.cpu64bit_capable", &value, &length, NULL, 0);
    if (error != 0) {
        error = sysctlbyname("hw.optional.x86_64", &value, &length, NULL, 0); //x86 specific
    }
    if (error != 0) {
        error = sysctlbyname("hw.optional.64bitops", &value, &length, NULL, 0); //PPC specific
    }

    BOOL is64bit = NO;

    if (error == 0) {
        is64bit = value == 1;
        [profileArray addObject:[NSDictionary dictionaryWithObjects:@[SUSystemProfilerCPU64bitKey, @"CPU is 64-Bit?", @(is64bit), is64bit ? @"Yes" : @"No"] forKeys:profileDictKeys]];
    }
    error = sysctlbyname("hw.cpusubtype", &value, &length, NULL, 0);
    if (error == 0) {
        NSString *visibleCPUSubType;
        if (cpuType == 7) {
            // Intel
            // TODO: other Intel processors, like Core i7, i5, i3, Xeon?
            visibleCPUSubType = is64bit ? @"Intel Core 2" : @"Intel Core"; // If anyone knows how to tell a Core Duo from a Core Solo, please email tph@atomicbird.com
        } else if (cpuType == 18) {
            // PowerPC
            switch (value) {
				case 9:					visibleCPUSubType=@"G3";	break;
				case 10:	case 11:	visibleCPUSubType=@"G4";	break;
				case 100:				visibleCPUSubType=@"G5";	break;
				default:				visibleCPUSubType=@"Other";	break;
            }
        } else {
            visibleCPUSubType = @"Other";
        }
        [profileArray addObject:[NSDictionary dictionaryWithObjects:@[SUSystemProfilerCPUSubtypeKey, @"CPU Subtype", @(value), visibleCPUSubType] forKeys:profileDictKeys]];
    }
    error = sysctlbyname("hw.model", NULL, &length, NULL, 0);
    if (error == 0) {
        char *cpuModel = (char *)malloc(sizeof(char) * length);
        if (cpuModel != NULL) {
            error = sysctlbyname("hw.model", cpuModel, &length, NULL, 0);
            if (error == 0) {
                NSString *rawModelName = @(cpuModel);
                NSString *visibleModelName = [modelTranslation objectForKey:rawModelName];
                if (visibleModelName == nil) {
                    visibleModelName = rawModelName;
                }
                [profileArray addObject:[NSDictionary dictionaryWithObjects:@[SUSystemProfilerHardwareModelKey, @"Mac Model", rawModelName, visibleModelName] forKeys:profileDictKeys]];
            }
            free(cpuModel);
        }
    }

    // Number of CPUs
    error = sysctlbyname("hw.ncpu", &value, &length, NULL, 0);
    if (error == 0) {
        [profileArray addObject:[NSDictionary dictionaryWithObjects:@[SUSystemProfilerCPUCountKey, @"Number of CPUs", @(value), @(value)] forKeys:profileDictKeys]];
    }

    // User preferred language
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defs objectForKey:@"AppleLanguages"];
    if ([languages count] > 0) {
        [profileArray addObject:[NSDictionary dictionaryWithObjects:@[SUSystemProfilerPreferredLanguageKey, @"Preferred Language", [languages objectAtIndex:0], [languages objectAtIndex:0]] forKeys:profileDictKeys]];
    }

    // Application sending the request
    NSString *appName = [host name];
    if (appName) {
        [profileArray addObject:[NSDictionary dictionaryWithObjects:@[SUSystemProfilerApplicationNameKey, @"Application Name", appName, appName] forKeys:profileDictKeys]];
    }
    NSString *appVersion = [host version];
    if (appVersion) {
        [profileArray addObject:[NSDictionary dictionaryWithObjects:@[SUSystemProfilerApplicationVersionKey, @"Application Version", appVersion, appVersion] forKeys:profileDictKeys]];
    }

    // Number of displays?

    // CPU speed
    unsigned long hz;
    size_t hz_size = sizeof(unsigned long);
    if (sysctlbyname("hw.cpufrequency", &hz, &hz_size, NULL, 0) == 0) {
        unsigned long mhz = hz / 1000000;
        [profileArray addObject:[NSDictionary dictionaryWithObjects:@[SUSystemProfilerCPUFrequencyKey, @"CPU Speed (MHz)", @(mhz), @(mhz / 1000.)] forKeys:profileDictKeys]];
    }

    // amount of RAM
    unsigned long bytes;
    size_t bytes_size = sizeof(unsigned long);
    if (sysctlbyname("hw.memsize", &bytes, &bytes_size, NULL, 0) == 0) {
        double megabytes = bytes / (1024. * 1024.);
        [profileArray addObject:[NSDictionary dictionaryWithObjects:@[SUSystemProfilerMemoryKey, @"Memory (MB)", @(megabytes), @(megabytes)] forKeys:profileDictKeys]];
    }

    return profileArray;
}

@end
