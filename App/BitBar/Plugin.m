//
//  Plugin.m
//  BitBar
//
//  Created by Mat Ryer on 11/12/13.
//  Copyright (c) 2013 Bit Bar. All rights reserved.
//

#import "Plugin.h"
#import "PluginManager.h"
#import "NSDate+TimeAgo.h"

#define DEFAULT_TIME_INTERVAL_SECONDS 60

@implementation Plugin

- (id) init {
  if (self = [super init]) {
    
    self.currentLine = -1;
    self.cycleLinesIntervalSeconds = 5;
        
  }
  return self;
}

- (id) initWithManager:(PluginManager*)manager {
  if (self = [self init]) {
    _manager = manager;
  }
  return self;
}

- (NSStatusItem *)statusItem {
  
  if (_statusItem == nil) {
    
    // make the status item
    _statusItem = [self.manager.statusBar statusItemWithLength:NSVariableStatusItemLength];
    
    // build the menu
    [self rebuildMenuForStatusItem:_statusItem];
    
  }
  
  return _statusItem;
  
}

- (NSMenuItem *) buildMenuItemForLine:(NSString *)line {
  NSDictionary * params = [self dictionaryForLine:line];
  NSString * title = [params objectForKey:@"title"];
  SEL sel = nil;
  if ([params objectForKey:@"href"] != nil) {
    sel = @selector(performMenuItemHREFAction:);
  }
  NSMenuItem * item = [[NSMenuItem alloc] initWithTitle:title action:sel keyEquivalent:@""];
  if (sel != nil) {
    item.representedObject = params;
    [item setTarget:self];
  }
  return item;
}

