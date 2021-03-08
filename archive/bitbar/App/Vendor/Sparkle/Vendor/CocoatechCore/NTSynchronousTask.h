//
//  NTSynchronousTask.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 9/29/05.
//  Copyright 2005 Steve Gehrman. All rights reserved.
//

#ifndef NTSYNCHRONOUSTASK_H
#define NTSYNCHRONOUSTASK_H

@interface NTSynchronousTask : NSObject
@property (readonly, strong) NSData *output;
@property (readonly) int result;

// pass nil for directory if not needed
// returns the result
+(int)	task:(NSString*)toolPath directory:(NSString*)currentDirectory withArgs:(NSArray*)args input:(NSData*)input output: (NSData**)outData;

+(NSData*)task:(NSString*)toolPath directory:(NSString*)currentDirectory withArgs:(NSArray*)args input:(NSData*)input;

- (void)run:(NSString*)toolPath directory:(NSString*)currentDirectory withArgs:(NSArray*)args input:(NSData*)input;

@end

#endif
