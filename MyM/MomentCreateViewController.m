/*
 * MyM: Map Your Moments "A Digital Travelogue"
 *
 * Developed using iOS and AWS for CSC Special Topics: Cloud Computing, Spring 2013 by
 * Adam Cumiskey, Dave Hand, Tim Honeywell, Marcelo Mazzotti, Justin Wagner, and Steven Zilberberg
 *
 * MomentCreateViewController.m
 * View Controller from which moments are created
 *
 */

#import "MomentCreateViewController.h"
#import "AJNotificationView.h"
#import "Constants.h"

#define BANNER_DEFAULT_TIME 3
#define SCREEN_HEIGHT [[UIScreen mainScreen] applicationFrame].size.height

#define MOMENT_CONTENTVIEW_X        20
#define MOMENT_CONTENTVIEW_Y        90
#define MOMENT_CONTENTVIEW_WIDTH    280
#define MOMENT_CONTENTVIEW_HEIGHT   180

#define MOMENT_IMAGEVIEW_MISSINGCONTENT     1
#define MOMENT_IMAGEVIEW_HASCONTENT         2

@interface MomentCreateViewController ()
{
    bool hasContentSet;         //Content is set
    
    UITextView *momentText;         //Moment vieweres
    UIImageView *momentImage;
    
    MPMoviePlayerViewController *moviePlayer;       //movie player
    AVAudioRecorder *recorder;                      //sound recorder

    UIView *recorderView;               //Recorder stop view
    
    NSURL *takenVideoURL;           //Urls for files fo taken media
    NSURL *takenAudioURL;
    
    UIButton *playButton;               //Play button for video
}

@end

@implementation MomentCreateViewController
@synthesize captionTextField;
@synthesize tagTextField;

@synthesize contentType;
@synthesize currentLocation;
@synthesize currentUser;

NSString *kStillImages = @"public.image";               //String constants
NSString *kVideoCamera = @"public.movie";
NSString *kMomemtAudio_temp = @"MomemtAudio_temp";

//Initilizer
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//Set up gesture for hiding keyboard, nulls objects and detects moment type
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [self nillObjects];
    
    UITapGestureRecognizer *tapHideKeyboard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [tapHideKeyboard setNumberOfTapsRequired:1];
    [tapHideKeyboard setNumberOfTouchesRequired:1];
    [self.view addGestureRecognizer:tapHideKeyboard];
    
    [self nillObjects];
    
    //Setup navigation view with title and submit button
    [self setTitle:@"Create Moment"];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Share" style:UIBarButtonItemStyleDone target:self action:@selector(share)];
    
    [self detectMomentType];
}

//presents content styles for each type of moment
-(void)detectMomentType
{
    if(momentImage == nil)
        hasContentSet = NO;
    
    if(contentType == kTAGMOMENTTEXT)
    {
        [self presentText];
    }
    else if(contentType == kTAGMOMENTPICTURE)
    {
        [self presentImage];
    }
    else if(contentType == kTAGMOMENTAUDIO)
    {
        [self presentAudio];
    }
    else if(contentType == kTAGMOMENTVIDEO)
    {
        [self presentVideo];
    }
}

//Creates Text input for text moment
-(void)presentText
{
    if(momentText == nil)
    {
        //UIImage *backgroundImage = [UIImage imageNamed:@"notepad_background.png"];
        momentText = [[UITextView alloc]initWithFrame:CGRectMake(MOMENT_CONTENTVIEW_X, MOMENT_CONTENTVIEW_Y, 280, 180)];
        [momentText setTag:kTAGMOMENTTEXT];
        [momentText setBackgroundColor:[UIColor colorWithRed:242 green:242 blue:128 alpha:1.0]];
        [momentText setFont:[UIFont fontWithName:@"Arial" size:24]];
        [self.view addSubview:momentText];
    }
}

//Presents an image controller for still images
-(void)presentImage
{
    if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Camera Detected" message:@"Your device doesn't have a camera." delegate:self cancelButtonTitle:@"Darn..." otherButtonTitles:nil];
        [alert setTag:kUIAlertViewMomentNoCamera];
        [alert show];
        return;
    }
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    [pickerController setDelegate:self];
    [pickerController setMediaTypes:[NSArray arrayWithObject:kStillImages]];
    [pickerController setSourceType:UIImagePickerControllerSourceTypeCamera];
    [self presentViewController:pickerController animated:YES completion:NULL];
}

//Presents an image controller for audio
//Puts a recognizer for stopping audio
-(void)presentAudio
{
    recorderView = [[UIView alloc]initWithFrame:CGRectMake(135, 214, 75, 75)];
    [recorderView setBackgroundColor:[UIColor greenColor]];
    UIImageView *recorderImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 75, 75)];
    [recorderImageView setImage:[UIImage imageNamed:@"siri-logo.png"]];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(stopRecording)];
    [tapGesture setNumberOfTapsRequired:1];
    [tapGesture setNumberOfTouchesRequired:1];
    [recorderImageView addGestureRecognizer:tapGesture];
    [recorderImageView setUserInteractionEnabled:YES];
    [recorderView addSubview:recorderImageView];
    [self.view addSubview:recorderView];
    
    
    takenAudioURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:kMomemtAudio_temp]];
    
    recorder = [[AVAudioRecorder alloc] initWithURL:takenAudioURL settings:nil error:nil];
    [recorder setDelegate:self];
    [recorder prepareToRecord];
    [recorder record];
    
    //NSLog(@"*Recording*");
}

