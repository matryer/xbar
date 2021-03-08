


# LaunchAtLoginController (using ARC)

A modified version of the original by Mozketo (at https://github.com/Mozketo/LaunchAtLoginController) with support for ARC (Automatic Reference Counting). Tested on Mac OSX 10.8.3 without any problems.

## Description:

A very simple controller for use in Cocoa Mac Apps to register/deregister itself for Launch at Login using LSSharedFileList (In simple terms, helps your Cocoa/Objective-C App to launch automatically at login).

It uses LSSharedFileList which means your Users will be able to check/uncheck your App in System Preferences > Accounts > Login Items.

## IMPLEMENTATION (via Code):

### Will app launch at login?
	
	//don't forget to add  #import "LaunchAtLoginController.h" to your implementation file.

    LaunchAtLoginController *launchController = [[LaunchAtLoginController alloc] init];
	BOOL launch = [launchController launchAtLogin];


### Set launch at login state.

	LaunchAtLoginController *launchController = [[LaunchAtLoginController alloc] init];
	[launchController setLaunchAtLogin:YES];


## IMPLEMENTATION (via the Interface Builder):

* Open Interface Builder
* Place a NSObject (the blue box) into the nib window
* From the Inspector - Identity Tab set the Class to LaunchAtLoginController
* Place a Checkbox on your Window/View
* From the Inspector - Bindings Tab unroll the > Value item
  * Bind to Launch at Login Controller
  * Model Key Path: launchAtLogin

## IS IT WORKING:

After implementing either through code or through IB, setLaunchAtLogin:YES and then check System Preferences > Accounts > Login Items. You should see your app in the list of apps that will start when the user logs in.

## CAVEATS (HelperApp Bundles):

If you're trying to set a different bundle (perhaps a HelperApp as a resource to your main bundle) you will simply want to change 
    - (NSURL *)appURL 
to return the path to this other bundle.

## REQUIREMENTS:

None

Last tested on 16th May 2013, XCode 4.6.1, Mac OSX 10.8.3

## ORIGINAL CODE:

The original version is by Mozketo (at https://github.com/Mozketo/LaunchAtLoginController). The credits for all of the code goes to him, and whoever is mentioned in his repository. The only thing I've done is modified it to work with ARC (Automatic Reference Counting) enabled.

## LICENSE:

(The MIT License)

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
