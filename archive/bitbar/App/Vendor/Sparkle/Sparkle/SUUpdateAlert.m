//
//  SUUpdateAlert.m
//  Sparkle
//
//  Created by Andy Matuschak on 3/12/06.
//  Copyright 2006 Andy Matuschak. All rights reserved.
//

// -----------------------------------------------------------------------------
//	Headers:
// -----------------------------------------------------------------------------

#import "SUUpdateAlert.h"

#import "SUHost.h"
#import <WebKit/WebKit.h>

#import "SUConstants.h"
#import "SULog.h"

// WebKit protocols are not explicitly declared until 10.11 SDK, so
// declare dummy protocols to keep the build working on earlier SDKs.
#if __MAC_OS_X_VERSION_MAX_ALLOWED < 101100
@protocol WebFrameLoadDelegate <NSObject>
@end
@protocol WebPolicyDelegate <NSObject>
@end
#endif

@interface SUUpdateAlert () <WebFrameLoadDelegate, WebPolicyDelegate>

@property (strong) SUAppcastItem *updateItem;
@property (strong) SUHost *host;
@property (strong) void(^completionBlock)(SUUpdateAlertChoice);

@property (strong) NSProgressIndicator *releaseNotesSpinner;
@property (assign) BOOL webViewFinishedLoading;

@property (weak) IBOutlet WebView *releaseNotesView;
@property (weak) IBOutlet NSView *releaseNotesContainerView;
@property (weak) IBOutlet NSTextField *descriptionField;
@property (weak) IBOutlet NSButton *automaticallyInstallUpdatesButton;
@property (weak) IBOutlet NSButton *installButton;
@property (weak) IBOutlet NSButton *skipButton;
@property (weak) IBOutlet NSButton *laterButton;

@end

@implementation SUUpdateAlert

@synthesize completionBlock;
@synthesize versionDisplayer;

@synthesize updateItem;
@synthesize host;

@synthesize releaseNotesSpinner;
@synthesize webViewFinishedLoading;

@synthesize releaseNotesView;
@synthesize releaseNotesContainerView;
@synthesize descriptionField;
@synthesize automaticallyInstallUpdatesButton;
@synthesize installButton;
@synthesize skipButton;
@synthesize laterButton;

- (instancetype)initWithAppcastItem:(SUAppcastItem *)item host:(SUHost *)aHost completionBlock:(void (^)(SUUpdateAlertChoice))block
{
    self = [super initWithWindowNibName:@"SUUpdateAlert"];
	if (self)
	{
        self.completionBlock = block;
        host = aHost;
        updateItem = item;
        [self setShouldCascadeWindows:NO];

        // Alex: This dummy line makes sure that the binary is linked against WebKit.
        // The SUUpdateAlert.xib file contains a WebView and if we don't link against WebKit,
        // we will get a runtime crash when decoding the NIB. It is better to get a link error.
        [WebView MIMETypesShownAsHTML];
    }
    return self;
}

- (NSString *)description { return [NSString stringWithFormat:@"%@ <%@>", [self class], [self.host bundlePath]]; }


- (void)endWithSelection:(SUUpdateAlertChoice)choice
{
    [self.releaseNotesView stopLoading:self];
    [self.releaseNotesView setFrameLoadDelegate:nil];
    [self.releaseNotesView setPolicyDelegate:nil];
    [self.releaseNotesView removeFromSuperview]; // Otherwise it gets sent Esc presses (why?!) and gets very confused.
    [self close];
    self.completionBlock(choice);
    self.completionBlock = nil;
}

- (IBAction)installUpdate:(id)__unused sender
{
    [self endWithSelection:SUInstallUpdateChoice];
}

- (IBAction)openInfoURL:(id)__unused sender
{
    [self endWithSelection:SUOpenInfoURLChoice];
}

- (IBAction)skipThisVersion:(id)__unused sender
{
    [self endWithSelection:SUSkipThisVersionChoice];
}

- (IBAction)remindMeLater:(id)__unused sender
{
    [self endWithSelection:SURemindMeLaterChoice];
}

