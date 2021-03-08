## NSString+Emojize
#### A category on NSString to turn codes from [Emoji Cheat Sheet](http://www.emoji-cheat-sheet.com/) into Unicode emoji characters.

## Getting Started

In order to use NSString+Emojize, you'll want to add the entirety of the `NSString+Emojize` directory to your project. To get started, simply:

```objective-c
#import "NSString+Emojize.h"
```

```objective-c
NSString *emojiString = @"This comment has an emoji :mushroom:";
NSLog(@"%@", [emojiString emojizedString]);
```

---

## Methods
```objective-c
- (NSString *)emojizedString;
+ (NSString *)emojizedStringWithString:(NSString *)aString;
```

---

## iOS Support
NSString+Emojize is tested on iOS 5 and up. Older versions of iOS may work but are not currently supported.

## ARC
NSString+Emojize uses ARC. If you are including NSString+Emojize in a project that **does not** use [Automatic Reference Counting (ARC)](http://developer.apple.com/library/ios/#releasenotes/ObjectiveC/RN-TransitioningToARC/Introduction/Introduction.html), you will need to set the `-fobjc-arc` compiler flag on all of the NSString+Emojize source files. To do this in Xcode, go to your active target and select the "Build Phases" tab. Now select all NSString+Emojize source files, press Enter, insert `-fobjc-arc` and then "Done" to enable ARC for NSString+Emojize.
