//
//  NTSynchronousTask.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 9/29/05.
//  Copyright 2005 Steve Gehrman. All rights reserved.
//

#import "NTSynchronousTask.h"

@interface NTSynchronousTask ()
@property (strong) NSTask *task;
@property (strong) NSPipe *outputPipe;
@property (strong) NSPipe *inputPipe;
@property (readwrite, strong) NSData *output;
@property (getter = isDone) BOOL done;
@property (readwrite) int result;
@end

@implementation NTSynchronousTask
@synthesize output = mv_output;
@synthesize result = mv_result;
@synthesize task = mv_task;
@synthesize outputPipe = mv_outputPipe;
@synthesize inputPipe = mv_inputPipe;
@synthesize done = mv_done;

- (void)taskOutputAvailable:(NSNotification*)note
{
	self.output = [[note userInfo] objectForKey:NSFileHandleNotificationDataItem];

	self.done = YES;
}

- (void)taskDidTerminate:(NSNotification *) __unused note
{
    self.result = [self.task terminationStatus];
}

- (instancetype)init
{
    self = [super init];
	if (self)
	{
		self.task = [[NSTask alloc] init];
		self.outputPipe = [[NSPipe alloc] init];
		self.inputPipe = [[NSPipe alloc] init];

		self.task.standardInput = self.inputPipe;
		self.task.standardOutput = self.outputPipe;
		self.task.standardError = self.outputPipe;
	}

    return self;
}

//----------------------------------------------------------
// dealloc
//----------------------------------------------------------
- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)run:(NSString*)toolPath directory:(NSString*)currentDirectory withArgs:(NSArray*)args input:(NSData*)input
{
	BOOL success = NO;

	if (currentDirectory) {
		self.task.currentDirectoryPath = currentDirectory;
	}

	self.task.launchPath = toolPath;
	self.task.arguments = args;

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(taskOutputAvailable:)
												 name:NSFileHandleReadToEndOfFileCompletionNotification
											   object:[[self outputPipe] fileHandleForReading]];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(taskDidTerminate:)
												 name:NSTaskDidTerminateNotification
											   object:[self task]];

	[[[self outputPipe] fileHandleForReading] readToEndOfFileInBackgroundAndNotifyForModes:@[NSDefaultRunLoopMode, NSModalPanelRunLoopMode, NSEventTrackingRunLoopMode]];

	@try
	{
		[self.task launch];
		success = YES;
	}
	@catch (NSException *) { }

	if (success)
	{
		if (input)
		{
			// feed the running task our input
			[[self.inputPipe fileHandleForWriting] writeData:input];
			[[self.inputPipe fileHandleForWriting] closeFile];
		}

		// loop until we are done receiving the data
		if (!self.done)
		{
			double resolution = 1;
			BOOL isRunning;
			NSDate* next;

			do {
				next = [NSDate dateWithTimeIntervalSinceNow:resolution];

				isRunning = [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
													 beforeDate:next];
			} while (isRunning && !self.done);
		}
	}
}

+ (NSData*)task:(NSString*)toolPath directory:(NSString*)currentDirectory withArgs:(NSArray*)args input:(NSData*)input
{
	@autoreleasepool {
		NSData* result = nil;
		// we need this wacky pool here, otherwise we run out of pipes, the pipes are internally autoreleased
		@try {
			NTSynchronousTask* task = [[NTSynchronousTask alloc] init];

			[task run:toolPath directory:currentDirectory withArgs:args input:input];

			if ([task result] == 0) {
				result = [task output];
			}
		}
		@catch (NSException *) { }
		
		return result;
	}
}


+(int)	task:(NSString*)toolPath directory:(NSString*)currentDirectory withArgs:(NSArray*)args input:(NSData*)input output: (NSData*__autoreleasing *)outData
{
	// we need this wacky pool here, otherwise we run out of pipes, the pipes are internally autoreleased
	@autoreleasepool {
		int taskResult = 0;
		if (outData) {
			*outData = nil;
		}

		@try {
			NTSynchronousTask* task = [[NTSynchronousTask alloc] init];

			[task run:toolPath directory:currentDirectory withArgs:args input:input];

			taskResult = [task result];
			if (outData) {
				*outData = [task output];
			}
			
		} @catch (NSException *) {
			taskResult = errCppGeneral;
		}
		
		return taskResult;
	}
}

@end
