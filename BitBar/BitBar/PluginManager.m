//
//  PluginManager.m
//  BitBar
//
//  Created by Mat Ryer on 11/12/13.
//  Copyright (c) 2013 Bit Bar. All rights reserved.
//

#import "PluginManager.h"
#import "Plugin.h"

@implementation PluginManager

- (id) initWithPluginPath:(NSString *)path {
  if (self = [super init]) {
    
    self.path = [path stringByStandardizingPath];
    
  }
  return self;
}

- (NSArray *) pluginFiles {
  
  // get the listing
  NSError *error;
  NSArray *dirFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.path error:&error];
  
  // TODO: handle error if there is one
  if (error != nil) {
    
    NSLog(@"TODO: handle directory error: %@", error);
    
  }
  
  // filter the files
  NSArray *shFiles = [dirFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.sh'"]];
  return shFiles;
}

- (NSArray *)plugins {
  
  if (_plugins == nil) {
    
    NSArray *pluginFiles = self.pluginFiles;
    NSMutableArray *plugins = [[NSMutableArray alloc] initWithCapacity:[pluginFiles count]];
    NSString *file;
    for (file in self.pluginFiles) {
     
      // setup this plugin
      Plugin *plugin = [[Plugin alloc] initWithManager:self];
      
      [plugin setPath:[self.path stringByAppendingPathComponent:file]];
      [plugin setName:file];
      
      [plugins addObject:plugin];
      
    }
    
    _plugins = [NSArray arrayWithArray:plugins];
  
  }
  
  return _plugins;
  
}

- (NSStatusBar *)statusBar {
  
  if (_statusBar == nil) {
    _statusBar = [NSStatusBar systemStatusBar];
  }
  
  return _statusBar;
  
}

- (void) setupAllPlugins {
  
  Plugin *plugin;
  for (plugin in self.plugins) {
    
    [plugin refresh];
    
  }
  
}

@end
