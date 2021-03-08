// AHProxySettings.m
//
// Copyright (c) 2014 Eldon Ahrold
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "AHProxySettings.h"
#import <SystemConfiguration/SystemConfiguration.h>

NSString *const kAHProxyExportHTTP = @"HTTP_PROXY";
NSString *const kAHProxyExportHTTPS = @"HTTPS_PROXY";
NSString *const kAHProxyExportFTP = @"FTP_PROXY";
NSString *const kAHProxyExportExceptions = @"NO_PROXY";
NSString *const kAHProxyExportSOCKS = @"ALL_PROXY";

NSString *const kNSProxyHTTP;
NSString *const kNSProxyHTTPS;

@interface AHProxy ()
@property (copy, nonatomic, readwrite) NSString *server;
@property (copy, nonatomic, readwrite) NSNumber *port;
@property (copy, nonatomic, readwrite) NSString *user;
@property (assign, nonatomic, readwrite) AHProxyType type;
@end

@implementation AHProxySettings {
    NSDictionary *_systemProxies;
    NSString *_pacFunction;
    BOOL _pacFileRetrievalFailed;
}

@synthesize autoDetectedProxies = _autoDetectedProxies;
@synthesize exceptionsList = _exceptionsList;

- (id)init {
    self = [super init];
    if (self) {
        _systemProxies = CFBridgingRelease(SCDynamicStoreCopyProxies(NULL));
        _useAutoDetectAsFailover = YES;
    }
    return self;
}

- (instancetype)initWithDestination:(NSString *)destURL {
    self = [self init];
    if (self) {
        _destinationURL = destURL;
    }
    return self;
}

- (AHProxy *)HTTPProxy {
    return [self proxyForType:@"HTTP"];
}

- (AHProxy *)HTTPSProxy {
    return [self proxyForType:@"HTTPS"];
}

- (AHProxy *)FTPProxy {
    return [self proxyForType:@"FTP"];
}

- (AHProxy *)SOCKSProxy {
    return [self proxyForType:@"SOCKS"];
}

- (NSArray *)autoDetectedProxies {
    if (_systemProxies[@"ProxyAutoConfigEnable"] ||
        _systemProxies[@"ProxyAutoDiscoveryEnable"]) {

        if (!_pacFunction && !_pacFileRetrievalFailed) {

            NSString *urlString = _systemProxies[@"ProxyAutoConfigURLString"];
            if (urlString && urlString.length > 0) {
                NSURL *pacFileURL = [NSURL URLWithString:urlString];

                NSURLRequest *req = [NSURLRequest
                     requestWithURL:pacFileURL
                        cachePolicy:
                            NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                    timeoutInterval:5.0];

                // Initialize our response and error objects
                NSHTTPURLResponse *resp;
                NSError *error = nil;

                // Get the PAC file data
                NSData *reqData =
                    [NSURLConnection sendSynchronousRequest:req
                                          returningResponse:&resp
                                                      error:&error];

                if (reqData && (![resp respondsToSelector:@selector(statusCode)] || resp.statusCode < 400)) {
                    _pacFunction =
                        [[NSString alloc] initWithData:reqData
                                              encoding:NSASCIIStringEncoding];
                } else {
                    _pacFileRetrievalFailed = YES;
                    NSLog(@"Error retrieving PAC file. %@",error ?
                          error.localizedDescription:@"");
                }
            }
        }

        if (_pacFunction && self.destinationURL) {
            CFErrorRef err;
            NSURL *url = [NSURL URLWithString:_destinationURL];

            NSArray *proxies = CFBridgingRelease(
                                                 CFNetworkCopyProxiesForAutoConfigurationScript(
                                                                                                (__bridge CFStringRef)(_pacFunction),
                                                                                                (__bridge CFURLRef)(url),
                                                                                                &err));
            if (err) {
                NSLog(@"%@", CFBridgingRelease(err));
            } else {
                NSMutableArray *workingProxies = [NSMutableArray new];

                for (NSDictionary *proxyDict in proxies) {
                    AHProxy *proxy = [[AHProxy alloc] init];
                    proxy.server =
                    proxyDict[@"kCFProxyHostNameKey"];
                    proxy.port =
                    proxyDict[@"kCFProxyPortNumberKey"];

                    if (proxy.server && proxy.port) {
                        [workingProxies addObject:proxy];
                    }
                }

                if (workingProxies.count) {
                    _autoDetectedProxies =
                    [NSArray arrayWithArray:workingProxies];
                }
            }
        }
    }
    return _autoDetectedProxies;
}

- (NSArray *)exceptionsList {
    _exceptionsList = _systemProxies[@"ExceptionsList"];
    return _exceptionsList;
}