//Presents an image controller for videos
-(void)presentVideo
{
    if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Camera Detected" message:@"Your device doesn't have a camera." delegate:self cancelButtonTitle:@"Darn..." otherButtonTitles:nil];
        [alert setTag:kUIAlertViewMomentNoCamera];
        [alert show];
        return;
    }
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    [pickerController setVideoMaximumDuration:5];
    [pickerController setDelegate:self];
    [pickerController setMediaTypes:[NSArray arrayWithObject:kVideoCamera]];
    [pickerController setSourceType:UIImagePickerControllerSourceTypeCamera];
    [self presentViewController:pickerController animated:YES completion:NULL];
}

//Shares moments by assembling data and getting it ready to pass to S3
-(void)share
{
    //Gets string data
    NSString *title = [[self.captionTextField text]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSMutableArray *tags = (NSMutableArray*)[[self.tagTextField text] componentsSeparatedByString:@" "];
    NSDate *currentDate = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
    
    //Sets up moment rawData
    NSData *momentContent = nil;
    
    //Depending on content type, content with be converted into raw data for transfer
    switch (contentType)
    {
        case kTAGMOMENTTEXT:
        {
            NSString *message = [momentText text];
            if([message length] > 0)
            {
                hasContentSet = YES;
                momentContent = [message dataUsingEncoding:[NSString defaultCStringEncoding]];
            }
            break;
        }
        case kTAGMOMENTPICTURE:
        {
            if([momentImage tag] == MOMENT_IMAGEVIEW_HASCONTENT)
                momentContent = UIImageJPEGRepresentation(momentImage.image, 0.25);
            break;
        }
        case kTAGMOMENTAUDIO:
        {
            break;
        }
        case kTAGMOMENTVIDEO:
        {
            if([momentImage tag] == MOMENT_IMAGEVIEW_HASCONTENT)
                momentContent = [[NSFileManager defaultManager] contentsAtPath:[takenVideoURL path]];
            break;
        }
    }
    //If no content set, display error
    if(!hasContentSet)
        [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeRed
                                       title:@"Content is Missing"
                             linedBackground:AJLinedBackgroundTypeDisabled
                                   hideAfter:BANNER_DEFAULT_TIME];
    
    //If content is set, load data to class instances and upload to S3
    if(hasContentSet == YES && title != nil && [title length] != 0)
    {
        Content *content = [[Content alloc] initWithContent:momentContent withType:self.contentType andTags:tags];
        NSData *contentData = [NSKeyedArchiver archivedDataWithRootObject:content];
        Moment *newMoment = [[Moment alloc] initWithTitle:title andUser:currentUser.username andContent:contentData andDate:currentDate andCoords:currentLocation andComments:nil];
        [S3UtilityClass addMomentToS3:newMoment];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeRed
                                       title:@"Caption Needed"
                             linedBackground:AJLinedBackgroundTypeDisabled
                                   hideAfter:BANNER_DEFAULT_TIME];
    }
}

//If user cancels get content from image picker, setup a way to reinitilize image selector
#pragma mark UIImagePickerController Delegate
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    //NSLog(@"No Picture Selected");
    if(momentImage == nil)
    {
        hasContentSet = NO;
        UIImage *img = [UIImage imageNamed:@"missing_logo.png"];
        momentImage = [[UIImageView alloc] initWithImage:img];
        [momentImage setTag:MOMENT_IMAGEVIEW_MISSINGCONTENT];
        [momentImage setFrame:CGRectMake(MOMENT_CONTENTVIEW_X, MOMENT_CONTENTVIEW_Y, MOMENT_CONTENTVIEW_WIDTH, MOMENT_CONTENTVIEW_HEIGHT)];
        [momentImage setUserInteractionEnabled:YES];
        [momentImage addGestureRecognizer:[self createTapGestureForContent]];
        [self.view addSubview:momentImage];
    }
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

