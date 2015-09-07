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

@interface WebInspector : NSObject  { WebView *_webView; }
- (id)initWithWebView:(WebView *)webView;
- (void)detach:     (id)sender;
- (void)show:       (id)sender;
- (void)showConsole:(id)sender;
@end

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
  [self reinitAutoReloadTimer];
  return YES;
}

-(void)reinitAutoReloadTimer {
  [self.autoReloadTimer invalidate];
  self.autoReloadTimer = [NSTimer scheduledTimerWithTimeInterval:[self.refreshIntervalSeconds doubleValue]
                                                          target:self
                                                        selector:@selector(reloadWebView)
                                                        userInfo:nil
                                                         repeats:YES];
  
}

-(void)reloadWebView {
  NSLog(@"soft reload");
  [self.webView reload:nil];
}

-(void)rebuildMenuForStatusItem:(NSStatusItem *)statusItem {
  WebView * webview = [WebView.alloc initWithFrame:NSMakeRect(0, 0, 15, 15)];

  self.webView = webview;
  
  webview.frameLoadDelegate = self;
  webview.resourceLoadDelegate = self;
  webview.UIDelegate = self;
  webview.drawsBackground = NO;
  webview.mainFrame.frameView.allowsScrolling = NO;
  webview.shouldUpdateWhileOffscreen = YES;
  webview.autoresizingMask = NSViewWidthSizable;

  NSURL * url = [NSURL fileURLWithPath:self.path];
  NSURLRequest * req = [NSURLRequest.alloc initWithURL:url];
  [webview.mainFrame loadRequest:req];
  statusItem.view = webview;

  [self resetMenu];
}

- (void)resizeWebViewToFitContents {
  WebView * webView = (WebView *)self.statusItem.view;
  WebFrame * webFrame = [webView mainFrame];
  
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

# pragma mark Delegate methods

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)webFrame
{
  [self resizeWebViewToFitContents];
}

- (void)webView:(WebView *)sender didClearWindowObject:(WebScriptObject *)windowObject forFrame:(WebFrame *)frame
{
  // WebInspector * inspector = [WebInspector.alloc initWithWebView:sender];
  // [inspector detach:sender];
  // [inspector showConsole:sender];

	NSLog(@"didClearWindowObject: windowObject: %@", windowObject);
	WebScriptObject * script = [sender windowScriptObject];
	NSLog(@"didClearWindowObject: script: %@", script);
	[script setValue:self forKey:@"BitBar"];
  [script evaluateWebScript:@"Object.isArray = function(a){ return a instanceof Array; }"];
}

- (void)webView:(WebView *)webView addMessageToConsole:(NSDictionary *)dictionary
{
	NSLog(@"Error from webkit: %@", dictionary);
}

-(NSArray *)webView:(WebView *)sender contextMenuItemsForElement:(NSDictionary *)element defaultMenuItems:(NSArray *)defaultMenuItems {
  // disable right-click menu in webview
  return nil;
}

-(BOOL)webView:(WebView *)sender shouldChangeSelectedDOMRange:(DOMRange *)currentRange toDOMRange:(DOMRange *)proposedRange affinity:(NSSelectionAffinity)selectionAffinity stillSelecting:(BOOL)flag {
  // disable text selection
  return NO;
}

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)selector {
  SEL allowed[] = {
    @selector(log:),
    @selector(setReloadInterval:),
    @selector(resizeToFit),
    @selector(showWebInspector),
    @selector(resetMenu),
    @selector(addMenuItem:),
    @selector(addMenuItems:),
    @selector(addMenuSeperatorItem),
    @selector(showMenu)
  };
  for (int i=0; i<(sizeof allowed)/(sizeof allowed[0]); i++) {
    if (allowed[i] == selector) {
      NSLog(@"allow Selector: %@", NSStringFromSelector(selector));
      return NO;
    }
  }
  //NSLog(@"isSelectorExcludedFromWebScript: %@", NSStringFromSelector(selector));
  return YES;
}

+(NSString *)webScriptNameForSelector:(SEL)selector {
  return [NSStringFromSelector(selector) stringByReplacingOccurrencesOfString:@":" withString:@""];
}

+(BOOL)isKeyExcludedFromWebScript:(const char *)name {
  NSArray * allowed = @[
                        @"reloadInterval"
                        ];
  if ([allowed containsObject:[NSString stringWithUTF8String:name]]) {
    NSLog(@"isKeyExcludedFromWebScript: %@", [NSString stringWithUTF8String:name]);
    return NO;
  }
  return YES;
}

#pragma mark - WebScriptObject Utils

