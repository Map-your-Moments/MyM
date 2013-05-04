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
    
    MPMoviePlayerController *moviePlayer;
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
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [audioSession setActive:YES error:nil];
        
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
    
}

-(void)share
{
    NSString *title = [[self.captionTextField text]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSMutableArray *tags = (NSMutableArray*)[[self.tagTextField text] componentsSeparatedByString:@","];
    NSDate *currentDate = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
    NSString *ID = [NSString stringWithFormat:@"%f_%f_%f", currentLocation.latitude, currentLocation.longitude, currentDate.timeIntervalSince1970];
    
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
                momentContent = UIImagePNGRepresentation(momentImage.image);
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
    if(!hasContentSet)
        [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeRed
                                       title:@"Content is Missing"
                             linedBackground:AJLinedBackgroundTypeDisabled
                                   hideAfter:BANNER_DEFAULT_TIME];
    
    NSLog(@"Moment Text: %d\nMoment Image: %d",[momentText tag], [momentImage tag]);
    if(hasContentSet == YES && title != nil && [title length] != 0)
    {
        Content *content = [[Content alloc] initWithContent:momentContent withType:self.contentType andTags:tags];
        Moment *newMoment = [[Moment alloc] initWithTitle:title andUser:currentUser.username andContent:content andDate:currentDate andCoords:currentLocation andComments:nil andID:ID];
        [self.dataController addMomentToMomentsWithMoment:newMoment];
        [self.delegate setDataController:self.dataController];
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
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark AVAudioRecorder Delegate
-(void)stopRecording
{
    [recorderView removeFromSuperview];
    [recorder stop];
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
    NSLog(@"*Playing*");
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"TestAudio" ofType:@"mp4"]] error:nil];
    [player setVolume:1.0];
    [player setDelegate:self];
    [player prepareToPlay];
    [player play];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
