//
//  AppDelegate.m
//  AHProxyExampe
//
//  Created by Eldon on 11/11/14.
//  Copyright (c) 2014 Eldon Ahrold. All rights reserved.
//

#import "AppDelegate.h"
#import "AHProxySettings.h"
#import "NSTask+useSystemProxies.h"

@interface AppDelegate () {
    AHProxySettings *_settings;
    NSTask *_task;
}

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    _testURL.stringValue = @"https://github.com";
    [self refresh:nil];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
}

- (IBAction)refresh:(id)sender {
    _settings = [[AHProxySettings alloc] init];
    _settings.useAutoDetectAsFailover = _useFailoverButton.state;
    _settings.destinationURL = _testURL.stringValue;

    _HTTPProxy.stringValue =
        _settings.HTTPProxy ? _settings.HTTPProxy.exportString : @"";
    _HTTPSProxy.stringValue =
        _settings.HTTPSProxy ? _settings.HTTPSProxy.exportString : @"";
    _FTPProxy.stringValue =
        _settings.FTPProxy ? _settings.FTPProxy.exportString : @"";
    _SOCKSProxy.stringValue =
        _settings.SOCKSProxy ? _settings.SOCKSProxy.exportString : @"";
    _AUTOProxy.stringValue =
        _settings.autoDetectedProxies
            ? [[_settings.autoDetectedProxies firstObject] exportString]
            : @"";
}

- (IBAction)runTaskWithProxy:(NSButton *)sender {
    [self setupTask];

    [_task useSystemProxiesForDestination:_testURL.stringValue];

    NSLog(@"%@",_task.environment);

    [_task launch];
}

- (IBAction)runTaskWithOutProxy:(id)sender {
    [self setupTask];
    [_task launch];
}

- (void)setupTask {
    _runStatusTF.stringValue = @"Checking...";
    [_runButton setEnabled:NO];
    [_runWithoutButton setEnabled:NO];

    _task = [[NSTask alloc] init];
    _task.launchPath = @"/usr/bin/curl";
    _task.arguments = @[ @"-k", _testURL.stringValue ];
    _task.standardOutput = [NSPipe pipe];
    _task.standardError = [NSPipe pipe];

    __weak typeof(self) weakSelf = self;
    [_task setTerminationHandler:^(NSTask *task) {
        typeof(self) strongSelf = weakSelf;
        if (task.terminationStatus > 0) {
            NSData *data = [[task.standardError fileHandleForReading] readDataToEndOfFile];
            NSString *errString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"%@",errString);
            strongSelf.runStatusTF.stringValue = [NSString stringWithFormat:@"Unable to connect to server [error code:%d]",task.terminationStatus ];
        } else {
            strongSelf.runStatusTF.stringValue = @"Successfully connected to server";
        }
        [strongSelf.runButton setEnabled:YES];
        [strongSelf.runWithoutButton setEnabled:YES];
    }];    
}

- (IBAction)cancelTask:(id)sender {
    if (_task && _task.isRunning) {
        [_task terminate];
    }
}
@end
