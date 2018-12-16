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
#import "NSString+Emojize.h"
#import "NSString+ANSI.h"

#define DEFAULT_TIME_INTERVAL_SECONDS ((double)60.)

@implementation Plugin

- init { return (self = super.init) ? _currentLine = -1, _cycleLinesIntervalSeconds = 5, self : nil; }

- initWithManager:(PluginManager*)manager { return (self = self.init) ? _manager = manager, self : nil; }

- (NSStatusItem *)statusItem { return _statusItem = _statusItem ?: ({
    
    // make the status item
    _statusItem = [self.manager.statusBar statusItemWithLength:NSVariableStatusItemLength];
    
    // build the menu
    [self rebuildMenuForStatusItem:_statusItem]; _statusItem; });
  
}

- (NSImage*) createImageFromBase64:(NSString*)string isTemplate:(BOOL)template{
  NSData * imageData;
  if ([NSData instancesRespondToSelector:@selector(initWithBase64EncodedString:options:)]) {
    imageData = [[NSData alloc] initWithBase64EncodedString:string options:0];
  }else {
    imageData = [[NSData alloc] initWithBase64Encoding:string];
  }
  NSImage * image = [[NSImage alloc] initWithData:imageData];
  if (template) {
    [image setTemplate:true];
  }
  return image;
}

