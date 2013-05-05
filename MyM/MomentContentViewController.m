/*
 * MyM: Map Your Moments "A Digital Travelogue"
 *
 * Developed using iOS and AWS for CSC Special Topics: Cloud Computing, Spring 2013 by
 * Adam Cumiskey, Dave Hand, Tim Honeywell, Marcelo Mazzotti, Justin Wagner, and Steven Zilberberg
 *
 * MomentContentViewController.m
 * This view controller displays the content for a moment.
 *
 */

#import "MomentContentViewController.h"
#import "Constants.h"

#define MOMENT_CONTENTVIEW_X        20
#define MOMENT_CONTENTVIEW_Y        90
#define MOMENT_CONTENTVIEW_WIDTH    280
#define MOMENT_CONTENTVIEW_HEIGHT   180

@interface MomentContentViewController ()
{
    NSData *rawContent;
    int contentType;
}

@end

@implementation MomentContentViewController
@synthesize momentContent;

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
    
    [self.navigationController setNavigationBarHidden:NO];
    
    contentType = [momentContent contentType];
    contentType = kTAGMOMENTTEXT;
    rawContent = [momentContent content];
    
    switch(contentType)
    {
        case kTAGMOMENTTEXT:
        {
            UIImage *backgroundImage = [UIImage imageNamed:@"notepad_background.png"];
            UITextView *momentText = [[UITextView alloc]initWithFrame:CGRectMake(MOMENT_CONTENTVIEW_X, MOMENT_CONTENTVIEW_Y, 280, 180)];
            [momentText setTag:kTAGMOMENTTEXT];
            [momentText setBackgroundColor:[UIColor colorWithPatternImage:backgroundImage]];
            [momentText setFont:[UIFont fontWithName:@"Arial" size:24]];
            NSString *dataString = nil;
            @try
            {
                dataString = [NSString stringWithUTF8String:[rawContent bytes]];
            }
            @catch(NSException *ex)
            {
                NSLog(@"%@",ex.description);
            }
            [momentText setText:dataString];
            [self.view addSubview:momentText];
            break;
        }
        case kTAGMOMENTPICTURE:
        {
            UIImageView *momentView = [[UIImageView alloc] init];
            [momentView setImage:[UIImage imageWithData:rawContent]];
            break;
        }
        case kTAGMOMENTAUDIO:
        {
            break;
        }
        case kTAGMOMENTVIDEO:
        {
            break;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
