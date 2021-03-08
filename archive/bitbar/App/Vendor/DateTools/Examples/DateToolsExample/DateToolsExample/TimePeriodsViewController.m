//
//  TimePeriodsViewController.m
//  DateToolsExample
//
//  Created by Matthew York on 3/22/14.
//
//

#import "TimePeriodsViewController.h"
#import "DTTimePeriod.h"

@interface TimePeriodsViewController ()
@property (weak, nonatomic) IBOutlet UIView *AView;
@property (weak, nonatomic) IBOutlet UIView *BView;
@property (weak, nonatomic) IBOutlet UIView *CView;

//Relationships
@property (weak, nonatomic) IBOutlet UILabel *ABRelationship;
@property (weak, nonatomic) IBOutlet UILabel *ACRelationship;
@property (weak, nonatomic) IBOutlet UILabel *BARelationship;
@property (weak, nonatomic) IBOutlet UILabel *BCRelationship;
@property (weak, nonatomic) IBOutlet UILabel *CARelationship;
@property (weak, nonatomic) IBOutlet UILabel *CBRelationship;

@end

@implementation TimePeriodsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        // Custom initialization
        self.title = @"Time Periods";
        self.tabBarItem.title = @"Time Periods";
        self.tabBarItem.image = [UIImage imageNamed:@"Recents"];
        self.tabBarItem.selectedImage = [UIImage imageNamed:@"Recents_filled"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //Setup pan recognizers
    UIPanGestureRecognizer *recognizerA = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [recognizerA setMaximumNumberOfTouches:1];
    [recognizerA setMinimumNumberOfTouches:1];
    [self.AView addGestureRecognizer:recognizerA];
    
    UIPanGestureRecognizer *recognizerB = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [recognizerB setMaximumNumberOfTouches:1];
    [recognizerB setMinimumNumberOfTouches:1];
    [self.BView addGestureRecognizer:recognizerB];
    
    UIPanGestureRecognizer *recognizerC = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [recognizerC setMaximumNumberOfTouches:1];
    [recognizerC setMinimumNumberOfTouches:1];
    [self.CView addGestureRecognizer:recognizerC];
    
    //Set initial relationships
    [self updateRelationships];
    
    //Set up info button for alert
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Info" style:UIBarButtonItemStyleBordered target:self action:@selector(showInfo)]];
}

