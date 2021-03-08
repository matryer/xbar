//
//  ExampleNavigationController.m
//  DateToolsExample
//
//  Created by Matthew York on 3/22/14.
//
//

#import "ExampleNavigationController.h"
#import "Colours.h"

@interface ExampleNavigationController ()

@end

@implementation ExampleNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if ([self.navigationBar respondsToSelector:@selector(setTranslucent:)]) {
        self.navigationBar.translucent = NO;
        self.navigationBar.barTintColor = [UIColor infoBlueColor];
        self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:21.0]};
        [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

@end
