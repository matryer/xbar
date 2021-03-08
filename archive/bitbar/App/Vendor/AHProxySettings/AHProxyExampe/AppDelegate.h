//
//  AppDelegate.h
//  AHProxyExampe
//
//  Created by Eldon on 11/11/14.
//  Copyright (c) 2014 Eldon Ahrold. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (weak) IBOutlet NSTextField *HTTPProxy;
@property (weak) IBOutlet NSTextField *HTTPSProxy;
@property (weak) IBOutlet NSTextField *FTPProxy;
@property (weak) IBOutlet NSTextField *SOCKSProxy;
@property (weak) IBOutlet NSTextField *AUTOProxy;

@property (weak) IBOutlet NSButton *useFailoverButton;
@property (weak) IBOutlet NSButton *runButton;
@property (weak) IBOutlet NSButton *runWithoutButton;
@property (weak) IBOutlet NSTextField *runStatusTF;


@property (weak) IBOutlet NSTextField *testURL;

- (IBAction)refresh:(id)sender;
- (IBAction)runTaskWithProxy:(NSButton *)sender;
@end