//If media is selected
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //If picture is is selected, put picture into view
    //make a tap gesture to select a new picture
    
    //Otherwise, if video is selected, make a thumbnail
    //and also make a tap gesutre to slecect a new video
    if(contentType == kTAGMOMENTPICTURE)
    {
        //NSLog(@"Picture Selected");
        if(momentImage != nil)
            [momentImage removeFromSuperview];
        
        //sets picture
        UIImage *selectedPicture = [info valueForKey:UIImagePickerControllerOriginalImage];
        momentImage = [[UIImageView alloc] initWithImage:selectedPicture];
        [momentImage setTag:MOMENT_IMAGEVIEW_HASCONTENT];
        [momentImage setFrame:CGRectMake(MOMENT_CONTENTVIEW_X+10, MOMENT_CONTENTVIEW_Y+20, selectedPicture.size.width/9, selectedPicture.size.height/9)];
        [self.view addSubview:momentImage];
        
        
        //creates tap gesture
        [momentImage setUserInteractionEnabled:YES];
        [momentImage addGestureRecognizer:[self createTapGestureForContent]];
        hasContentSet = YES;
    }
    else if(contentType == kTAGMOMENTVIDEO)
    {
        //NSLog(@"Video Selected");
        if(momentImage != nil)
            [momentImage removeFromSuperview];
        
        //get videourl
        takenVideoURL = [info valueForKey:UIImagePickerControllerMediaURL];
        
        //gets player for thumbnail
        MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:takenVideoURL];
        [player setShouldAutoplay:NO];
    
        //Set thumbnail
        UIImage *thumbnail = [player thumbnailImageAtTime:1.0 timeOption:MPMovieTimeOptionNearestKeyFrame];
        momentImage = [[UIImageView alloc] initWithImage:thumbnail];
        [momentImage setTag:MOMENT_IMAGEVIEW_HASCONTENT];
        [momentImage setFrame:CGRectMake(MOMENT_CONTENTVIEW_X+10, MOMENT_CONTENTVIEW_Y+50, thumbnail.size.width/2, thumbnail.size.height/2)];
        
        //Get gesture
        [momentImage setUserInteractionEnabled:YES];
        [momentImage addGestureRecognizer:[self createTapGestureForContent]];
        [self.view addSubview:momentImage];
        
        //set play button
        playButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [playButton setFrame:CGRectMake(MOMENT_CONTENTVIEW_X, MOMENT_CONTENTVIEW_Y, 100, 45)];
        [playButton setTitle:@"Play Video" forState:UIControlStateNormal];
        [playButton addTarget:self action:@selector(playMedia) forControlEvents:UIControlEventTouchUpInside];
        [playButton setUserInteractionEnabled:YES];
        [self.view addSubview:playButton];
        
        hasContentSet = YES;
    }
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark AVAudioRecorder Delegate
-(void)stopRecording
{
    //Stops recording
    [recorderView removeFromSuperview];
    [recorder stop];
}

-(void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
    //NSLog(@"ERROR");
}

-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    //NSLog(@"*Recorder Stopped");
    //Sets play button for audio
    playButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [playButton setFrame:CGRectMake(MOMENT_CONTENTVIEW_X, MOMENT_CONTENTVIEW_Y, 100, 45)];
    [playButton setTitle:@"Play Record" forState:UIControlStateNormal];
    [playButton addTarget:self action:@selector(playMedia) forControlEvents:UIControlEventTouchUpInside];
    [playButton setUserInteractionEnabled:YES];
    [self.view addSubview:playButton];
}

#pragma mark AVAudioPlayer Delegate
//Sets play button to play recorded media
-(void)playMedia
{
    if(contentType == kTAGMOMENTAUDIO)
    {
        //NSLog(@"*Playing Sound*");
        NSURL *fileURL = [NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"TestAudio" ofType:@"mp4"]];
        AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
        [player setVolume:1.0];
        [player setDelegate:self];
        [player prepareToPlay];
        [player play];
    }
    else if(contentType == kTAGMOMENTVIDEO)
    {
        moviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:takenVideoURL];
        [self presentMoviePlayerViewControllerAnimated:moviePlayer];
        
        moviePlayer.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
        [moviePlayer.moviePlayer play];
    }
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    //NSLog(@"Player Stopped");
}

#pragma mark UIAlertView Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([alertView tag] == kUIAlertViewMomentNoCamera)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark Helper Functions
//creates gesture to detect content type
-(UITapGestureRecognizer*)createTapGestureForContent
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(detectMomentType)];
    [tapGesture setNumberOfTapsRequired:1];
    [tapGesture setNumberOfTouchesRequired:1];
    
    return tapGesture;
}

//Nills all objects
-(void)nillObjects
{
    momentText = nil;
    momentImage = nil;
    
    moviePlayer = nil;
    recorder = nil;
    takenAudioURL = nil;
    takenVideoURL = nil;
}

-(IBAction)goToNext
{
    [self.captionTextField resignFirstResponder];
    [self.tagTextField becomeFirstResponder];
}

-(IBAction)hideTagField
{
    [self.tagTextField resignFirstResponder];
}

//Method to hide keyboard
-(void)hideKeyboard
{
    [self.captionTextField resignFirstResponder];
    [self.tagTextField resignFirstResponder];
    if(momentText != nil)
        [momentText resignFirstResponder];
}

- (void) movieFinishedCallback:(NSNotification*) aNotification {
    MPMoviePlayerController *player = [aNotification object];
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:MPMoviePlayerPlaybackDidFinishNotification
     object:player];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
