//
//  MomentCreateViewController.m
//  MyM
//
//  Created by Steven Zilberberg on 5/3/13.
//  Copyright (c) 2013 MyM Co. All rights reserved.
//

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

//Hiding keyboard on textfields doesn't work...

@interface MomentCreateViewController ()
{
    bool hasContentSet;
    
    UITextView *momentText;
    UIImageView *momentImage;
    
    MPMoviePlayerViewController *moviePlayer;
    AVAudioRecorder *recorder;

    UIView *recorderView;
    
    NSURL *takenVideoURL;
    NSURL *takenAudioURL;
    
    UIButton *playButton;
}

@end

@implementation MomentCreateViewController
@synthesize captionTextField;
@synthesize tagTextField;

@synthesize contentType;
@synthesize currentLocation;
@synthesize currentUser;

NSString *kStillImages = @"public.image";
NSString *kVideoCamera = @"public.movie";
NSString *kMomemtAudio_temp = @"MomemtAudio_temp";

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
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [self nillObjects];
    
    UITapGestureRecognizer *tapHideKeyboard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [tapHideKeyboard setNumberOfTapsRequired:1];
    [tapHideKeyboard setNumberOfTouchesRequired:1];
    [self.view addGestureRecognizer:tapHideKeyboard];
    
    //Setup navigation view with title and submit button
    [self setTitle:@"Create Moment"];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Share" style:UIBarButtonItemStyleDone target:self action:@selector(share)];
    
    [self detectMomentType];
}

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

-(void)presentText
{
    if(momentText == nil)
    {
        UIImage *backgroundImage = [UIImage imageNamed:@"notepad_background.png"];
        momentText = [[UITextView alloc]initWithFrame:CGRectMake(MOMENT_CONTENTVIEW_X, MOMENT_CONTENTVIEW_Y, 280, 180)];
        [momentText setTag:kTAGMOMENTTEXT];
        [momentText setBackgroundColor:[UIColor colorWithPatternImage:backgroundImage]];
        [momentText setFont:[UIFont fontWithName:@"Arial" size:24]];
        [self.view addSubview:momentText];
    }
}

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
    
    NSLog(@"*Recording*");
}

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

-(void)share
{
    NSString *title = [[self.captionTextField text]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSMutableArray *tags = (NSMutableArray*)[[self.tagTextField text] componentsSeparatedByString:@","];
    NSDate *currentDate = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
    
    NSData *momentContent = nil;
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
            NSLog(@"%Size: %d", [momentContent bytes]);
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
    if(!hasContentSet)
        [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeRed
                                       title:@"Content is Missing"
                             linedBackground:AJLinedBackgroundTypeDisabled
                                   hideAfter:BANNER_DEFAULT_TIME];
    
    NSLog(@"Moment Text: %d\nMoment Image: %d",[momentText tag], [momentImage tag]);
    if(hasContentSet == YES && title != nil && [title length] != 0)
    {
        Content *content = [[Content alloc] initWithContent:momentContent withType:self.contentType andTags:tags];
        Moment *newMoment = [[Moment alloc] initWithTitle:title andUser:currentUser.username andContent:content andDate:currentDate andCoords:currentLocation andComments:nil];
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

#pragma mark UIImagePickerController Delegate
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"No Picture Selected");
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

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if(contentType == kTAGMOMENTPICTURE)
    {
        NSLog(@"Picture Selected");
        if(momentImage != nil)
            [momentImage removeFromSuperview];
        
        UIImage *selectedPicture = [info valueForKey:UIImagePickerControllerOriginalImage];
        momentImage = [[UIImageView alloc] initWithImage:selectedPicture];
        [momentImage setTag:MOMENT_IMAGEVIEW_HASCONTENT];
        [momentImage setFrame:CGRectMake(MOMENT_CONTENTVIEW_X+10, MOMENT_CONTENTVIEW_Y+20, selectedPicture.size.width/9, selectedPicture.size.height/9)];
        [self.view addSubview:momentImage];
        
        [momentImage setUserInteractionEnabled:YES];
        [momentImage addGestureRecognizer:[self createTapGestureForContent]];
        
        hasContentSet = YES;
    }
    else if(contentType == kTAGMOMENTVIDEO)
    {
        NSLog(@"Video Selected");
        if(momentImage != nil)
            [momentImage removeFromSuperview];
        
        takenVideoURL = [info valueForKey:UIImagePickerControllerMediaURL];
        
        MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:takenVideoURL];
        [player setShouldAutoplay:NO];
    
        UIImage *thumbnail = [player thumbnailImageAtTime:1.0 timeOption:MPMovieTimeOptionNearestKeyFrame];
        
        momentImage = [[UIImageView alloc] initWithImage:thumbnail];
        [momentImage setTag:MOMENT_IMAGEVIEW_HASCONTENT];
        [momentImage setFrame:CGRectMake(MOMENT_CONTENTVIEW_X+10, MOMENT_CONTENTVIEW_Y+50, thumbnail.size.width/2, thumbnail.size.height/2)];
        
        
        [momentImage setUserInteractionEnabled:YES];
        [momentImage addGestureRecognizer:[self createTapGestureForContent]];
        [self.view addSubview:momentImage];
        
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
    [recorderView removeFromSuperview];
    [recorder stop];
}

-(void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
    NSLog(@"ERROR");
}

-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    NSLog(@"*Recorder Stopped");
    playButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [playButton setFrame:CGRectMake(MOMENT_CONTENTVIEW_X, MOMENT_CONTENTVIEW_Y, 100, 45)];
    [playButton setTitle:@"Play Record" forState:UIControlStateNormal];
    [playButton addTarget:self action:@selector(playMedia) forControlEvents:UIControlEventTouchUpInside];
    [playButton setUserInteractionEnabled:YES];
    [self.view addSubview:playButton];
}

#pragma mark AVAudioPlayer Delegate
-(void)playMedia
{
    if(contentType == kTAGMOMENTAUDIO)
    {
        NSLog(@"*Playing Sound*");
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
    NSLog(@"Player Stopped");
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
-(UITapGestureRecognizer*)createTapGestureForContent
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(detectMomentType)];
    [tapGesture setNumberOfTapsRequired:1];
    [tapGesture setNumberOfTouchesRequired:1];
    
    return tapGesture;
}

-(void)nillObjects
{
    momentText = nil;
    momentImage = nil;
    
    moviePlayer = nil;
    recorder = nil;
    takenAudioURL = nil;
    takenVideoURL = nil;
}

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
