//
//  SUTestWebServer.m
//  Sparkle
//
//  Created by Kevin Wojniak on 10/8/15.
//  Copyright © 2015 Sparkle Project. All rights reserved.
//

#import "SUTestWebServer.h"
#import <sys/socket.h>
#import <netinet/in.h>

@class SUTestWebServerConnection;

@protocol SUTestWebServerConnectionDelegate <NSObject>
@required
- (void)connectionDidClose:(SUTestWebServerConnection*)sender;
@end

@interface SUTestWebServerConnection : NSObject <NSStreamDelegate>

@property (nonatomic) NSString* workingDirectory;
@property (nonatomic, weak) id<SUTestWebServerConnectionDelegate> delegate;
@property (nonatomic) NSInputStream *inputStream;
@property (nonatomic) NSOutputStream *outputStream;
@property (nonatomic) NSData *dataToWrite;
@property (nonatomic) NSInteger numBytesToWrite;

@end

@implementation SUTestWebServerConnection

@synthesize workingDirectory = _workingDirectory;
@synthesize delegate = _delegate;
@synthesize inputStream = _inputStream;
@synthesize outputStream = _outputStream;
@synthesize dataToWrite = _dataToWrite;
@synthesize numBytesToWrite = _numBytesToWrite;

- (instancetype)initWithNativeHandle:(CFSocketNativeHandle)handle workingDirectory:(NSString*)workingDirectory delegate:(id<SUTestWebServerConnectionDelegate>)delegate {
    self = [super init];
    assert(self != nil);
    
    _workingDirectory = workingDirectory;
    _delegate = delegate;
    
    CFReadStreamRef readStream = NULL;
    CFWriteStreamRef writeStream = NULL;
    CFStreamCreatePairWithSocket(NULL, handle, &readStream, &writeStream);
    assert(readStream != NULL);
    assert(writeStream != NULL);
    
    _inputStream = (__bridge NSInputStream*)readStream;
    assert(_inputStream != nil);
    _inputStream.delegate = self;
    
    _outputStream = (__bridge NSOutputStream*)writeStream;
    assert(_outputStream != nil);
    _outputStream.delegate = self;
    
    [_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_inputStream open];
    [_outputStream open];
    
    return self;
}