- (NSArray*) arrayOfKeysFromWebScriptObject:(WebScriptObject *)obj {
  WebScriptObject* bridge = [obj evaluateWebScript:@"Object"];
  WebScriptObject* keysObj = [bridge callWebScriptMethod:@"keys" withArguments:@[obj]];
  return [self arrayFromWebScriptObject:keysObj];
}

- (NSDictionary*) dictionaryFromWebScriptObject:(WebScriptObject *)obj {
  NSArray * keys = [self arrayOfKeysFromWebScriptObject:obj];
  NSMutableDictionary * dict = [NSMutableDictionary.alloc initWithCapacity:keys.count];
  for (NSString * key in keys) {
    NSObject * value = [obj valueForKey:key];
    if ([[value class] isSubclassOfClass:[NSString class]] || [[value class] isSubclassOfClass:[NSNumber class]]) {
      [dict setObject:value forKey:key];
    }
  }
  return dict;
}

- (BOOL) isWebScriptObjectInstanceOfArray:(WebScriptObject *)obj {
  WebScriptObject* bridge = [obj evaluateWebScript:@"Object"];
  NSNumber * result = [bridge callWebScriptMethod:@"isArray" withArguments:@[obj]];
  return [result boolValue];
}

- (NSArray*) arrayFromWebScriptObject:(WebScriptObject *)obj {
  NSMutableArray * values = NSMutableArray.new;
  id elem = nil;
  int i = 0;
  WebUndefined *undefined = [WebUndefined undefined];
  while ((elem = [obj webScriptValueAtIndex:i++]) != undefined) {
    [values addObject:elem];
  }
  return values;
}


#pragma mark - Called from JavaScript

-(void)log:(NSString*) str {
  NSLog(@"JAVASCRIPT LOG: %@", str);
}

-(NSNumber *)reloadInterval {
  NSLog(@"reloadInterval:");
  return self.refreshIntervalSeconds;
}

-(void)setReloadInterval:(NSNumber* )arg{
  if (![arg isKindOfClass:[NSNumber class]]) {
    return;
  }
  NSLog(@"setReloadInterval: %@", arg);
  self.refreshIntervalSeconds = arg;
  [self reinitAutoReloadTimer];
}

- (void) resizeToFit {
  [self resizeWebViewToFitContents];
}

- (void) resetMenu {
  NSLog(@"resetMenu");
  _menu = NSMenu.new;
}

- (void) addMenuItem:(NSObject*)titleOrParamsDict {
  [self addMenuItems:titleOrParamsDict];
}

- (void) addMenuItems:(NSObject*)titleOrParamsDict {
  NSDictionary * params = nil;
  if ([[titleOrParamsDict class] isSubclassOfClass:[NSString class]]) {
    NSString * title = (NSString *)titleOrParamsDict;
    if ([title hasPrefix:@"---"]) {
      [self addMenuSeperatorItem];
      return;
    }
    params = @{@"title": title};
  }
  else if ([[titleOrParamsDict class] isSubclassOfClass:[NSArray class]]) {
    NSArray * values = (NSArray *)titleOrParamsDict;
    for (NSObject * value in values) {
      [self addMenuItem:value];
    }
    return;
  }
  else if ([[titleOrParamsDict class] isSubclassOfClass:[NSDictionary class]]) {
    params = (NSDictionary *)titleOrParamsDict;
  }
  else if ([[titleOrParamsDict class] isSubclassOfClass:[WebScriptObject class]]) {
    WebScriptObject * obj = (WebScriptObject*) titleOrParamsDict;
    if ([self isWebScriptObjectInstanceOfArray:obj]) {
      [self addMenuItems:[self arrayFromWebScriptObject:obj]];
      return;
    } else {
      params = [self dictionaryFromWebScriptObject:obj];
    }
  }
  else {
    NSLog(@"addMenuItem: ERROR: unhandled class: %@", [titleOrParamsDict class]);
  }
  if (params != nil) {
    NSLog(@"addMenuItem: %@", params);
    NSMenuItem * item = [self buildMenuItemWithParams:params];
    [_menu addItem:item];
  }
}

- (void) addMenuSeperatorItem {
  NSLog(@"addMenuSeperatorItem");
  [_menu addItem:[NSMenuItem separatorItem]];
}

- (void) showMenu {
  NSLog(@"showMenu");
  _menu.delegate = self;
  
  [self addDefaultMenuItems:_menu];
  self.statusItem.menu = _menu;
  [self.statusItem popUpStatusItemMenu:self.statusItem.menu];
}

- (void) showWebInspector {
  WebView * webview = (WebView*) self.statusItem.view;
  WebInspector * inspector = [WebInspector.alloc initWithWebView:webview];
  // [inspector detach:sender];
  [inspector showConsole:webview];
}

@end
