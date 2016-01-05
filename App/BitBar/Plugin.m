//
//  Plugin.m
//  BitBar
//
//  Created by Mat Ryer on 11/12/13.
//  Copyright (c) 2013 Bit Bar. All rights reserved.
//

#import "Plugin.h"
#import "PluginManager.h"
#import "STPrivilegedTask.h"
#import "NSDate+DateTools.h"
#import "NSColor+Hex.h"

#define DEFAULT_TIME_INTERVAL_SECONDS ((double)60.)

@implementation Plugin

- init { return self = super.init ? _currentLine = -1, _cycleLinesIntervalSeconds = 5, self : nil; }

- initWithManager:(PluginManager*)manager { return self = self.init ? _manager = manager, self : nil; }

- (NSStatusItem *)statusItem { return _statusItem = _statusItem ?: ({
    
    // make the status item
    _statusItem = [self.manager.statusBar statusItemWithLength:NSVariableStatusItemLength];
    
    // build the menu
    [self rebuildMenuForStatusItem:_statusItem]; _statusItem; });
  
}

- (NSMenuItem*) buildMenuItemWithParams:(NSDictionary *)params {

  NSString * title = [params objectForKey:@"title"];
  SEL sel = params[@"href"] ? @selector(performMenuItemHREFAction:)
          : params[@"bash"] ? @selector(performMenuItemOpenTerminalAction:)
          : params[@"refresh"] ? @selector(performRefreshNow:):
    nil;
  
  NSMenuItem * item = [NSMenuItem.alloc initWithTitle:title action:sel keyEquivalent:@""];
  if (sel) {
    item.representedObject = params;
    [item setTarget:self];
  }
  if (params[@"size"] || params[@"color"])
    item.attributedTitle = [self attributedTitleWithParams:params];

  return item;
}

- (NSAttributedString*) attributedTitleWithParams:(NSDictionary *)params {

  NSString * title = params[@"title"];
  CGFloat     size = params[@"size"] ? [params[@"size"] floatValue] : 14;
  NSFont    * font = params[@"font"] ? [NSFont fontWithName:params[@"font"] size:size]
                                     : [NSFont menuFontOfSize:size]
                                    ?: [NSFont menuFontOfSize:size];
  NSColor * fgColor;
  NSMutableAttributedString * attributedTitle = [NSMutableAttributedString.alloc initWithString:title attributes:@{NSFontAttributeName: font}];
  if (!params[@"color"]) return attributedTitle;
  if ((fgColor = [NSColor colorWithWebColorString:[params objectForKey:@"color"]]))
    [attributedTitle addAttribute:NSForegroundColorAttributeName value:fgColor range:NSMakeRange(0, title.length)];
  return attributedTitle;
}

- (NSMenuItem*) buildMenuItemForLine:(NSString *)line { return [self buildMenuItemWithParams:[self dictionaryForLine:line]]; }