- (void)displayReleaseNotes
{
    self.releaseNotesView.preferencesIdentifier = SUBundleIdentifier;
    WebPreferences *prefs = [self.releaseNotesView preferences];
    prefs.plugInsEnabled = NO;
    prefs.javaEnabled = NO;
    prefs.javaScriptEnabled = [self.host boolForInfoDictionaryKey:SUEnableJavaScriptKey];
    self.releaseNotesView.frameLoadDelegate = self;
    self.releaseNotesView.policyDelegate = self;
    
    // Set the default font
    // "-apple-system-font" is a reference to the system UI font. "-apple-system" is the new recommended token, but for backward compatibility we can't use it.
    prefs.standardFontFamily = @"-apple-system-font";
    prefs.defaultFontSize = (int)[NSFont systemFontSize];

    // Stick a nice big spinner in the middle of the web view until the page is loaded.
    NSRect frame = [[self.releaseNotesView superview] frame];
    self.releaseNotesSpinner = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(NSMidX(frame) - 16, NSMidY(frame) - 16, 32, 32)];
    [self.releaseNotesSpinner setStyle:NSProgressIndicatorSpinningStyle];
    [self.releaseNotesSpinner startAnimation:self];
    self.webViewFinishedLoading = NO;
    [[self.releaseNotesView superview] addSubview:self.releaseNotesSpinner];

    // If there's a release notes URL, load it; otherwise, just stick the contents of the description into the web view.
	if ([self.updateItem releaseNotesURL])
	{
        [[self.releaseNotesView mainFrame] loadRequest:[NSURLRequest requestWithURL:[self.updateItem releaseNotesURL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30]];
	}
	else
	{
        [[self.releaseNotesView mainFrame] loadHTMLString:[self.updateItem itemDescription] baseURL:nil];
    }
}

