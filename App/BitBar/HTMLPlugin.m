//
//  HTMLPlugin.m
//  BitBar
//
//  Created by Mathias Leppich on 22/01/14.
//  Copyright (c) 2014 Bit Bar. All rights reserved.
//

#import "HTMLPlugin.h"
#import "PluginManager.h"
#import <WebKit/WebKit.h>

@implementation HTMLPlugin

-(BOOL)refresh {
  
  if (![[NSFileManager defaultManager] fileExistsAtPath:self.path]) {
    return NO;
  }
  
  NSLog(@" HTML File: %@", self.path);
  self.content = @"HTML File";
  self.currentLine = -1;
  [self cycleLines];
  
  [self.manager pluginDidUdpdateItself:self];
  
  return YES;
}

-(void)rebuildMenuForStatusItem:(NSStatusItem *)statusItem {
  WebView * webview = [[WebView alloc] initWithFrame:NSMakeRect(0, 0, 15, 15)];
  
  [webview setFrameLoadDelegate:self];
  [webview setDrawsBackground:NO];
  [[[webview mainFrame] frameView] setAllowsScrolling:NO];

  NSLog(@" WebView: %@", NSStringFromRect(webview.frame));
  NSStringEncoding encoding;
  NSError * error;
  NSString *htmlContent = [NSString stringWithContentsOfFile:self.path
                                                usedEncoding:&encoding
                                                       error:&error];
  NSURL *url = [NSURL fileURLWithPath:[self.path stringByDeletingLastPathComponent]];

  [webview.mainFrame loadHTMLString:htmlContent baseURL:url];
  DOMDocument * dom = webview.mainFrame.DOMDocument;
  NSLog(@" DOM: %@", dom);
  
  statusItem.view = webview;
}

//called when the frame finishes loading
- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)webFrame
{
  WebView * webView = [webFrame webView];
  if([webFrame isEqual:[webView mainFrame]])
  {
    //get the rect for the rendered frame
    NSRect webFrameRect = [[[webFrame frameView] documentView] frame];
    //get the rect of the current webview
    NSRect webViewRect = [webView frame];
    
    //calculate the new frame
    NSRect newWebViewRect = NSMakeRect(webViewRect.origin.x,
                                       webViewRect.origin.y,
                                       webFrameRect.size.width,
                                       webViewRect.size.height);
    //set the frame
    [webView setFrame:newWebViewRect];
    
    NSLog(@"The dimensions of the page are: %@",NSStringFromRect(webFrameRect));
  }
}

@end
