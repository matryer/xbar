//
//  Plugin.m
//  BitBar
//
//  Created by Mat Ryer on 11/12/13.
//  Copyright (c) 2013 Bit Bar. All rights reserved.
//

#import "Plugin.h"
#import "PluginManager.h"

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
    
    _statusItem = [self.manager.statusBar statusItemWithLength:NSVariableStatusItemLength];
    
  }
  
  return _statusItem;
  
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
  
  NSTask *task = [[NSTask alloc] init];
  [task setLaunchPath:@"/bin/bash"];
  [task setArguments:[NSArray arrayWithObjects:self.path, nil]];
  
  NSPipe *stdoutPipe = [NSPipe pipe];
  [task setStandardOutput:stdoutPipe];
  
  NSPipe *stderrPipe = [NSPipe pipe];
  [task setStandardError:stderrPipe];
  
  [task launch];
  
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
  
  // execute command
  [self refreshContentByExecutingCommand];
  
  // reset the current line
  self.currentLine = -1;
  
  // update the status item
  [self cycleLines];
  
  return YES;
  
}

- (void) cycleLines {
  
  // update the status item
  self.currentLine++;
  
  // if we've gone too far - wrap around
  if ((NSUInteger)self.currentLine >= self.allContentLines.count) {
    self.currentLine = 0;
  }
  
  [self.statusItem setTitle:self.allContentLines[self.currentLine]];

  
}

- (void)contentHasChanged {
  _allContent = nil;
  _allContentLines = nil;
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
    if (self.errorContent != nil) {
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
      line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
      
      // add the line if we have something in it
      if (line.length > 0)
        [cleanLines addObject:line];
      
    }
    
    _allContentLines = [NSArray arrayWithArray:cleanLines];
    
  }
  return _allContentLines;
  
}

- (BOOL) isMultiline {
  return [self.allContentLines count] > 1;
}

@end