- (BOOL)showsReleaseNotes
{
    NSNumber *shouldShowReleaseNotes = [self.host objectForInfoDictionaryKey:SUShowReleaseNotesKey];
	if (shouldShowReleaseNotes == nil)
	{
        // Don't show release notes if RSS item contains no description and no release notes URL:
        return (([self.updateItem itemDescription] != nil
                 && [[[self.updateItem itemDescription] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] > 0)
                || [self.updateItem releaseNotesURL] != nil);
	}
	else
        return [shouldShowReleaseNotes boolValue];
}

- (BOOL)allowsAutomaticUpdates
{
    return self.host.allowsAutomaticUpdates;
}

- (void)windowDidLoad
{
    BOOL showReleaseNotes = [self showsReleaseNotes];

    [self.window setFrameAutosaveName: showReleaseNotes ? @"SUUpdateAlert" : @"SUUpdateAlertSmall" ];

    if ([self.host isBackgroundApplication]) {
        [self.window setLevel:NSFloatingWindowLevel]; // This means the window will float over all other apps, if our app is switched out ?!
    }

    if (self.updateItem.isInformationOnlyUpdate) {
        [self.installButton setTitle:SULocalizedString(@"Learn More...", @"Alternate title for 'Install Update' button when there's no download in RSS feed.")];
        [self.installButton setAction:@selector(openInfoURL:)];
    }

    if (showReleaseNotes) {
        [self displayReleaseNotes];
    } else {
        NSLayoutConstraint *automaticallyInstallUpdatesButtonToDescriptionFieldConstraint = [NSLayoutConstraint constraintWithItem:self.automaticallyInstallUpdatesButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.descriptionField attribute:NSLayoutAttributeBottom multiplier:1.0 constant:8.0];
        
        [self.window.contentView addConstraint:automaticallyInstallUpdatesButtonToDescriptionFieldConstraint];
        
        [self.releaseNotesContainerView removeFromSuperview];
    }
    
    // When we show release notes, it looks ugly if the install buttons are not closer to the release notes view
    // However when we don't show release notes, it looks ugly if the install buttons are too close to the description field. Shrugs.
    if (showReleaseNotes && ![self allowsAutomaticUpdates]) {
        NSLayoutConstraint *skipButtonToReleaseNotesContainerConstraint = [NSLayoutConstraint constraintWithItem:self.skipButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.releaseNotesContainerView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:12.0];
        
        [self.window.contentView addConstraint:skipButtonToReleaseNotesContainerConstraint];
        
        [self.automaticallyInstallUpdatesButton removeFromSuperview];
    }

    [self.window center];
}

- (BOOL)windowShouldClose:(NSNotification *) __unused note
{
	[self endWithSelection:SURemindMeLaterChoice];
	return YES;
}

- (NSImage *)applicationIcon
{
    return [self.host icon];
}

- (NSString *)titleText
{
    return [NSString stringWithFormat:SULocalizedString(@"A new version of %@ is available!", nil), [self.host name]];
}

- (NSString *)descriptionText
{
    NSString *updateItemVersion = [self.updateItem displayVersionString];
    NSString *hostVersion = [self.host displayVersion];
    // Display more info if the version strings are the same; useful for betas.
    if (!self.versionDisplayer && [updateItemVersion isEqualToString:hostVersion] ) {
        updateItemVersion = [updateItemVersion stringByAppendingFormat:@" (%@)", [self.updateItem versionString]];
        hostVersion = [hostVersion stringByAppendingFormat:@" (%@)", self.host.version];
    } else {
        [self.versionDisplayer formatVersion:&updateItemVersion andVersion:&hostVersion];
    }

    // We display a slightly different summary depending on if it's an "info-only" item or not
    NSString *finalString = nil;

    if (self.updateItem.isInformationOnlyUpdate) {
        finalString = [NSString stringWithFormat:SULocalizedString(@"%@ %@ is now available--you have %@. Would you like to learn more about this update on the web?", @"Description text for SUUpdateAlert when the update informational with no download."), self.host.name, updateItemVersion, hostVersion];
    } else {
        finalString = [NSString stringWithFormat:SULocalizedString(@"%@ %@ is now available--you have %@. Would you like to download it now?", @"Description text for SUUpdateAlert when the update is downloadable."), self.host.name, updateItemVersion, hostVersion];
    }
    return finalString;
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:frame
{
    if ([frame parentFrame] == nil) {
        self.webViewFinishedLoading = YES;
        [self.releaseNotesSpinner setHidden:YES];
        [sender display]; // necessary to prevent weird scroll bar artifacting
    }
}

- (void)webView:(WebView *)__unused sender decidePolicyForNavigationAction:(NSDictionary *)__unused actionInformation request:(NSURLRequest *)request frame:(WebFrame *)__unused frame decisionListener:(id<WebPolicyDecisionListener>)listener
{
    NSURL *requestURL = request.URL;
    NSString *scheme = requestURL.scheme;
    BOOL whitelistedSafe = [scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"] || [requestURL.absoluteString isEqualToString:@"about:blank"];

    // Do not allow redirects to dangerous protocols such as file://
    if (!whitelistedSafe) {
        SULog(@"Blocked display of %@ URL which may be dangerous", scheme);
        [listener ignore];
        return;
    }

    if (self.webViewFinishedLoading) {
        if (requestURL) {
            [[NSWorkspace sharedWorkspace] openURL:requestURL];
        }

        [listener ignore];
    }
    else {
        [listener use];
    }
}

// Clean up the contextual menu.
- (NSArray *)webView:(WebView *)__unused sender contextMenuItemsForElement:(NSDictionary *)__unused element defaultMenuItems:(NSArray *)defaultMenuItems
{
    NSMutableArray *webViewMenuItems = [defaultMenuItems mutableCopy];

	if (webViewMenuItems)
	{
		for (NSMenuItem *menuItem in defaultMenuItems)
		{
            NSInteger tag = [menuItem tag];

			switch (tag)
			{
                case WebMenuItemTagOpenLinkInNewWindow:
                case WebMenuItemTagDownloadLinkToDisk:
                case WebMenuItemTagOpenImageInNewWindow:
                case WebMenuItemTagDownloadImageToDisk:
                case WebMenuItemTagOpenFrameInNewWindow:
                case WebMenuItemTagGoBack:
                case WebMenuItemTagGoForward:
                case WebMenuItemTagStop:
                case WebMenuItemTagReload:
                    [webViewMenuItems removeObjectIdenticalTo:menuItem];
            }
        }
    }

    return webViewMenuItems;
}

@end
