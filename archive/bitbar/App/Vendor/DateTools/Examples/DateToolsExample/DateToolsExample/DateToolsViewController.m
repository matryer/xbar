//
//  DateToolsViewController.m
//  DateToolsExample
//
//  Created by Matthew York on 3/22/14.
//
//

#import "DateToolsViewController.h"
#import "NSDate+DateTools.h"
#import "Colours.h"

@interface DateToolsViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *MasterScrollView;
@property NSTimer *updateTimer;
@property NSDate *selectedDate;
@property NSDateFormatter *formatter;

//Time Ago View
@property (strong, nonatomic) IBOutlet UIView *TimeAgoView;
@property (weak, nonatomic) IBOutlet UILabel *TimeAgoLabel;
@property (weak, nonatomic) IBOutlet UISlider *TimeAgoSlider;
@property (weak, nonatomic) IBOutlet UILabel *SecondsLabel;
@property (weak, nonatomic) IBOutlet UILabel *MinutesLabel;
@property (weak, nonatomic) IBOutlet UILabel *HoursLabel;
@property (weak, nonatomic) IBOutlet UILabel *DaysLabel;
@property (weak, nonatomic) IBOutlet UILabel *WeeksLabel;
@property (weak, nonatomic) IBOutlet UILabel *MonthsLabel;
@property (weak, nonatomic) IBOutlet UILabel *YearsLabel;

@end

@implementation DateToolsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"NSDate+DateTools";
        self.tabBarItem.title = @"NSDate+DateTools";
        self.tabBarItem.image = [UIImage imageNamed:@"Calendar"];
        self.tabBarItem.selectedImage = [UIImage imageNamed:@"Calendar_filled"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Setup date formatter
    self.formatter = [[NSDateFormatter alloc] init];
    [self.formatter setDateFormat:@"HHmm MMMM d yyyy"];
    
    //Set initial date
    self.selectedDate = [self.formatter dateFromString:@"0000 November 5 1605"];
    self.TimeAgoSlider.value = [self.selectedDate timeIntervalSinceNow];
    
    //Set up timer for updating UI
    self.updateTimer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(updateTimeAgoLabels) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.updateTimer forMode:NSRunLoopCommonModes];
    
    [self setupViews];
    [self updateTimeAgoLabels];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setupViews{
    [self.MasterScrollView addSubview:self.TimeAgoView];
    [self.MasterScrollView setContentSize:self.TimeAgoView.frame.size];
    
    self.SecondsLabel.textColor = [UIColor tealColor];
    self.MinutesLabel.textColor = [UIColor moneyGreenColor];
    self.HoursLabel.textColor = [UIColor salmonColor];
    self.DaysLabel.textColor = [UIColor violetColor];
    self.WeeksLabel.textColor = [UIColor tealColor];
    self.MonthsLabel.textColor = [UIColor waveColor];
    self.YearsLabel.textColor = [UIColor bananaColor];
}

#pragma mark - Update
-(void)updateTimeAgoLabels{
    //Account for now
    if (self.TimeAgoSlider.value == 0) {
        self.selectedDate = [NSDate date];
    }
    
    //Set time ago label
    self.TimeAgoLabel.text = [self.formatter stringFromDate:self.selectedDate];
    
    //Set date component labels
    self.SecondsLabel.text = [NSString stringWithFormat:@"%.0f", self.selectedDate.secondsAgo];
    self.MinutesLabel.text = [NSString stringWithFormat:@"%.0f", self.selectedDate.minutesAgo];
    self.HoursLabel.text = [NSString stringWithFormat:@"%.0f", self.selectedDate.hoursAgo];
    self.DaysLabel.text = [NSString stringWithFormat:@"%ld", (long)self.selectedDate.daysAgo];
    self.WeeksLabel.text = [NSString stringWithFormat:@"%ld", (long)self.selectedDate.weeksAgo];
    self.MonthsLabel.text = [NSString stringWithFormat:@"%ld", (long)self.selectedDate.monthsAgo];
    self.YearsLabel.text = [NSString stringWithFormat:@"%ld", (long)self.selectedDate.yearsAgo];
}

- (IBAction)sliderValueDidChange:(UISlider *)sender {
    self.selectedDate = [NSDate dateWithTimeIntervalSinceNow:sender.value];
    
    //Update UI
    [self updateTimeAgoLabels];
}

@end
