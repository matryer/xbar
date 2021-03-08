#AHProxySettings
### Simple lib to access the OSX system proxy settings 

```Objective-c
AHProxySettings  *settings = [[AHProxySettings alloc] init];
    
NSLog(@"%@",settings.HTTPProxy.exportString);
NSLog(@"%@",settings.HTTPSProxy.exportString);
NSLog(@"%@",settings.FTProxy.exportString);
NSLog(@"%@",settings.SOCKSProxy.exportString);
NSLog(@"%@",settings.autoDetectedProxies);

// By default HTTP(S) and FTP proxy objects will be 
// populated with a proxy returned from a .PAC / WPAD request.
// To disable this behavior

settings.useAutoDetectAsFailover = NO;
```
But the reason this project was started was to get the system proxy values into an NSTask, so there's a category for that to.

```
#import "NSTask+useSystemProxies.h"

NSTask *task = [NSTask alloc] init];
task.launchPath = @"/usr/bin/curl"
task.arguments = @[ @"-k", _testURL.stringValue ];

[task useSystemProxies];
// This is equivalent to 
// export HTTP_PROXY = ...
// export HTTPS_PROXY = ...
// export FTP_PROXY = ...
// export NO_PROXY = ...
// based on your system settings

// or to dynamically determine if a proxy 
// is needed based on a PAC file
[task useSystemProxiesForDestination:@"github.com"];

[task launch];

// ... then do what you will with the results ... //

```
if not using CocoaPods, make sure to include `-ObjC` in you build setting's other linker flags so the category isn't optimized out.