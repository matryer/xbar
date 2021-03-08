// AHProxy.m
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

#import "AHProxy.h"
#import <Security/Security.h>

@interface AHProxy ()
@property (copy, nonatomic, readwrite) NSString *server;
@property (copy, nonatomic, readwrite) NSNumber *port;
@property (copy, nonatomic, readwrite) NSString *user;
@property (copy, nonatomic, readwrite) NSString *password;
@property (assign, nonatomic, readwrite) AHProxyType type;
@end

NSString *urlEncodedString(NSString *string) {
    NSString *result = CFBridgingRelease(
        CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                (__bridge CFStringRef)string,
                                                NULL,
                                                CFSTR(":/?#[]@$&’+,;="),
                                                kCFStringEncodingUTF8));
    return result;
}

@implementation AHProxy
- (NSString *)description {
    return self.exportString;
}

- (NSString *)password {
    if (!_password && (_server && _user)) {
        CFTypeRef results = NULL;

        NSData *passwordData = nil;
        NSDictionary *query = @{
            (__bridge id)kSecClass : (__bridge id)kSecClassInternetPassword,
            (__bridge id)kSecMatchLimit : (__bridge id)kSecMatchLimitOne,
            (__bridge id)kSecAttrService : _server,
            (__bridge id)kSecAttrAccount : _user,
            (__bridge id)kSecReturnData : @YES,
        };

        if (SecItemCopyMatching((__bridge CFDictionaryRef)query, &results) ==
            errSecSuccess) {
            passwordData = CFBridgingRelease(results);
            if (passwordData) {
                _password =
                    [[NSString alloc] initWithData:passwordData
                                          encoding:NSUTF8StringEncoding];
            }
        }
    }
    return _password;
}

- (NSString *)exportString {
    NSString *exportString = nil;
    if (_server) {

        NSMutableString *workingExportString =
            [[NSMutableString alloc] initWithString:[self prefixForType]];

        if (_user && self.password) {
            [workingExportString
                appendFormat:@"%@:%@@", _user, urlEncodedString(_password)];
        }

        [workingExportString appendString:_server];
        if (_port) {
            [workingExportString appendFormat:@":%@", _port];
        }
        exportString = [NSString stringWithString:workingExportString];
    }
    return exportString;
}

- (NSString *)prefixForType {
    NSString *prefix;
    switch (_type) {
        case kAHProxyTypeFTP:
        case kAHProxyTypeHTTP:
            prefix = @"http://";
            break;
        case kAHProxyTypeHTTPS:
            prefix = @"https://";
            break;
        case kAHProxyTypeSOCKS:
            prefix = @"socks://";
            break;
        default:
            prefix = @"";
            break;
    }
    return prefix;
}

@end