- (NSString *)destinationURL {
    if (!_destinationURL) {
        _destinationURL = @"http://0.0.0.0";
    }
    return _destinationURL;
}

- (NSDictionary *)taskDictionary {
    NSMutableDictionary *exportDictionary =
        [[NSMutableDictionary alloc] initWithCapacity:5];

    AHProxy *httpProxy = self.HTTPProxy;
    if (httpProxy) {
        NSString *proxy = httpProxy.exportString;
        if (proxy) {
            [exportDictionary setObject:proxy forKey:kAHProxyExportHTTP];
            [exportDictionary setObject:proxy
                                 forKey:[kAHProxyExportHTTP lowercaseString]];
        }
    }

    AHProxy *httpsProxy = self.HTTPSProxy;
    if (httpsProxy) {
        NSString *proxy = httpsProxy.exportString;
        if (proxy) {
            [exportDictionary setObject:proxy forKey:kAHProxyExportHTTPS];
            [exportDictionary setObject:proxy
                                 forKey:[kAHProxyExportHTTPS lowercaseString]];
        }
    }

    AHProxy *socksProxy = self.SOCKSProxy;
    if (socksProxy) {
        NSString *proxy = socksProxy.exportString;
        if (proxy) {
            [exportDictionary setObject:proxy forKey:kAHProxyExportSOCKS];
            [exportDictionary setObject:proxy
                                 forKey:[kAHProxyExportSOCKS lowercaseString]];
        }
    }

    NSArray *autoDetectedProxies = self.autoDetectedProxies;
    if (autoDetectedProxies) {
        NSString *proxy = [[autoDetectedProxies firstObject] exportString];

        if (!httpProxy) {
            [exportDictionary setObject:proxy forKey:kAHProxyExportHTTP];
            [exportDictionary setObject:proxy
                                 forKey:[kAHProxyExportHTTP lowercaseString]];
        }
        if (!httpsProxy) {
            [exportDictionary setObject:proxy forKey:kAHProxyExportHTTPS];
            [exportDictionary setObject:proxy
                                 forKey:[kAHProxyExportHTTPS lowercaseString]];
        }
    }

    // If there are not keys added to the dictionary yet, skip the exception
    // list
    if ((exportDictionary.count > 0) && self.exceptionsList) {
        NSMutableArray *exceptionList = [[NSMutableArray alloc] init];

        // The NO_PROXY key is formatted differently than set in system
        // you can't start with wild cards, instead you specify
        // domain extensions directly (e.g. *.mit.edu is just .mit.edu)
        for (NSString *exception in _exceptionsList) {
            if (exception.length > 2 &&
                [[exception substringToIndex:2] isEqualToString:@"*."]) {
                [exceptionList addObject:[exception substringFromIndex:1]];
            } else { [exceptionList addObject:exception]; }
        }

        NSString *exceptions = [exceptionList componentsJoinedByString:@","];
        [exportDictionary setObject:exceptions forKey:kAHProxyExportExceptions];
    }

    return exportDictionary.count
               ? [NSDictionary dictionaryWithDictionary:exportDictionary]
               : nil;
}

#pragma mark - Private
- (AHProxy *)proxyForType:(NSString *)type {
    AHProxy *proxy = nil;
    NSString *typeEnabled = [type stringByAppendingString:@"Enable"];
    if (_systemProxies[typeEnabled]) {
        NSString *proxyServer = [type stringByAppendingString:@"Proxy"];

        // If there is a value for the key init an AHProxy object.
        if (_systemProxies[proxyServer]) {
            proxy = [[AHProxy alloc] init];
            proxy.server = _systemProxies[proxyServer];

            // Set the port.
            NSString *proxyPort = [type stringByAppendingString:@"Port"];
            proxy.port = _systemProxies[proxyPort];

            // Set the user.
            NSString *proxyUser = [type stringByAppendingString:@"User"];
            proxy.user = _systemProxies[proxyUser];

            // Set the type.
            if ([type isEqualToString:@"HTTP"]) {
                proxy.type = kAHProxyTypeHTTP;
            } else if ([type isEqualToString:@"HTTPS"]) {
                proxy.type = kAHProxyTypeHTTPS;
            } else if ([type isEqualToString:@"FTP"]) {
                proxy.type = kAHProxyTypeFTP;
            } else if ([type isEqualToString:@"SOCKS"]) {
                proxy.type = kAHProxyTypeSOCKS;
            }
        }
    }

    // unless disabled try to
    if (!proxy && _useAutoDetectAsFailover) {
        if ([type isEqualToString:@"HTTP"] || [type isEqualToString:@"HTTPS"] ||
            [type isEqualToString:@"FTP"]) {
            proxy = [self.autoDetectedProxies firstObject];
        }
    }

    return proxy;
}

@end
