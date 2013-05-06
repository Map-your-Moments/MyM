/*
 * MyM: Map Your Moments "A Digital Travelogue"
 *
 * Developed using iOS and AWS for CSC Special Topics: Cloud Computing, Spring 2013 by
 * Adam Cumiskey, Dave Hand, Tim Honeywell, Marcelo Mazzotti, Justin Wagner, and Steven Zilberberg
 *
 * MomentDetailedSecondViewController.m
 * This VC displays some more information about the moments and allows the user
 * to view the content
 */

#import "MomentDetailedSecondViewController.h"
#import "AJNotificationView.h"
#import "S3UtilityClass.h"
#import "Constants.h"

//Standard content view variables
#define MOMENT_CONTENTVIEW_X        20
#define MOMENT_CONTENTVIEW_Y        90
#define MOMENT_CONTENTVIEW_WIDTH    280
#define MOMENT_CONTENTVIEW_HEIGHT   180
#define BANNER_DEFAULT_TIME         2

//Action Sheet Tag
#define kTagActionSheetDeleteMoment 1

//Screeen height
#define screenWidth [[UIScreen mainScreen] applicationFrame].size.width
#define screenHeight [[UIScreen mainScreen] applicationFrame].size.height

@interface MomentDetailedSecondViewController ()
{
    Content *momentContent;         //Holds Content
    NSArray *sections;              //Moment Display Section Headers
    NSArray *momentDataArray;       //Data for each section
    
    NSMutableArray *momentTags;     //Tags of each moment
    
    MPMoviePlayerViewController *moviePlayerView;       //Movie players, two, one for thumbnails, another for actually playing
    MPMoviePlayerController *moviePlayer;
}
@end

@implementation MomentDetailedSecondViewController
@synthesize targetMoment;

//Initilization of class
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

//Sets up view for needed data and content depending on content type

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Creates delete button if user selects own moment
    if([[targetMoment user] isEqualToString:self.currentUser])
        [self createDeleteMomentButton];
    
    //unarchives data
    momentContent = [NSKeyedUnarchiver unarchiveObjectWithData:targetMoment.content];
    momentTags = (NSMutableArray*)[momentContent tags];
    NSString *contentTypeString;
    
    //detemines content type
    switch([momentContent contentType])
    {
        case kTAGMOMENTTEXT:
            contentTypeString = @"Text";
            break;
        case kTAGMOMENTPICTURE:
            contentTypeString = @"Picture";
            break;
        case kTAGMOMENTAUDIO:
            contentTypeString = @"Audio";
            break;
        case kTAGMOMENTVIDEO:
            contentTypeString = @"Video";
            break;
        default:
            contentTypeString = @"Unknown";
            break;
    }
    
    //setup moment data and content from unarchived data
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString = [dateFormatter stringFromDate:[targetMoment date]];
    
    [self setTitle:[targetMoment title]];
    
    NSString *momentTagString = [NSString stringWithFormat:@"Tags: %d", [momentTags count]];
    if([momentTags count] == 0)
        momentTagString = @"No Tags";
    
    sections = [[NSArray alloc] initWithObjects:@"Moment Tags", @"Date Created", @"Moment Created By", @"Moment Type", nil];
    momentDataArray = [[NSArray alloc] initWithObjects:momentTagString , dateString, [targetMoment user], contentTypeString, @"Click to View Moment", nil];
    
    //Puts content in view
    [self setContentFooter:[momentContent contentType]];
}

-(void)setContentFooter:(int)contentType
{
    //Decrypts and sets data into a viewable fashion depending on type
    NSData *rawContent = [momentContent content];
    switch(contentType)
    {
        case kTAGMOMENTTEXT:
        {
            //UIImage *backgroundImage = [UIImage imageNamed:@"notepad_background.png"];
            UITextView *momentText = [[UITextView alloc]initWithFrame:CGRectMake(0, 0, 280, 180)];
            [momentText setTag:kTAGMOMENTTEXT];
            [momentText setBackgroundColor:[UIColor colorWithRed:242 green:242 blue:128 alpha:1.0]];
            [momentText setFont:[UIFont fontWithName:@"Arial" size:24]];
            NSString *dataString = [NSString stringWithUTF8String:[rawContent bytes]];
            [momentText setText:dataString];
            [momentText setEditable:NO];
            self.tableView.tableHeaderView = momentText;
            break;
        }
        case kTAGMOMENTPICTURE:
        {
            UIImage *picture = [UIImage imageWithData:rawContent];
            UIImageView *momentImage = [[UIImageView alloc] initWithImage:picture];
            [momentImage setFrame:CGRectMake(0, 0, 360, 410)];
            self.tableView.tableHeaderView = momentImage;
            break;
        }
        case kTAGMOMENTAUDIO:
        {
            break;
        }
        case kTAGMOMENTVIDEO:
        {
            //Save NSData to URL locally
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *appFile = [documentsDirectory stringByAppendingPathComponent:@"MyFile.m4v"];
            [rawContent writeToFile:appFile atomically:YES];
            
            //Initiate movieplayer and movieplayerview. First for thumbnail and second for what plays it
            moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:appFile]];
            moviePlayerView = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:appFile]];
            moviePlayer.shouldAutoplay = NO;
            
            //create thumbnail
            UIImage *thumbnail = [UIImage imageNamed:@"playButton.png"];//[moviePlayer thumbnailImageAtTime:1.0 timeOption:MPMovieTimeOptionNearestKeyFrame];
            
            UIImageView *momentImage = [[UIImageView alloc] initWithImage:thumbnail];
            [momentImage setFrame:CGRectMake(0, 0, 100, 100)];
            
            //add tap to play gesture to image
            [momentImage setUserInteractionEnabled:YES];
            UITapGestureRecognizer *tapPlayMovie = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playMovie)];
            [tapPlayMovie setNumberOfTapsRequired:1];
            [tapPlayMovie setNumberOfTouchesRequired:1];
            [momentImage addGestureRecognizer:tapPlayMovie];
            
            self.tableView.tableHeaderView = momentImage;
            
            break;
        }
        default:
        {
            //NSLog(@"Error");
            break;
        }
    }
}

