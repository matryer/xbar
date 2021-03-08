// Copyright (C) 2014 by Matthew York
//
// Permission is hereby granted, free of charge, to any
// person obtaining a copy of this software and
// associated documentation files (the "Software"), to
// deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge,
// publish, distribute, sublicense, and/or sell copies of the
// Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall
// be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
// BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
// ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "DTError.h"

#pragma mark - Domain
NSString *const DTErrorDomain = @"com.mattyork.dateTools";

@implementation DTError

+(void)throwInsertOutOfBoundsException:(NSInteger)index array:(NSArray *)array{
    //Handle possible zero bounds
    NSInteger arrayUpperBound = (array.count == 0)? 0:array.count;
    
    //Create info for error
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Operation was unsuccessful.", nil), NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Attempted to insert DTTimePeriod at index %ld but the group is of size [0...%ld].", (long)index, (long)arrayUpperBound],NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Please try an index within the bounds or the group.", nil)};
    
    //Handle Error
    NSError *error = [NSError errorWithDomain:DTErrorDomain code:DTInsertOutOfBoundsException userInfo:userInfo];
    [self printErrorWithCallStack:error];
}

+(void)throwRemoveOutOfBoundsException:(NSInteger)index array:(NSArray *)array{
    //Handle possible zero bounds
    NSInteger arrayUpperBound = (array.count == 0)? 0:array.count;
    
    //Create info for error
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Operation was unsuccessful.", nil), NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Attempted to remove DTTimePeriod at index %ld but the group is of size [0...%ld].", (long)index, (long)arrayUpperBound],NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Please try an index within the bounds of the group.", nil)};
    
    //Handle Error
    NSError *error = [NSError errorWithDomain:DTErrorDomain code:DTRemoveOutOfBoundsException userInfo:userInfo];
    [self printErrorWithCallStack:error];
}

+(void)throwBadTypeException:(id)obj expectedClass:(Class)classType{
    //Create info for error
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Operation was unsuccessful.", nil), NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Attempted to insert object of class %@ when expecting object of class %@.", NSStringFromClass([obj class]), NSStringFromClass(classType)],NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Please try again by inserting a DTTimePeriod object.", nil)};
    
    //Handle Error
    NSError *error = [NSError errorWithDomain:DTErrorDomain code:DTBadTypeException userInfo:userInfo];
    [self printErrorWithCallStack:error];
}

+(void)printErrorWithCallStack:(NSError *)error{
    //Print error
    NSLog(@"%@", error);
    
    //Print call stack
    for (NSString *symbol in [NSThread callStackSymbols]) {
        NSLog(@"\n\n %@", symbol);
    }
}
@end
