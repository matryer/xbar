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
#import "NSColor+Hex.h"

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

- (NSMenuItem *) buildMenuItemWithParams:(NSDictionary *)params {
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
  if ([params objectForKey:@"color"] != nil) {
    item.attributedTitle = [self attributedTitleWithParams:params];
  }
  return item;
}

- (NSAttributedString *) attributedTitleWithParams:(NSDictionary *)params {
  NSString * title = [params objectForKey:@"title"];
  NSFont * font = [NSFont menuFontOfSize:14.0];
  NSMutableAttributedString * attributedTitle = [[NSMutableAttributedString alloc] initWithString:title attributes:@{NSFontAttributeName: font}];
  if ([params objectForKey:@"color"] != nil) {
    NSColor * fgColor = [NSColor colorWithWebColorString:[params objectForKey:@"color"]];
    if (fgColor != nil) {
      [attributedTitle addAttribute:NSForegroundColorAttributeName value:fgColor range:NSMakeRange(0, title.length)];
    }
  }
  return attributedTitle;
}

- (NSMenuItem *) buildMenuItemForLine:(NSString *)line {
  NSDictionary * params = [self dictionaryForLine:line];
  return [self buildMenuItemWithParams:params];
}

- (NSDictionary *) dictionaryForLine:(NSString *)line {
  NSRange found = [line rangeOfString:@"|"];
  if (found.location == NSNotFound) {
    return @{ @"title": line };
  }
  NSString * title = [[line substringToIndex:found.location]
                      stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
  NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
  [params setObject:title forKey:@"title"];
  NSString * paramsStr = [line substringFromIndex:found.location + found.length];
  NSArray * paramsArr = [[paramsStr
                          stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]
                         componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
  for (NSString * paramStr in paramsArr) {
    NSRange found = [paramStr rangeOfString:@"="];
    if (found.location != NSNotFound) {
      NSString * key = [[paramStr substringToIndex:found.location] lowercaseString];
      NSString * value = [paramStr substringFromIndex:found.location + found.length];
      [params setObject:value forKey:key];
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
  
  [self addAdditionalMenuItems:menu];
  
  [self.manager addHelperItemsToMenu:menu asSubMenu:(menu.itemArray.count>0)];
  
  // set the menu
  statusItem.menu = menu;
  
}

- (void) addAdditionalMenuItems:(NSMenu *)menu {
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


- (BOOL) refresh {
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
    NSDictionary * params = [self dictionaryForLine:self.allContentLines[self.currentLine]];
    self.statusItem.attributedTitle = [self attributedTitleWithParams:params];
    
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
