//
//  AppDelegate.m
//  BitBar
//
//  Created by Mat Ryer on 11/12/13.
//  Copyright (c) 2013 Bit Bar. All rights reserved.
//

#import "BitBarController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (nonatomic) BitBarController* controller;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  // enable usage of Safari's WebInspector to debug HTML Plugins
  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"WebKitDeveloperExtras"];
  
  self.controller = BitBarController.new;
  [self.controller startApp];
  
}

@end

int main(int argc, const char * argv[])
{
  return NSApplicationMain(argc, argv);
}