//Plays movie
-(void)playMovie
{
    [self presentMoviePlayerViewControllerAnimated:moviePlayerView];
    
    moviePlayerView.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
    [moviePlayerView.moviePlayer play];
}

//If running low on memeny
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//If user switches view while notification is still visable
- (void)viewDidDisappear:(BOOL)animated
{
    [AJNotificationView hideCurrentNotificationViewAndClearQueue];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section != 5)
        return 1;
    else
        return 0;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [sections objectAtIndex:section];
}

//Puts data into each part of table
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"Cell Identification";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if(cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    NSString *cellData;
    switch([indexPath section])
    {
        case 0:
            cell.autoresizesSubviews = YES;
            cellData = [self createTagString];
            break;
        case 1:
            cellData = [momentDataArray objectAtIndex:1];
            break;
        case 2:
            cellData = [momentDataArray objectAtIndex:2];
            break;
        case 3:
            cellData = [momentDataArray objectAtIndex:3];
            break;
        case 4:
            //cellData = [momentDataArray objectAtIndex:4];
            break;
        default:
            //NSLog(@"ERROR");
            break;
    }
    
    cell.textLabel.text = cellData;
    
    return cell;
}

//creats a CSV style string
-(NSString*)createTagString
{
    NSString *output = @"";
    for(int c = 0; c < [momentTags count]; c++)
    {
        if(c != 0 && c != [momentTags count])
            output = [output stringByAppendingString:@", "];
        NSString *stringTag = (NSString*)[momentTags objectAtIndex:c];
        output = [output stringByAppendingString:stringTag];
    }
    return output;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Delete moment

//sets to delete moment
-(void)deleteMoment
{
    [S3UtilityClass removeMomentFromS3:targetMoment];
    [self.navigationController popViewControllerAnimated:YES];
}

//Creates delete button
- (void)createDeleteMomentButton
{
    // create a UIButton (Delete Moment button)
    UIImage *deleteImage = [UIImage imageNamed:@"delete~iphone.png"];
    UIButton *btnDelete = [UIButton buttonWithType:UIButtonTypeCustom];
    btnDelete.frame = CGRectMake(-10, 25, self.view.bounds.size.width - 20, 40);
    btnDelete.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    btnDelete.titleLabel.shadowColor = [UIColor lightGrayColor];
    btnDelete.titleLabel.shadowOffset = CGSizeMake(0, -1);
    [btnDelete setTitle:@"Delete Moment" forState:UIControlStateNormal];
    [btnDelete setBackgroundImage:[deleteImage resizableImageWithCapInsets:UIEdgeInsetsMake(20, 5, 5 ,5)] forState:UIControlStateNormal];
    [btnDelete setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnDelete addTarget:self action:@selector(deleteMomentButton) forControlEvents:UIControlEventTouchUpInside];
    
    //create a footer view on the bottom of the tabeview
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(20, 0, 280, 100)];
    [footerView addSubview:btnDelete];
    
    self.tableView.tableFooterView = footerView;
}

//Deletes moment
- (void)deleteMomentButton
{
    [self deleteMomentAlert:self];
}

//Delete Confirmation
- (IBAction)deleteMomentAlert:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Deleting Moment"
                          message:@"Are you sure you want to permanently delete this moment?"
                          delegate:self
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@"Confirm", nil];
    alert.tag = kUIAlertDeleteMoment;
    [alert show];
}

//Confirmation
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(alertView.tag == kUIAlertDeleteMoment && buttonIndex == 0)
    {
        return;
    }
    if(alertView.tag == kUIAlertDeleteMoment && buttonIndex == 1)
    {
        [self deleteMoment];
    }
}

@end