- (NSDictionary*) dictionaryForLine:(NSString *)line {
  // Find the title
  NSRange found = [line rangeOfString:@"|"];
  if (found.location == NSNotFound) return @{ @"title": line };
  NSString * title = [[line substringToIndex:found.location] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
  NSMutableDictionary * params = @{@"title":title}.mutableCopy;
  
  // Find the parameters
  NSString * paramStr = [line substringFromIndex:found.location + found.length];

  NSScanner* scanner = [NSScanner scannerWithString:paramStr];
  NSMutableCharacterSet* keyValueSeparator = [NSMutableCharacterSet characterSetWithCharactersInString:@"=:"];
  NSMutableCharacterSet* quoteSeparator = [NSMutableCharacterSet characterSetWithCharactersInString:@"\"'"];
  
  while (![scanner isAtEnd]) {
    NSString *key = @""; NSString* value = @"";
    [scanner scanUpToCharactersFromSet:keyValueSeparator intoString:&key];
    [scanner scanCharactersFromSet:keyValueSeparator intoString:NULL];
    
    if ([scanner scanCharactersFromSet:quoteSeparator intoString:NULL]) {
      [scanner scanUpToCharactersFromSet:quoteSeparator intoString:&value];
      [scanner scanCharactersFromSet:quoteSeparator intoString:NULL];
    } else {
      [scanner scanUpToString:@" " intoString:&value];
    }
    
    // Remove extraneous spaces from key and value
    key = [key stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    params[key] = value;
    
    if([key isEqualToString:@"args"]){
      params[key] = [value componentsSeparatedByString:@"__"];
    }
  }
  
  return params;
}

-(void)performRefreshNow:(NSMenuItem*)menuItem {
    NSLog(@"Nothing to refresh in this plugin");
}

- (void) performMenuItemHREFAction:(NSMenuItem *)menuItem {

  [NSWorkspace.sharedWorkspace openURL:[NSURL URLWithString:menuItem.representedObject[@"href"]]];
}


- (void) performMenuItemOpenTerminalAction:(NSMenuItem *)menuItem {

    NSMutableDictionary * params = menuItem.representedObject;
    NSString *bash = [params[@"bash"] stringByStandardizingPath].stringByResolvingSymlinksInPath,
           *param1 = params[@"param1"] ?: @"",
           *param2 = params[@"param2"] ?: @"",
           *param3 = params[@"param3"] ?: @"",
           *param4 = params[@"param4"] ?: @"",
           *param5 = params[@"param5"] ?: @"",
         *terminal = params[@"terminal"] ?: [NSString stringWithFormat:@"%s", "true"];
    NSArray *args = params[@"args"] ?: ({

      NSMutableArray *argArray = @[].mutableCopy;
      for (int i = 1; i < 6; i ++) {
        id x = params[[NSString stringWithFormat:@"param%i", i]];
        if (x) [argArray addObject:x];
      }
      argArray.copy;

    });
    
    if([terminal isEqual: @"false"]){

      NSLog(@"Args: %@", args);

      id task = [params[@"root"] isEqualToString:@"true"] ? STPrivilegedTask.new : NSTask.new;

      [(NSTask*)task setLaunchPath:bash];
      [(NSTask*)task setArguments:args];
      [(NSTask*)task launch];
      
    } else {

      NSString *full_link = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@", bash, param1, param2, param3, param4, param5];
      NSString *s = [NSString stringWithFormat:@"tell application \"Terminal\" \n\
                do script \"%@\"\n\
                 activate \n\
                 end tell", full_link];
      NSAppleScript *as = [NSAppleScript.alloc initWithSource: s];
      [as executeAndReturnError:nil];
    }
}

- (void) rebuildMenuForStatusItem:(NSStatusItem*)statusItem {
  
  // build the menu
  NSMenu *menu = NSMenu.new;
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
    
    self.lastUpdatedMenuItem = [NSMenuItem.alloc initWithTitle:@"Updated just now" action:nil keyEquivalent:@""];
    [menu addItem:self.lastUpdatedMenuItem];
    
    [menu addItem:[NSMenuItem separatorItem]];
  }
  
  [self addAdditionalMenuItems:menu];
  [self addDefaultMenuItems:menu];
  
  // set the menu
  statusItem.menu = menu;
  
}

- (void) addDefaultMenuItems:(NSMenu *)menu {
  if (menu.itemArray.count>0) {
    [menu addItem:[NSMenuItem separatorItem]];
  }
  [self.manager addHelperItemsToMenu:menu asSubMenu:(menu.itemArray.count>0)];
  
}

- (void) addAdditionalMenuItems:(NSMenu *)menu { }

- (void) changePluginsDirectorySelected:_ {
  
  _manager.path = nil;
  [_manager reset];
}

- (NSNumber*) refreshIntervalSeconds {
  
  if (_refreshIntervalSeconds == nil) {
    
    NSArray *segments = [self.name componentsSeparatedByString:@"."];
    
    if (segments.count < 3)
      return _refreshIntervalSeconds = @(DEFAULT_TIME_INTERVAL_SECONDS);
    
    NSString *timeStr = [segments[1] lowercaseString];
    
    if ([timeStr length] < 2) {
      _refreshIntervalSeconds = @(DEFAULT_TIME_INTERVAL_SECONDS);
      return _refreshIntervalSeconds;
    }
    
    NSString *numberPart = [timeStr substringToIndex:[timeStr length]-1];
    double numericalValue = numberPart.doubleValue ?: DEFAULT_TIME_INTERVAL_SECONDS;
    
    if ([timeStr hasSuffix:@"s"]) {
      // this is ok - but nothing to do
    } else if ([timeStr hasSuffix:@"m"]) numericalValue *= 60;
      else if ([timeStr hasSuffix:@"h"]) numericalValue *= 60*60;
      else if ([timeStr hasSuffix:@"d"]) numericalValue *= 60*60*24;
      else
      return _refreshIntervalSeconds = @(DEFAULT_TIME_INTERVAL_SECONDS);

    
    _refreshIntervalSeconds = @(numericalValue);
    
  }
  
  return _refreshIntervalSeconds;
  
}

- (BOOL) refresh {
  return YES;
}

- (NSString*) lastUpdatedString { return [self.lastUpdated timeAgoSinceNow].lowercaseString; }

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
    NSDictionary * params = [self dictionaryForLine:self.allContentLines[self.currentLine]];
    self.statusItem.attributedTitle = [self attributedTitleWithParams:params];
    self.pluginIsVisible = YES;
  } else {
    self.statusItem = nil;
    self.pluginIsVisible = NO;
  }
  
}

- (void) contentHasChanged {
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
  if (!_allContent) {
    _allContent = self.content;
    if (self.errorContent.length > 0) {
      _allContent = [@"⚠️" stringByAppendingString:_allContent];
      _allContent = [_allContent stringByAppendingString:@"\n---\n"];
      _allContent = [_allContent stringByAppendingString:self.errorContent];
    }
  }
  return _allContent;
}

- (NSArray *)allContentLines {
  
  return _allContentLines = _allContentLines ?: ({

    NSMutableArray *cleanLines = @[].mutableCopy;
    
    for (NSString *lineEval in [self.allContent componentsSeparatedByCharactersInSet:NSCharacterSet.newlineCharacterSet]) {



      
      // strip whitespace
      NSString *line = [self cleanLine:lineEval];

      // add the line if we have something in it
      if (line.length) {
      
        if ([line isEqualToString:@"---"]) break;
        
        [cleanLines addObject:line];
      
      }
      
    }
    cleanLines.copy;
  });
  
}

- (NSString*) cleanLine:(NSString*)line {
    return line;
  NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"  +" options:NSRegularExpressionCaseInsensitive error:nil];
  return [regex stringByReplacingMatchesInString:line options:0 range:NSMakeRange(0, line.length) withTemplate:@" "];
}

- (NSArray*) allContentLinesAfterBreak {
  
  if (_allContentLinesAfterBreak == nil) {
    
    NSArray *lines = [self.allContent componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSMutableArray *cleanLines = [NSMutableArray.alloc initWithCapacity:lines.count];
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