- (NSDictionary *) dictionaryForLine:(NSString *)line {
  NSArray * pair = [line componentsSeparatedByString:@"|"];
  NSString * title = [[pair objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
  NSMutableDictionary * params = [@{ @"title": title } mutableCopy];
  if ([pair count] > 1) {
    NSArray * paramsArr = [[[pair objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    for (NSString * paramStr in paramsArr) {
      NSRange found = [paramStr rangeOfString:@"="];
      if (found.location != NSNotFound) {
        NSString * key = [[paramStr substringToIndex:found.location] lowercaseString];
        NSString * value = [paramStr substringFromIndex:found.location + found.length];
        [params setObject:value forKey:key];
      }
    }
  }
  return params;
}

- (void) performMenuItemHREFAction:(NSMenuItem *)menuItem {
  NSMutableDictionary * params = menuItem.representedObject;
  NSString * href = [params objectForKey:@"href"];
  NSURL * url = [NSURL URLWithString:href];
  [[NSWorkspace sharedWorkspace] openURL:url];
}

- (void) rebuildMenuForStatusItem:(NSStatusItem*)statusItem {
  
  // build the menu
  NSMenu *menu = [[NSMenu alloc] init];
  [menu setDelegate:self];
  
  if (self.isMultiline) {
    
    // put all content as an item
    NSString *line;
    for (line in self.allContentLines) {
      NSMenuItem * item = [self buildMenuItemForLine:line];
      [menu addItem:item];
    }
    
    // add the seperator
    [menu addItem:[NSMenuItem separatorItem]];
    
    // are there any allContentLinesAfterBreak?
    if (self.allContentLinesAfterBreak.count > 0) {
      
      // put all content as an item
      NSString *line;
      for (line in self.allContentLinesAfterBreak) {
        
        if ([line isEqualToString:@"---"]) {
          [menu addItem:[NSMenuItem separatorItem]];
        } else {
          NSMenuItem * item = [self buildMenuItemForLine:line];
          [menu addItem:item];
        }
        
      }
      
      // add the seperator
      [menu addItem:[NSMenuItem separatorItem]];
      
    }
    
  }
  
  if (self.lastUpdated != nil) {
    
    self.lastUpdatedMenuItem = [[NSMenuItem alloc] initWithTitle:@"Updated just now" action:nil keyEquivalent:@""];
    [menu addItem:self.lastUpdatedMenuItem];
    
  }
  
  [menu addItem:[NSMenuItem separatorItem]];
  
  NSMenuItem *copyItem = [[NSMenuItem alloc] initWithTitle:@"Copy" action:@selector(copyOutput) keyEquivalent:@"c"];
  [copyItem setTarget:self];
  [menu addItem:copyItem];

  NSMenuItem *copyAllItems = [[NSMenuItem alloc] initWithTitle:@"Copy All" action:@selector(copyAllOutput) keyEquivalent:@"C"];
  [copyAllItems setTarget:self];
  [menu addItem:copyAllItems];

  NSMenuItem *runItem = [[NSMenuItem alloc] initWithTitle:@"Run in Terminal…" action:@selector(runPluginExternally) keyEquivalent:@"o"];
  [runItem setTarget:self];
  [menu addItem:runItem];
  
  
  // add the seperator
  [menu addItem:[NSMenuItem separatorItem]];
  
  [self.manager addHelperItemsToMenu:menu asSubMenu:(menu.itemArray.count>0)];
  
  // set the menu
  statusItem.menu = menu;
  
}


- (void) copyOutput {

  NSString *valueToCopy = [self.allContentLines objectAtIndex:self.currentLine];
  NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
  [pasteboard clearContents];
  [pasteboard writeObjects:[NSArray arrayWithObject:valueToCopy]];
  
}

- (void) copyAllOutput {
  
  NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
  [pasteboard clearContents];
  [pasteboard writeObjects:[NSArray arrayWithObject:self.allContent]];
  
}

- (void) runPluginExternally {
  
  NSString* script = @"tell application \"Terminal\" \n\
	  do script \"%@\" \n\
    activate \n\
  end tell";
  
  NSString *s = [NSString stringWithFormat:
                 script, self.path];
  NSAppleScript *as = [[NSAppleScript alloc] initWithSource:s];
  [as executeAndReturnError:nil];
  
}

- (void)changePluginsDirectorySelected:(id)sender {
  
  self.manager.path = nil;
  [self.manager reset];
  
}

- (NSNumber *)refreshIntervalSeconds {
  
  if (_refreshIntervalSeconds == nil) {
    
    NSArray *segments = [self.name componentsSeparatedByString:@"."];
    
    if ([segments count] < 3) {
      _refreshIntervalSeconds = [NSNumber numberWithDouble:DEFAULT_TIME_INTERVAL_SECONDS];
      return _refreshIntervalSeconds;
    }
    
    NSString *timeStr = [[segments objectAtIndex:1] lowercaseString];
    
    if ([timeStr length] < 2) {
      _refreshIntervalSeconds = [NSNumber numberWithDouble:DEFAULT_TIME_INTERVAL_SECONDS];
      return _refreshIntervalSeconds;
    }
    
    NSString *numberPart = [timeStr substringToIndex:[timeStr length]-1];
    double numericalValue = [numberPart doubleValue];
    
    if (numericalValue == 0) {
      numericalValue = DEFAULT_TIME_INTERVAL_SECONDS;
    }
    
    if ([timeStr hasSuffix:@"s"]) {
      // this is ok - but nothing to do
    } else if ([timeStr hasSuffix:@"m"]) {
      numericalValue *= 60;
    } else if ([timeStr hasSuffix:@"h"]) {
      numericalValue *= 60*60;
    } else if ([timeStr hasSuffix:@"d"]) {
      numericalValue *= 60*60*24;
    } else {
      _refreshIntervalSeconds = [NSNumber numberWithDouble:DEFAULT_TIME_INTERVAL_SECONDS];
      return _refreshIntervalSeconds;
    }
    
    _refreshIntervalSeconds = [NSNumber numberWithDouble:numericalValue];
    
  }
  
  return _refreshIntervalSeconds;
  
}

- (BOOL) refreshContentByExecutingCommand {
  
  if (![[NSFileManager defaultManager] fileExistsAtPath:self.path]) {
    return NO;
  }
  
  NSTask *task = [[NSTask alloc] init];
  
  [task setEnvironment:self.manager.environment];
  [task setLaunchPath:self.path];
  
  NSPipe *stdoutPipe = [NSPipe pipe];
  [task setStandardOutput:stdoutPipe];
  
  NSPipe *stderrPipe = [NSPipe pipe];
  [task setStandardError:stderrPipe];
  
  @try {
    [task launch];
  } @catch (NSException *e) {
    NSLog(@"Error when running %@: %@", self.name, e);
    return NO;
  }
  NSData *stdoutData = [[stdoutPipe fileHandleForReading] readDataToEndOfFile];
  NSData *stderrData = [[stderrPipe fileHandleForReading] readDataToEndOfFile];
  
  [task waitUntilExit];
  
  self.content = [[NSString alloc] initWithData:stdoutData encoding:NSUTF8StringEncoding];
  self.errorContent = [[NSString alloc] initWithData:stderrData encoding:NSUTF8StringEncoding];
  
  // failure
  if ([task terminationStatus] != 0) {
    self.lastCommandWasError = YES;
    return NO;
  }
  
  // success
  self.lastCommandWasError = NO;
  return YES;
  
}

- (BOOL) refresh {
  
  [self.lineCycleTimer invalidate];
  self.lineCycleTimer = nil;
  
  // execute command
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0),  ^{
    [self refreshContentByExecutingCommand];
    dispatch_sync(dispatch_get_main_queue(), ^{
      
      self.lastUpdated = [[NSDate alloc] init];
      
      [self rebuildMenuForStatusItem:self.statusItem];
      
      // reset the current line
      self.currentLine = -1;
      
      // update the status item
      [self cycleLines];
      
      // sort out multi-line cycler
      if (self.isMultiline) {
        
        // start the timer to keep cycling lines
        self.lineCycleTimer = [NSTimer scheduledTimerWithTimeInterval:self.cycleLinesIntervalSeconds target:self selector:@selector(cycleLines) userInfo:nil repeats:YES];
        
      }
      
      // tell the manager this plugin has updated
      [self.manager pluginDidUdpdateItself:self];
      
      // schedule next refresh
      [NSTimer scheduledTimerWithTimeInterval:[self.refreshIntervalSeconds doubleValue] target:self selector:@selector(refresh) userInfo:nil repeats:NO];
      
    });
  });
  
  return YES;
  
}

- (NSString *)lastUpdatedString {
  return [[self.lastUpdated timeAgo] lowercaseString];
}

- (void) cycleLines {
  
  // do nothing if the menu is open
  if (self.menuIsOpen) { return; };
  
  // update the status item
  self.currentLine++;
  
  // if we've gone too far - wrap around
  if ((NSUInteger)self.currentLine >= self.allContentLines.count) {
    self.currentLine = 0;
  }
  
  if (self.allContentLines.count > 0) {
    
    [self.statusItem setTitle:self.allContentLines[self.currentLine]];
    
    self.pluginIsVisible = YES;
  } else {
    self.statusItem = nil;
    self.pluginIsVisible = NO;
  }
  
}

- (void)contentHasChanged {
  _allContent = nil;
  _allContentLines = nil;
  _allContentLinesAfterBreak = nil;
}

- (void) setContent:(NSString *)content {
  _content = content;
  [self contentHasChanged];
}
- (void) setErrorContent:(NSString *)errorContent {
  _errorContent = errorContent;
  [self contentHasChanged];
}

- (NSString *)allContent {
  if (_allContent == nil) {
    
    if ([self.errorContent length] > 0) {
      _allContent = [self.content stringByAppendingString:self.errorContent];
    } else {
      _allContent = self.content;
    }
    
  }
  return _allContent;
}

- (NSArray *)allContentLines {
  
  if (_allContentLines == nil) {
    
    NSArray *lines = [self.allContent componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    NSMutableArray *cleanLines = [[NSMutableArray alloc] initWithCapacity:lines.count];
    NSString *line;
    for (line in lines) {
      
      // strip whitespace
      line = [self cleanLine:line];

      // add the line if we have something in it
      if (line.length > 0) {
      
        if ([line isEqualToString:@"---"]) {
          break;
        }
        
        [cleanLines addObject:line];
      
      }
      
    }
    
    _allContentLines = [NSArray arrayWithArray:cleanLines];
    
  }
  return _allContentLines;
  
}

- (NSString*) cleanLine:(NSString*)line {
  
  NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"  +" options:NSRegularExpressionCaseInsensitive error:nil];
  line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  
  line = [regex stringByReplacingMatchesInString:line options:0 range:NSMakeRange(0, [line length]) withTemplate:@" "];
  
  return line;
}

- (NSArray *)allContentLinesAfterBreak {
  
  if (_allContentLinesAfterBreak == nil) {
    
    NSArray *lines = [self.allContent componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSMutableArray *cleanLines = [[NSMutableArray alloc] initWithCapacity:lines.count];
    NSString *line;
    BOOL storing = NO;

    for (line in lines) {
      
      // strip whitespace
      line = [self cleanLine:line];
      
      // add the line if we have something in it
      if (line.length > 0) {
        
        if ([line isEqualToString:@"---"]) {
          
          if (storing) {
            [cleanLines addObject:line];
          }
          
          storing = YES;
        } else {
          if (storing == YES) {
            [cleanLines addObject:line];
          }
        }
        
      }
      
    }
    
    _allContentLinesAfterBreak = [NSArray arrayWithArray:cleanLines];
    
  }
  
  return _allContentLinesAfterBreak;
  
}

- (BOOL) isMultiline {
  return [self.allContentLines count] > 1 || [self.allContentLinesAfterBreak count]>0;
}

#pragma mark - NSMenuDelegate

- (void)menuWillOpen:(NSMenu *)menu {
  self.menuIsOpen = YES;
  [self.statusItem setHighlightMode:YES];
}

- (void)menuDidClose:(NSMenu *)menu {
  self.menuIsOpen = NO;
  [self.statusItem setHighlightMode:NO];
}

@end
