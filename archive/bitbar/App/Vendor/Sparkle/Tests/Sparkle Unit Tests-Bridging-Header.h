//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#import "SUUnarchiver.h"
#import "SUPipedUnarchiver.h"
#import "SUBinaryDeltaCommon.h"
#import "SUFileManager.h"
#import "SUAppcast.h"
#import "SUAppcastItem.h"
#import "SUBasicUpdateDriver.h"
#import "SUVersionComparisonProtocol.h"
#import "SUStandardVersionComparator.h"

// Duplicated to avoid exporting a private symbol from SUFileManager
static const char *SUAppleQuarantineIdentifier = "com.apple.quarantine";

@interface SUFileManager (Private)

- (BOOL)_acquireAuthorizationWithError:(NSError *__autoreleasing *)error;

- (BOOL)_itemExistsAtURL:(NSURL *)fileURL;
- (BOOL)_itemExistsAtURL:(NSURL *)fileURL isDirectory:(BOOL *)isDirectory;

@end

@interface SUBasicUpdateDriver (Private)

+ (SUAppcastItem *)bestItemFromAppcastItems:(NSArray *)appcastItems getDeltaItem:(SUAppcastItem * __autoreleasing *)deltaItem withHostVersion:(NSString *)hostVersion comparator:(id<SUVersionComparison>)comparator;

@end


@interface SUAppcast (Private)
- (NSArray *)parseAppcastItemsFromXMLFile:(NSURL *)appcastFile error:(NSError *__autoreleasing*)errorp;
@end