- (NSMenuItem*) buildMenuItemWithParams:(NSDictionary *)params {

  if ([[params[@"dropdown"] lowercaseString] isEqualToString:@"false"]) {
    return nil;
  }
  
  NSString * fullTitle = params[@"title"];
  if (![[params[@"emojize"] lowercaseString] isEqualToString:@"false"]) {
    fullTitle = [fullTitle emojizedString];
  }
  if (![[params[@"trim"] lowercaseString] isEqualToString:@"false"]) {
      fullTitle = [fullTitle stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
  }

  CGFloat titleLength = [fullTitle length];
  CGFloat lengthParam = params[@"length"] ? [params[@"length"] floatValue] : titleLength;
  CGFloat truncLength = lengthParam >= titleLength ? titleLength : lengthParam;

  NSString * title = truncLength < titleLength ? [[fullTitle substringToIndex:truncLength] stringByAppendingString:@"…"] : fullTitle;

  SEL sel = params[@"href"] ? @selector(performMenuItemHREFAction:)
          : params[@"bash"] ? @selector(performMenuItemOpenTerminalAction:)
          : params[@"refresh"] ? @selector(performRefreshNow):
    nil;

  NSMenuItem * item = [NSMenuItem.alloc initWithTitle:title action:sel keyEquivalent:@""];

  if (truncLength < titleLength)
    [item setToolTip:fullTitle];

  item.representedObject = params;  
  if (sel) {
    [item setTarget:self];
  }
  BOOL parseANSI = [fullTitle containsANSICodes] && ![[params[@"ansi"] lowercaseString] isEqualToString:@"false"];
  if (params[@"font"] || params[@"size"] || params[@"color"] || parseANSI)
    item.attributedTitle = [self attributedTitleWithParams:params];
  
  if (params[@"alternate"]) {
    item.alternate = YES;
    item.keyEquivalentModifierMask = NSAlternateKeyMask;
  }
  if (params[@"templateImage"]) {
    item.image = [self createImageFromBase64:params[@"templateImage"] isTemplate:true];
  }else if (params[@"image"]) {
    item.image = [self createImageFromBase64:params[@"image"] isTemplate:false];
  }

  return item;
}

- (NSAttributedString*) attributedTitleWithParams:(NSDictionary *)params {

  NSString * fullTitle = params[@"title"];
  if (![[params[@"emojize"] lowercaseString] isEqualToString:@"false"]) {
    fullTitle = [fullTitle emojizedString];
  }
  if (![[params[@"trim"] lowercaseString] isEqualToString:@"false"]) {
    fullTitle = [fullTitle stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
  }

  CGFloat titleLength = [fullTitle length];
  CGFloat lengthParam = params[@"length"] ? [params[@"length"] floatValue] : titleLength;
  CGFloat truncLength = lengthParam >= titleLength ? titleLength : lengthParam;

  NSString * title = truncLength < titleLength ? [[fullTitle substringToIndex:truncLength] stringByAppendingString:@"…"] : fullTitle;

  CGFloat     size = params[@"size"] ? [params[@"size"] floatValue] : 14;
  NSFont    * font;
  if ([NSFont respondsToSelector:@selector(monospacedDigitSystemFontOfSize:weight:)]) {
    font = [self isFontValid:params[@"font"]] ? [NSFont fontWithName:params[@"font"] size:size]
                                       : [NSFont monospacedDigitSystemFontOfSize:size weight:NSFontWeightRegular]
                                      ?: [NSFont monospacedDigitSystemFontOfSize:size weight:NSFontWeightRegular];
  } else {
    font = [self isFontValid:params[@"font"]] ? [NSFont fontWithName:params[@"font"] size:size]
                                       : [NSFont menuFontOfSize:size]
                                       ?: [NSFont menuFontOfSize:size];
  }

  NSDictionary* attributes = @{NSFontAttributeName: font, NSBaselineOffsetAttributeName : @0};
  BOOL parseANSI = [fullTitle containsANSICodes] && ![[params[@"ansi"] lowercaseString] isEqualToString:@"false"];
  if (parseANSI) {
    NSMutableAttributedString * attributedTitle = [title attributedStringParsingANSICodes];
    [attributedTitle addAttributes:attributes range:NSMakeRange(0, attributedTitle.length)];
    return attributedTitle;
  } else {
    NSColor * fgColor;
    NSMutableAttributedString * attributedTitle = [NSMutableAttributedString.alloc initWithString:title attributes:attributes];
    if (!params[@"color"]) return attributedTitle;
    if ((fgColor = [NSColor colorWithWebColorString:[params objectForKey:@"color"]]))
      [attributedTitle addAttribute:NSForegroundColorAttributeName value:fgColor range:NSMakeRange(0, title.length)];
    return attributedTitle;
  }
}

- (NSMenuItem*) buildMenuItemForLine:(NSString *)line { return [self buildMenuItemWithParams:[self dictionaryForLine:line]]; }

- (NSDictionary*) dictionaryForLine:(NSString *)line {
  // Find the title
  NSRange found = [line rangeOfString:@"|"];
  if (found.location == NSNotFound) return @{ @"title": line };
  NSString * title = [line substringToIndex:found.location];
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

- (void)performRefreshNow {
    NSLog(@"Nothing to refresh in this plugin");
}

- (void)performHREFAction:(NSDictionary *)params {
  [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:params[@"href"]]];
}

- (void) performMenuItemHREFAction:(NSMenuItem *)menuItem {

  [self performHREFAction:menuItem.representedObject];
}

- (void) startTask:(NSMutableDictionary*)params {
    id task = [params[@"root"] isEqualToString:@"true"] ? STPrivilegedTask.new : NSTask.new;
    
    [(NSTask*)task setLaunchPath:params[@"bash"]];
    [(NSTask*)task setArguments:params[@"args"]];
    
    ((NSTask*)task).terminationHandler = ^(NSTask *task) {
      if (params[@"refresh"]) {
        [self performSelectorOnMainThread:@selector(performRefreshNow) withObject:NULL waitUntilDone:false];
      }
    };
    @try {
      [(NSTask*)task launch];
    } @catch (NSException *e) {
      NSLog(@"Error launching command for %@:\n\tCMD: %@\n\tARGS: %@\n%@", self.name, params[@"bash"], params[@"args"], e);
    }
    [(NSTask*)task waitUntilExit];
}

- (void)performOpenTerminalAction:(NSMutableDictionary *)params {

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
      [params setObject:bash forKey:@"bash"];
      [params setObject:args forKey:@"args"];
      [self performSelectorInBackground:@selector(startTask:) withObject:params];
    } else {

      NSString *full_link = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@", bash, param1, param2, param3, param4, param5];
      NSString *s = [NSString stringWithFormat:@"tell application \"Terminal\" \n\
                 do script \"%@\" \n\
                 activate \n\
                 end tell", full_link];
      NSAppleScript *as = [NSAppleScript.alloc initWithSource: s];
      [as executeAndReturnError:nil];
    }
}

- (void)performMenuItemOpenTerminalAction:(NSMenuItem *)menuItem {
  [self performOpenTerminalAction:menuItem.representedObject];
}

- (void) rebuildMenuForStatusItem:(NSStatusItem*)statusItem {
  
  // build the menu
  NSMenu *menu = NSMenu.new;
  [menu setDelegate:self];
  
  if (self.isMultiline) {
    
    // put all content as an item
    NSString *line;
    if ([self.titleLines count] > 1) {
      for (line in self.titleLines) {
        NSMenuItem * item = [self buildMenuItemForLine:line];
        if (item) {
          [menu addItem:item];
        }

      }
      // add the seperator
      [menu addItem:[NSMenuItem separatorItem]];
    }
    
    // are there any allContentLines?
    if (self.allContentLines.count > 0) {
      
      // put all content as an item
      NSString *line;
      for (line in self.allContentLines) {
        if ([line isEqualToString:@"---"]) {
          [menu addItem:[NSMenuItem separatorItem]];
        } else {
          NSMenu *submenu = menu;
          
          // traverse submenus up to the menu to add the item to
          while ([line hasPrefix:@"--"]) {
            line = [line substringFromIndex:2];
            
            NSMenuItem *lastItem = submenu.itemArray.lastObject;
            
            if (!lastItem.submenu) {
              lastItem.submenu = [[NSMenu alloc] init];
              lastItem.submenu.delegate = self;
            }
            
            submenu = lastItem.submenu;
            
            if ([line isEqualToString:@"---"]) {
              break;
            }
          }
          
          if ([line isEqualToString:@"---"]) {
            [submenu addItem:[NSMenuItem separatorItem]];
          } else {
            NSMenuItem * item = [self buildMenuItemForLine:line];
            if(item)
              [submenu addItem:item];
          }
        }
        
      }
      
      // add the seperator
      [menu addItem:[NSMenuItem separatorItem]];
      
    }
    
  }
  
  if (self.lastUpdated != nil) {
    
    self.lastUpdatedMenuItem = [NSMenuItem.alloc initWithTitle:@"Updated just now" action:nil keyEquivalent:@""];
    [menu addItem:self.lastUpdatedMenuItem];
  }
  
  [self addAdditionalMenuItems:menu];
  [self addDefaultMenuItems:menu];
  
  // set the menu
  statusItem.menu = menu;
  
}

- (void) addDefaultMenuItems:(NSMenu *)menu {
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

- (void) close {
}

- (NSString*) lastUpdatedString { return [self.lastUpdated timeAgoSinceNow].lowercaseString; }

- (void) cycleLines {
  
  // do nothing if the menu is open
  if (self.menuIsOpen) { return; };
  
  // update the status item
  self.currentLine++;
  
  // if we've gone too far - wrap around
  if ((NSUInteger)self.currentLine >= self.titleLines.count) {
    self.currentLine = 0;
  }
  
  if (self.titleLines.count > 0) {
    NSDictionary * params = [self dictionaryForLine:self.titleLines[self.currentLine]];
    
    // skip alternate line
    if (params[@"alternate"]) {
      [self cycleLines];
      return;
    }
    
    if (params[@"href"] || params[@"bash"] || params[@"refresh"]) {
      self.statusItem.menu = nil;
      self.statusItem.action = @selector(statusItemClicked);
      self.statusItem.target = self;
    } else if (!self.statusItem.menu) {
      self.statusItem.action = NULL;
      self.statusItem.target = nil;
      [self rebuildMenuForStatusItem:self.statusItem];
    }
    
    // Add image if present
    if (params[@"templateImage"]) {
      self.statusItem.image = [self createImageFromBase64:params[@"templateImage"] isTemplate:true];
    }else if (params[@"image"]) {
      self.statusItem.image = [self createImageFromBase64:params[@"image"] isTemplate:false];
    } else {
      self.statusItem.image = nil;
    }
    
    
    self.statusItem.attributedTitle = [self attributedTitleWithParams:params];
    self.pluginIsVisible = YES;
  } else {
    self.statusItem = nil;
    self.pluginIsVisible = NO;
  }
  
}

- (void) contentHasChanged {
  _allContent = nil;
  _titleLines = nil;
  _allContentLines = nil;
}

- (BOOL) isFontValid:(NSString *)fontName {
  if (fontName == nil) {
    return NO;
  }
  
  NSFontDescriptor *fontDescriptor = [NSFontDescriptor fontDescriptorWithFontAttributes:@{NSFontNameAttribute:fontName}];
  NSArray *matches = [fontDescriptor matchingFontDescriptorsWithMandatoryKeys: nil];
  
  return ([matches count] > 0);
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

- (NSArray *)titleLines {
  
  return _titleLines = _titleLines ?: ({

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
  NSArray *splitLine = [line componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
  if ([[splitLine componentsJoinedByString:@""] isEqualToString:@""])
    return @"";
  return line; //[splitLine componentsJoinedByString:@" "];
  //return [regex stringByReplacingMatchesInString:line options:0 range:NSMakeRange(0, line.length) withTemplate:@" "];
}

- (NSArray*) allContentLines {
  
  if (_allContentLines == nil) {
    
    NSArray *lines = [self.allContent componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSMutableArray *cleanLines = [NSMutableArray.alloc initWithCapacity:lines.count];
    NSString *line;
    BOOL firstBreakFound = NO;

    for (line in lines) {
      
      // strip whitespace
      line = [self cleanLine:line];
      
      // add the line if we have something in it
      if (line.length > 0) {
        
        if ([line isEqualToString:@"---"]) {
          
          if (firstBreakFound) {
            [cleanLines addObject:line];
          }

          firstBreakFound = YES;
        } else {
          if (firstBreakFound) {
            [cleanLines addObject:line];
          }
        }
        
      }
      
    }
    
    _allContentLines = [NSArray arrayWithArray:cleanLines];
    
  }
  
  return _allContentLines;
  
}

- (BOOL) isMultiline {
  return [self.titleLines count] > 1 || [self.allContentLines count]>0;
}

- (void)statusItemClicked {
  NSDictionary *params = [self dictionaryForLine:self.titleLines[self.currentLine]];
  if (params[@"href"]) {
    [self performHREFAction:params];
  } else if (params[@"bash"]) {
    [self performOpenTerminalAction:[NSMutableDictionary dictionaryWithDictionary:params]];
  } else if (params[@"refresh"]) {
    [self performRefreshNow];
  }
}

#pragma mark - NSMenuDelegate

- (void)menuWillOpen:(NSMenu *)menu {
  if (menu.supermenu) {
    return;
  }
  
  self.menuIsOpen = YES;
  
  if (self.currentLine >= 0 && self.currentLine < self.titleLines.count) {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:[self dictionaryForLine:self.titleLines[self.currentLine]]];
    if (params[@"color"]) {
      [params removeObjectForKey:@"color"];
      self.statusItem.attributedTitle = [self attributedTitleWithParams:params];
    }
  }
  
  [self.statusItem setHighlightMode:YES];

  [self.lastUpdatedMenuItem setTitle:self.lastUpdated ? [NSString stringWithFormat:@"Updated %@", self.lastUpdatedString] : @"Refreshing…"];
}

- (void)menuDidClose:(NSMenu *)menu {
  if (menu.supermenu) {
    return;
  }
  
  self.menuIsOpen = NO;
  [self.statusItem setHighlightMode:NO];
  
  if (self.currentLine >= 0 && self.currentLine < self.titleLines.count) {
    NSDictionary *params = [self dictionaryForLine:self.titleLines[self.currentLine]];
    if (params[@"color"]) {
      self.statusItem.attributedTitle = [self attributedTitleWithParams:params];
    }
  }
}

- (void)menu:(NSMenu *)menu willHighlightItem:(NSMenuItem *)item {
  // restore about to be unhighlighted item
  if (menu.highlightedItem.representedObject && menu.highlightedItem.attributedTitle) {
    NSDictionary *params = menu.highlightedItem.representedObject;
    if (params[@"color"]) {
      menu.highlightedItem.attributedTitle = [self attributedTitleWithParams:params];
    }
  }
  
  // remove about to be highlighted item color
  if (item.representedObject && item.attributedTitle) {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:item.representedObject];
    if (params[@"color"]) {
      [params removeObjectForKey:@"color"];
      item.attributedTitle = [self attributedTitleWithParams:params];
    }
  }
}

@end