-(void)showInfo{
    [[[UIAlertView alloc] initWithTitle:@"Legend" message:@"Ins. - Inside\nEnc. - Enclosing\n\nFor more information on the various DTTimePeriod relationships, please see the DateTools README on GitHub." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Pan Recognizers


- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer {
    
    CGPoint translation = [recognizer translationInView:self.view];
    recognizer.view.frame = CGRectMake(MAX(10, MIN((self.view.frame.size.width-recognizer.view.frame.size.width - 10), recognizer.view.frame.origin.x + translation.x)), recognizer.view.frame.origin.y, recognizer.view.frame.size.width, recognizer.view.frame.size.height);
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    
    [self updateRelationships];
}

#pragma mark - Update

-(void)updateRelationships{
    NSInteger AOffset = -300 + (self.AView.frame.origin.x - 10);
    NSInteger BOffset = -300 + (self.BView.frame.origin.x - 10);
    NSInteger COffset = -300 + (self.CView.frame.origin.x - 10);
    
    //AOffset *= 4;
    //BOffset *= 4;
    //COffset *= 4;
    
    DTTimePeriod *aPeriod = [DTTimePeriod timePeriodWithStartDate:[NSDate dateWithTimeIntervalSince1970:AOffset] endDate:[NSDate dateWithTimeIntervalSince1970:AOffset+self.AView.frame.size.width]];
    DTTimePeriod *bPeriod = [DTTimePeriod timePeriodWithStartDate:[NSDate dateWithTimeIntervalSince1970:BOffset] endDate:[NSDate dateWithTimeIntervalSince1970:BOffset+self.BView.frame.size.width]];
    DTTimePeriod *cPeriod = [DTTimePeriod timePeriodWithStartDate:[NSDate dateWithTimeIntervalSince1970:COffset] endDate:[NSDate dateWithTimeIntervalSince1970:COffset+self.CView.frame.size.width]];
    
    //Set A relationships
    self.ABRelationship.text = [self stringForRelation:[aPeriod relationToPeriod:bPeriod] forPeriodName:@"B"];
    self.ACRelationship.text = [self stringForRelation:[aPeriod relationToPeriod:cPeriod] forPeriodName:@"C"];
    
    //Set B relationships
    self.BARelationship.text = [self stringForRelation:[bPeriod relationToPeriod:aPeriod] forPeriodName:@"A"];
    self.BCRelationship.text = [self stringForRelation:[bPeriod relationToPeriod:cPeriod] forPeriodName:@"C"];
    
    //Set C relationships
    self.CARelationship.text = [self stringForRelation:[cPeriod relationToPeriod:aPeriod] forPeriodName:@"A"];
    self.CBRelationship.text = [self stringForRelation:[cPeriod relationToPeriod:bPeriod] forPeriodName:@"B"];
    
}

-(NSString *)stringForRelation:(DTTimePeriodRelation)relation forPeriodName:(NSString *)periodName{
    switch (relation) {
        case DTTimePeriodRelationAfter:
            return [NSString stringWithFormat:@"After %@", periodName];
            
        case DTTimePeriodRelationBefore:
            return [NSString stringWithFormat:@"Before %@", periodName];
            
        case DTTimePeriodRelationEnclosing:
            return [NSString stringWithFormat:@"Enclosing %@", periodName];
            
        case DTTimePeriodRelationEnclosingEndTouching:
            return [NSString stringWithFormat:@"Enc. End Touch %@", periodName];
            
        case DTTimePeriodRelationEnclosingStartTouching:
            return [NSString stringWithFormat:@"Enc. Start Touch %@", periodName];
            
        case DTTimePeriodRelationEndInside:
            return [NSString stringWithFormat:@"Ends Inside %@", periodName];
            
        case DTTimePeriodRelationEndTouching:
            return [NSString stringWithFormat:@"Ends Touching %@", periodName];
            
        case DTTimePeriodRelationExactMatch:
            return [NSString stringWithFormat:@"Exact Match %@", periodName];
            
        case DTTimePeriodRelationInside:
            return [NSString stringWithFormat:@"Inside %@", periodName];
            
        case DTTimePeriodRelationInsideEndTouching:
            return [NSString stringWithFormat:@"Ins. End Touch %@", periodName];
            
        case DTTimePeriodRelationInsideStartTouching:
            return [NSString stringWithFormat:@"Ins. Start Touch %@", periodName];
            
        case DTTimePeriodRelationNone:
            return [NSString stringWithFormat:@"No Relation to %@", periodName];
            
        case DTTimePeriodRelationStartInside:
            return [NSString stringWithFormat:@"Starts Inside %@", periodName];
            
        case DTTimePeriodRelationStartTouching:
            return [NSString stringWithFormat:@"Starts Touching %@", periodName];
            
        default:
            break;
    }
    
    typedef NS_ENUM(NSUInteger, DTTimePeriodRelation){
        DTTimePeriodRelationAfter,
        DTTimePeriodRelationStartTouching,
        DTTimePeriodRelationStartInside,
        DTTimePeriodRelationInsideStartTouching,
        DTTimePeriodRelationEnclosingStartTouching,
        DTTimePeriodRelationEnclosing,
        DTTimePeriodRelationEnclosingEndTouching,
        DTTimePeriodRelationExactMatch,
        DTTimePeriodRelationInside,
        DTTimePeriodRelationInsideEndTouching,
        DTTimePeriodRelationEndInside,
        DTTimePeriodRelationEndTouching,
        DTTimePeriodRelationBefore,
        DTTimePeriodRelationNone //One or more of the dates does not exist
    };
}

@end