- (void)close {
    NSInputStream *inputStream = self.inputStream;
    NSOutputStream *outputStream = self.outputStream;
    if (inputStream == nil) {
        assert(outputStream == nil);
        return;
    }
    [inputStream close];
    [outputStream close];
    [inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    self.inputStream = nil;
    self.outputStream = nil;
    [self.delegate connectionDidClose:self];
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    if (eventCode == NSStreamEventEndEncountered) {
        [self close];
        return;
    }
    if (aStream == self.inputStream && eventCode == NSStreamEventHasBytesAvailable) {
        uint8_t buffer[8096];
        const NSInteger numBytes = [self.inputStream read:buffer maxLength:sizeof(buffer)];
        if (numBytes > 0) {
            NSString *request = [[NSString alloc] initWithBytes:buffer length:(NSUInteger)numBytes encoding:NSUTF8StringEncoding];
            NSArray *lines = [request componentsSeparatedByString:@"\r\n"];
            NSString *requestLine = lines.count >= 3 ? [lines objectAtIndex:0] : nil;
            NSArray *parts = requestLine ? [requestLine componentsSeparatedByString:@" "] : nil;
            // Only process GET requests for existing files
            if ([[parts objectAtIndex:0] isEqualToString:@"GET"]) {
                // Use NSURL to strip out query parameters
                NSString *path = [NSURL URLWithString:[parts objectAtIndex:1] relativeToURL:nil].path;
                NSString *filePath = [self.workingDirectory stringByAppendingString:path];
                BOOL isDir = NO;
                if (![[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir] || isDir) {
                    NSLog(@"%@ - 404", requestLine);
                    [self write404];
                } else {
                    NSLog(@"%@ - 200", requestLine);
                    [self write:[NSData dataWithContentsOfFile:filePath] status:YES];
                }
            } else {
                NSLog(@"%@ - 404", requestLine);
                [self write404];
            }
        }
    } else if (aStream == self.outputStream && eventCode == NSStreamEventHasSpaceAvailable && self.dataToWrite != nil) {
        [self checkIfCanWriteNow];
    }
}

- (void)write404 {
    NSString *body = @"<html><head><title>404 Not Found</title></head><body><h1>Not Found</h1></body></html>";
    [self write:[body dataUsingEncoding:NSUTF8StringEncoding] status:NO];
}

- (void)write:(NSData*)body status:(BOOL)status {
    NSString *state = status ? @"200 OK" : @"404 Not Found";
    NSString *header = [NSString stringWithFormat:@"HTTP/1.0 %@\r\nContent-Length: %lu\r\n\r\n", state, body.length];
    NSMutableData *response = [[header dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
    [response appendData:body];
    [self queueWrite:response];
}

- (void)queueWrite:(NSData*)data {
    assert(self.dataToWrite == nil);
    assert(data != nil);
    assert(data.length > 0);
    self.dataToWrite = data;
    self.numBytesToWrite = (NSInteger)data.length;
    [self checkIfCanWriteNow];
}

- (void)checkIfCanWriteNow {
    assert(self.dataToWrite != nil);
    if (self.numBytesToWrite == 0) {
        // nothing more to write, we're done.
        self.dataToWrite = nil;
        self.numBytesToWrite = -1;
    } else if (self.outputStream.hasSpaceAvailable) {
        [self writeNow];
    }
    // otherwise wait for space available event
}

- (void)writeNow {
    assert(self.outputStream != nil);
    assert(self.outputStream.hasSpaceAvailable);
    assert(self.dataToWrite != nil);
    NSData *dataToWrite = self.dataToWrite;
    const uint8_t *bytesOffset = (const uint8_t*)dataToWrite.bytes + ((NSInteger)dataToWrite.length - self.numBytesToWrite);
    const NSInteger bytesWritten = [self.outputStream write:bytesOffset maxLength:(NSUInteger)self.numBytesToWrite];
    if (bytesWritten > 0) {
        self.numBytesToWrite = self.numBytesToWrite - bytesWritten;
        assert(self.numBytesToWrite >= 0);
        // wait for next space available event to write more
    } else {
        NSLog(@"Error: bytes written = %ld (%@)", bytesWritten, [NSString stringWithUTF8String:strerror(errno)]);
    }
}

@end

@interface SUTestWebServer () <SUTestWebServerConnectionDelegate> {
    CFSocketRef _socket;
}

@property (nonatomic) NSMutableArray *connections;
@property (nonatomic) NSString *workingDirectory;

- (void)accept:(CFSocketNativeHandle)address;

@end

static void connectCallback(CFSocketRef __unused s, CFSocketCallBackType type, CFDataRef __unused address, const void *data, void *info) {
    if (type == kCFSocketAcceptCallBack) {
        assert(data != NULL);
        assert(info != NULL);
        SUTestWebServer *server = (__bridge SUTestWebServer*)info;
        assert(server != nil);
        [server accept:*(const CFSocketNativeHandle*)data];
    }
}

@implementation SUTestWebServer

@synthesize connections = _connections;
@synthesize workingDirectory = _workingDirectory;

- (instancetype)initWithPort:(int)port workingDirectory:(NSString*)workingDirectory {
    self = [super init];
    assert(self != nil);
    
    CFSocketContext ctx;
    memset(&ctx, 0, sizeof(ctx));
    ctx.info = (__bridge void*)self;
    _socket = CFSocketCreate(NULL, 0, 0, 0, kCFSocketAcceptCallBack, connectCallback, &ctx);
    assert(_socket != NULL);
    
    struct sockaddr_in address;
    memset(&address, 0, sizeof(address));
    address.sin_len = sizeof(address);
    address.sin_family = AF_INET;
    address.sin_port = htons(port);
    address.sin_addr.s_addr = INADDR_ANY;
    
    // will fail if port is in use.
    CFSocketError socketErr = CFSocketSetAddress(_socket, (CFDataRef)[NSData dataWithBytes:&address length:sizeof(address)]);
    if (socketErr != kCFSocketSuccess) {
        NSLog(@"Socket error: %@", [NSString stringWithUTF8String:strerror(errno)]);
        return nil;
    }
    
    _connections = [[NSMutableArray alloc] init];
    _workingDirectory = workingDirectory;

    CFRunLoopSourceRef source = CFSocketCreateRunLoopSource(NULL, _socket, 0);
    assert(source != NULL);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), source, kCFRunLoopDefaultMode);
    CFRelease(source);
    
    return self;
}

- (void)connectionDidClose:(SUTestWebServerConnection *)sender {
    assert(self.connections != nil);
    assert([self.connections containsObject:sender]);
    [self.connections removeObject:sender];
}

- (void)accept:(CFSocketNativeHandle)address {
    SUTestWebServerConnection *conn = [[SUTestWebServerConnection alloc] initWithNativeHandle:address workingDirectory:self.workingDirectory delegate:self];
    assert(conn != nil);
    if (conn) {
        assert(self.connections != nil);
        [self.connections addObject:conn];
    }
}

- (void)close {
    for (SUTestWebServerConnection *conn in self.connections) {
        [conn close];
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdirect-ivar-access"
    if (_socket) {
        CFSocketInvalidate(_socket);
        CFRelease(_socket);
        _socket = NULL;
    }
#pragma clang diagnostic pop
}

@end
