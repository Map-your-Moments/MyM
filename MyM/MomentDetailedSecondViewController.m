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

#define MOMENT_CONTENTVIEW_X        20
#define MOMENT_CONTENTVIEW_Y        90
#define MOMENT_CONTENTVIEW_WIDTH    280
#define MOMENT_CONTENTVIEW_HEIGHT   180
#define BANNER_DEFAULT_TIME         2

#define kTagActionSheetDeleteMoment 1

#define screenWidth [[UIScreen mainScreen] applicationFrame].size.width
#define screenHeight [[UIScreen mainScreen] applicationFrame].size.height

@interface MomentDetailedSecondViewController ()
{
    Content *momentContent;
    NSArray *sections;
    NSArray *momentDataArray;
    
    NSMutableArray *momentTags;
    
    MPMoviePlayerViewController *moviePlayerView;
    MPMoviePlayerController *moviePlayer;
}
@end

@implementation MomentDetailedSecondViewController
@synthesize targetMoment;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if([[targetMoment user] isEqualToString:self.currentUser])
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Delete Moment" style:UIBarButtonItemStyleDone target:self action:@selector(deleteMoment)];
    
    momentContent = [NSKeyedUnarchiver unarchiveObjectWithData:targetMoment.content];
    momentTags = (NSMutableArray*)[momentContent tags];
    NSString *contentTypeString;
    
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
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString = [dateFormatter stringFromDate:[targetMoment date]];
    
    [self setTitle:[targetMoment title]];
    
    NSString *momentTagString = [NSString stringWithFormat:@"Tags: %d", [momentTags count]];
    
    sections = [[NSArray alloc] initWithObjects:@"Moment Tags", @"Date Created", @"Moment Created By", @"Moment Type", nil];
    NSLog(@"Number of Tags: %d", [momentTags count]);
    momentDataArray = [[NSArray alloc] initWithObjects:momentTagString , dateString, [targetMoment user], contentTypeString, @"Click to View Moment", nil];
    
    [self setContentFooter:[momentContent contentType]];
}

-(void)setContentFooter:(int)contentType
{
    NSData *rawContent = [momentContent content];
    switch(contentType)
    {
        case kTAGMOMENTTEXT:
        {
            //UIImage *backgroundImage = [UIImage imageNamed:@"notepad_background.png"];
            UITextView *momentText = [[UITextView alloc]initWithFrame:CGRectMake(0, 0, 280, 180)];
            [momentText setTag:kTAGMOMENTTEXT];
            [momentText setBackgroundColor:[UIColor colorWithRed:242 green:242 blue:128 alpha:1.0]];//[UIColor colorWithPatternImage:backgroundImage]];
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

-(void)playMovie
{
    [self presentMoviePlayerViewControllerAnimated:moviePlayerView];
    
    moviePlayerView.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
    [moviePlayerView.moviePlayer play];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)deleteMoment
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Are you sure you want to delete %@?", [targetMoment title]] delegate:self cancelButtonTitle:@"No" destructiveButtonTitle:@"Yes" otherButtonTitles:nil];
    [actionSheet setTag:kTagActionSheetDeleteMoment];
    [actionSheet showInView:self.view];
}

#pragma mark UIActionSheet Delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([actionSheet tag] == kTagActionSheetDeleteMoment)
    {
        if(buttonIndex == [actionSheet destructiveButtonIndex])
        {
             [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeRed title:@"Your moment is being deleted" hideAfter:BANNER_DEFAULT_TIME];
             [S3UtilityClass removeMomentFromS3:targetMoment];
             [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"Cell Identification";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if(cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    
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

@end