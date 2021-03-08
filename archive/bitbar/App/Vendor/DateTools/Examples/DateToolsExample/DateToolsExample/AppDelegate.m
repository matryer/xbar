//
//  AppDelegate.m
//  DateToolsExample
//
//  Created by Matthew York on 3/19/14.
//
//

#import "AppDelegate.h"
#import "Colours.h"
#import "ExampleNavigationController.h"
#import "DateToolsViewController.h"
#import "TimePeriodsViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    [self initializeTabBarController];
    
    [self.window setRootViewController:self.tabBarController];
    [self.window makeKeyAndVisible];
    
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)initializeTabBarController{
    ExampleNavigationController *dtVC = [[ExampleNavigationController alloc] initWithRootViewController:[[DateToolsViewController alloc] initWithNibName:@"DateToolsViewController" bundle:nil]];
    
    ExampleNavigationController *tpVC = [[ExampleNavigationController alloc] initWithRootViewController:[[TimePeriodsViewController alloc] initWithNibName:@"TimePeriodsViewController" bundle:nil]];
    
    //Initialize tab bar controller
    self.tabBarController = [[UITabBarController alloc] init];
    
    //Style tab bar
    if ([self.tabBarController.tabBar respondsToSelector:@selector(setTranslucent:)]) {
        [self.tabBarController.tabBar setTranslucent:NO];
        [self.tabBarController.tabBar setTintColor:[UIColor infoBlueColor]];
    }
    else {
        [self.tabBarController.tabBar setBackgroundColor:[UIColor infoBlueColor]];
    }
    
    //Add view controllers
    self.tabBarController.viewControllers = @[dtVC, tpVC];
}

@end
