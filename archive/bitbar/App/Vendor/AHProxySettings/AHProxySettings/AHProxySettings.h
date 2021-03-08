// AHProxySettings.h
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

#import <Foundation/Foundation.h>
#import "AHProxy.h"

/**
 *  String for key representing export HTTP_PROXY for NSTasks
 */
extern NSString *const kAHProxyExportHTTP;
/**
 *  String for key representing export HTTPS_PROXY for NSTasks
 */
extern NSString *const kAHProxyExportHTTPS;
/**
 *  String for key representing export FTP_PROXY for NSTasks
 */
extern NSString *const kAHProxyExportFTP;
/**
 *  String for key representing export ALL_PROXY which is used for socks exports
 * for NSTasks
 */
extern NSString *const kAHProxyExportSOCKS;
/**
 *  String for key representing export NO_PROXY for NSTasks
 */
extern NSString *const kAHProxyExportExceptions;

/**
 *  Access information about the current system proxy configuration
 */
@interface AHProxySettings : NSObject

/**
 *  AHProxy object representing the System Web Proxy (HTTP)
 */
@property (copy, nonatomic, readonly) AHProxy *HTTPProxy;

/**
 *  AHProxy object representing the System Secure Web Proxy (HTTPS)
 */
@property (copy, nonatomic, readonly) AHProxy *HTTPSProxy;

/**
 *  AHProxy object representing the System FTP Proxy
 */
@property (copy, nonatomic, readonly) AHProxy *FTPProxy;

/**
 *  AHProxy object representing the System SOCKS Proxy (HTTP)
 */
@property (copy, nonatomic, readonly) AHProxy *SOCKSProxy;

/**
 *  Array of automatically discovered AHProxy objects from PAC / WPAD
 */
@property (copy, nonatomic, readonly) NSArray *autoDetectedProxies;

/**
 *  List of bypassed hosts and domains used by the system
 */
@property (copy, nonatomic, readonly) NSArray *exceptionsList;

/**
 *  URL used during the execution a PAC script to determine the appropriate
 *  proxies
 */
@property (copy, nonatomic) NSString *destinationURL;

/**
 *  Return a dictionary suitable for NSTask's proxies environment
 */
@property (copy, nonatomic) NSDictionary *taskDictionary;

/**
 *  Whether to use auto-detected proxies as failover for HTTP, HTTPS, and FTP
 *  @note Defaults to true
 */
@property (nonatomic, assign) BOOL useAutoDetectAsFailover;

/**
 *  Initialize the
 *
 *  @param destURL URL used during the execution a PAC script to determine the
 *  appropriate proxies
 *
 *  @return initialized AHProxySettings
 */
- (instancetype)initWithDestination:(NSString *)destURL;

@end
