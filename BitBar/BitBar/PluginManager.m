//
//  PluginManager.m
//  BitBar
//
//  Created by Mat Ryer on 11/12/13.
//  Copyright (c) 2013 Bit Bar. All rights reserved.
//

#import "PluginManager.h"

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

@end
