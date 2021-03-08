# STPrivilegedTask - Objective C class

An NSTask-like wrapper around AuthorizationExecuteWithPrivileges() in the Security API to run shell commands with root privileges in Mac OS X.

Created a long time ago. It has been updated to support ARC and is available via <a href="https://cocoapods.org">CocoaPods</a>.

## Examples

### Create and launch task

```objective-c

STPrivilegedTask *privilegedTask = [[STPrivilegedTask alloc] init];
[privilegedTask setLaunchPath:@"/usr/bin/touch"];
NSArray *args = [NSArray arrayWithObject:@"/etc/my_test_file"];
[privilegedTask setArguments:args];

// this is optional, defaults to /
// [privilegedTask setCurrentDirectoryPath:[[NSBundle mainBundle] resourcePath]];

// launch it, user is prompted for password
OSStatus err = [privilegedTask launch];
if (err != errAuthorizationSuccess) {
	if (err == errAuthorizationCanceled) {
	    NSLog(@"User cancelled");
	} else {
	    NSLog(@"Something went wrong");
	}
} else {
	// task successfully launched
}
```

### Getting task output

```objective-c
// ... launch task

[privilegedTask waitUntilExit];

// Read output file handle for data
NSFileHandle *readHandle = [privilegedTask outputFileHandle];
NSData *outputData = [readHandle readDataToEndOfFile];
NSString *outputString = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];

```

### Getting output while task runs in background

```objective-c

// ... launch task

NSFileHandle *readHandle = [privilegedTask outputFileHandle];
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getOutputData:) name:NSFileHandleReadCompletionNotification object:readHandle];
[readHandle readInBackgroundAndNotify];

// ...

- (void)getOutputData:(NSNotification *)aNotification {
    //get data from notification
    NSData *data = [[aNotification userInfo] objectForKey:NSFileHandleNotificationDataItem];
    
    //make sure there's actual data
    if ([data length]) {
        // do something with the data
        
        // go read more data in the background
        [[aNotification object] readInBackgroundAndNotify];
    } else {
        // do something else
    }
}
```

### Notification when task terminates

Observe STPrivilegedTaskDidTerminateNotification.

```objective-c
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(privilegedTaskFinished:) name:STPrivilegedTaskDidTerminateNotification object:nil];

- (void)privilegedTaskFinished:(NSNotification *)aNotification {
	// do something
}
```



# BSD License

```

 # Redistribution and use in source and binary forms, with or without
 # modification, are permitted provided that the following conditions are met:
 #     * Redistributions of source code must retain the above copyright
 #       notice, this list of conditions and the following disclaimer.
 #     * Redistributions in binary form must reproduce the above copyright
 #       notice, this list of conditions and the following disclaimer in the
 #       documentation and/or other materials provided with the distribution.
 #     * Neither the name of Sveinbjorn Thordarson nor that of any other
 #       contributors may be used to endorse or promote products
 #       derived from this software without specific prior written permission.
 # 
 # THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 # ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 # WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 # DISCLAIMED. IN NO EVENT SHALL  BE LIABLE FOR ANY
 # DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 # (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 # LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 # ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 # (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 # SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

```