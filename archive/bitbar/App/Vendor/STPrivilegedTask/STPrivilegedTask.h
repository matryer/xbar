/*
 #
 # STPrivilegedTask - NSTask-like wrapper around AuthorizationExecuteWithPrivileges
 # Copyright (C) 2009-2015 Sveinbjorn Thordarson <sveinbjornt@gmail.com>
 #
 # BSD License
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
 */

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>
#import <Security/Authorization.h>
#import <Security/AuthorizationTags.h>

#define STPrivilegedTaskDidTerminateNotification @"STPrivilegedTaskDidTerminateNotification"
//#define TMP_STDERR_TEMPLATE @".authStderr.XXXXXX"

// Defines error value for when AuthorizationExecuteWithPrivilleges no longer
// exists anyplace. Rather than defining a new enum, we just create a global
// constant
extern const OSStatus errAuthorizationFnNoLongerExists;

@interface STPrivilegedTask : NSObject 
{
    NSArray         *arguments;
    NSString        *cwd;
    NSString        *launchPath;
    BOOL            isRunning;
    pid_t           pid;
    int             terminationStatus;
    NSFileHandle    *outputFileHandle;
    NSTimer         *checkStatusTimer;
}
-(id)initWithLaunchPath:(NSString *)path;
-(id)initWithLaunchPath:(NSString *)path arguments:  (NSArray *)args;
+(STPrivilegedTask *)launchedPrivilegedTaskWithLaunchPath:(NSString *)path;
+(STPrivilegedTask *)launchedPrivilegedTaskWithLaunchPath:(NSString *)path arguments:(NSArray *)arguments;
-(NSArray *)arguments;
-(NSString *)currentDirectoryPath;
-(BOOL)isRunning;
-(int)launch;
-(NSString *)launchPath;
-(int)processIdentifier;
-(void)setArguments:(NSArray *)arguments;
-(void)setCurrentDirectoryPath:(NSString *)path;
-(void)setLaunchPath:(NSString *)path;
-(NSFileHandle *)outputFileHandle;
-(void)terminate;  // doesn't work
-(int)terminationStatus;
-(void)_checkTaskStatus;
-(void)waitUntilExit;
@end
/*static OSStatus AuthorizationExecuteWithPrivilegesStdErrAndPid (
                                                                AuthorizationRef authorization,
                                                                const char *pathToTool,
                                                                AuthorizationFlags options,
                                                                char * const *arguments,
                                                                FILE **communicationsPipe,
                                                                FILE **errPipe,
                                                                pid_t* processid
                                                                );*/
