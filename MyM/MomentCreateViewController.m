//
//  MomentViewController.m
//  MyM
//
//  Created by Steven Zilberberg on 3/25/13.
//  Copyright (c) 2013 MyM Co. All rights reserved.
//

#import "MomentCreateViewController.h"
#import "AJNotificationView.h"
#import "Constants.h"

#define BANNER_DEFAULT_TIME 3
#define SCREEN_HEIGHT [[UIScreen mainScreen] applicationFrame].size.height


@interface MomentCreateViewController ()
{
    IBOutlet UITextView *textView;
    IBOutlet UIImageView *imageView;
    
    NSURL *takenVideo;
    NSURL *takenAudio;

}

@end

@implementation MomentCreateViewController
@synthesize contentView;
@synthesize captionTextField;
@synthesize tagTextField;
@synthesize tripButton;
@synthesize trips;

@synthesize contentType;
@synthesize currentLocation;
@synthesize currentUser;

@synthesize recorder;

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
	
    //Null objects
    takenVideo = nil;
    recorder = nil;
    textView = nil;
    imageView = nil;
    
    //setup hide keyboard for textFields
    [self.captionTextField addTarget:self action:@selector(hideKeybord:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.tagTextField addTarget:self action:@selector(hideKeybord:) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    //setup navigation view with title and submit button
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Share" style:UIBarButtonItemStyleDone target:self action:@selector(share:)];
    [self setTitle:@"Create Moment"];
    
    [self detectMoementType];
}

-(void)detectMoementType {
    
    //if imageview exists and the gesture is enabled, set it enabled 
    if(imageView != nil && [[imageView.gestureRecognizers objectAtIndex:0] isEnabled]){
        
        [[imageView.gestureRecognizers objectAtIndex:0] setEnabled:NO];
        return;
    }
    
    //Detect type of moment to setup
    if(contentType == kTAGMOMENTTEXT){
        NSLog(@"Text View");
        [self performSelector:@selector(presentTextView) withObject:nil afterDelay:0];
    }
    else if(contentType == kTAGMOMENTPICTURE){
        NSLog(@"Picture Content");
        [self performSelector:@selector(presentImageSelector) withObject:nil afterDelay:0];
    }
    else if(contentType == kTAGMOMENTVIDEO){
        //Set video content
        NSLog(@"Video Content");
        [self performSelector:@selector(presentVideoSelector) withObject:nil afterDelay:0];
    }
    else if(contentType == kTAGMOMENTAUDIO){
        //Set audio
        NSLog(@"Audio Content");
        [self performSelector:@selector(presentAudioSelector) withObject:nil afterDelay:0];
    }
}

#pragma mark NEW Present Media Views
-(void)presentTextView
{
    UIImage *backgroundImage = [UIImage imageNamed:@"notepad_background.png"];
    textView = [[UITextView alloc]initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height)];
    [textView setTag:kTAGMOMENTTEXT];
    [textView setBackgroundColor:[UIColor colorWithPatternImage:backgroundImage]];
    [textView setFont:[UIFont fontWithName:@"Arial" size:24]];
    [self.contentView addSubview:textView];
}

-(void)presentImageSelector
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

-(void)presentVideoSelector
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
    [pickerController setMediaTypes:[NSArray arrayWithObject:kVideoCamera]];
    [pickerController setSourceType:UIImagePickerControllerSourceTypeCamera];
    [self presentViewController:pickerController animated:YES completion:NULL];
}

-(void)presentAudioSelector
{
    recorderView = [[UIView alloc]initWithFrame:CGRectMake(135, 214, 75, 75)];
    [recorderView setBackgroundColor:[UIColor greenColor]];
    UIImageView *recorderImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 75, 75)];
    [recorderImageView setImage:[UIImage imageNamed:@"siri-logo.png"]];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(stopRecordingManually)];
    [tapGesture setNumberOfTapsRequired:1];
    [tapGesture setNumberOfTouchesRequired:1];
    [recorderImageView addGestureRecognizer:tapGesture];
    [recorderImageView setUserInteractionEnabled:YES];
    [recorderView addSubview:recorderImageView];
    [self.view addSubview:recorderView];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setActive:YES error:nil];
    
    takenAudio = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:kMomemtAudio_temp]];
    
    recorder = [[AVAudioRecorder alloc] initWithURL:takenAudio settings:nil error:nil];
    [recorder setDelegate:self];
    [recorder prepareToRecord];
    [recorder record];
}

#pragma mark UIAlertView Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([alertView tag] == kUIAlertViewMomentNoCamera)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


#pragma mark OLD Present Media Views
/*
-(void)presentTextView
{
    UIImage *backgroundImage = [UIImage imageNamed:@"notepad_background.png"];
    textView = [[UITextView alloc]initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height)];
    [textView setTag:kTAGMOMENTTEXT];
    [textView setBackgroundColor:[UIColor colorWithPatternImage:backgroundImage]];
    [textView setFont:[UIFont fontWithName:@"Arial" size:24]];
    [self.contentView addSubview:textView];
}

-(void)presentImageSelector
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"Select Media" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Saved Image", @"Take Picture", nil];
    [actionSheet setTag:kUIACTIONSHEETTAGPICTURE];
    [actionSheet showInView:self.view];
}

-(void)presentVideoSelector
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"Select Media" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Saved Video", @"Take Video", nil];
    [actionSheet setTag:kUIACTIONSHEETTAGVIDEO];
    [actionSheet showInView:self.view];
}

-(void)presentAudioSelector
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"Select Media" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Saved Audio", @"Record Audio", nil];
    [actionSheet setTag:kUIACTIONSHEETTAGAUDIO];
    [actionSheet showInView:self.view];
}*/

-(void)share:(id)sender
{
    NSString *title = [self.captionTextField text];
    NSMutableArray *tags = (NSMutableArray*)[[self.tagTextField text] componentsSeparatedByString:@","];
    NSDate *currentDate = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
    
    NSString *tripID = @"MyM_Trip";//[[self.tripButton titleLabel]text];
    
    id momentContent = nil;
    switch(self.contentType)
    {
        case kTAGMOMENTTEXT:
            momentContent = [textView text];
            break;
        case kTAGMOMENTPICTURE:
            momentContent = [imageView image];
            break;
        case kTAGMOMENTAUDIO:
            NSLog(@"Need Implementation");
            break;
        case kTAGMOMENTVIDEO:
            NSLog(@"Need Implementation");
            break;
    }
    
    Content *content = [[Content alloc] initWithContent:momentContent withType:self.contentType andTags:tags];
    
    if(title != nil)
    {
        if(![[self.captionTextField text] isEqualToString:@""])
        {
            Moment *newMoment = [[Moment alloc] initWithTitle:title andUser:currentUser andContent:content andDate:currentDate andCoords:currentLocation andComments:nil andTripID:tripID];
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
}

-(void)creatMissingImageView
{
    UIImage *img = [UIImage imageNamed:@"missing_logo.png"];
    imageView = [[UIImageView alloc] initWithImage:img];
    [imageView setFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height)];
    
    UILongPressGestureRecognizer *holdDownRecognizer = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(detectMoementType)];
    [holdDownRecognizer setNumberOfTapsRequired:0];
    [holdDownRecognizer setNumberOfTouchesRequired:1];
    [holdDownRecognizer setMinimumPressDuration:0.5];
    
    [imageView setUserInteractionEnabled:YES];
    [imageView addGestureRecognizer:holdDownRecognizer];
    
    [self.contentView addSubview:imageView];
}

#pragma mark UIImagePickerController Delegate

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"No Picture Selected");
    if(imageView == nil)
    {
        [self creatMissingImageView];
    }
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"Picture Selected");
    
    UIImage *img = [info valueForKey:UIImagePickerControllerOriginalImage];
    imageView = [[UIImageView alloc] initWithImage:img];
    [imageView setFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height)];
    
    
    if([[info valueForKey:UIImagePickerControllerMediaType] isEqualToString:kVideoCamera])
    {
        NSLog(@"Is Video File");
        
#warning NEED TO MAKE AND IMPLEMENT BUTTON TO PLAY
        
        NSURL *videoURL = [info valueForKey:UIImagePickerControllerMediaURL];
        
        img = [moviePlayer thumbnailImageAtTime:0 timeOption:MPMovieTimeOptionNearestKeyFrame];
        self.testingImage.image = img;
        imageView = nil;
        imageView = [[UIImageView alloc] initWithImage:img];
        [imageView setFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height)];
        
        takenVideo = videoURL;
    }
    
    UILongPressGestureRecognizer *holdDownRecognizer = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(presentImageSelector)];
    [holdDownRecognizer setNumberOfTapsRequired:0];
    [holdDownRecognizer setNumberOfTouchesRequired:1];
    [holdDownRecognizer setMinimumPressDuration:0.5];
    
    [imageView setUserInteractionEnabled:YES];
    [imageView addGestureRecognizer:holdDownRecognizer];
    [imageView setTag:kTAGMOMENTPICTURE];
    
    [self.contentView addSubview:imageView];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)playMedia:(id)sender
{
    if(contentType == kTAGMOMENTVIDEO)
    {
        if(takenVideo != nil)
            [self playVideo];
    }
    else if(contentType == kTAGMOMENTAUDIO)
    {
        if(takenAudio != nil)
            [self playAudio];
    }
}

-(void)playAudio
{
    NSLog(@"Playing...");
    NSString *file = [[NSBundle mainBundle] resourcePath];
    file = [file stringByAppendingPathComponent:kMomemtAudio_temp];
    NSURL *audioURL = takenAudio;
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:audioURL error:nil];
    [player setDelegate:self];
    [player setVolume:1];
    [player play];
}

-(void)stopRecordingManually
{
    NSLog(@"Stop recording");
    [recorderView removeFromSuperview];
    [recorder stop];
}

- (void)playVideo
{
    MPMoviePlayerViewController *moviePlayerViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:takenVideo];
    [self presentMoviePlayerViewControllerAnimated:moviePlayerViewController];
    
    moviePlayerViewController.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
    [moviePlayerViewController.moviePlayer play];
}

#pragma mark AVAudioRecorder Delegate

-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    NSLog(@"*Recording Finished*");
}

#pragma mark AVAudioPlayer Delegate

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"*Player Finished*");
}

- (IBAction)hideKeybord:(id)sender {
    [self.captionTextField resignFirstResponder];
    [self.tagTextField resignFirstResponder];
    if(textView != nil)
        [textView resignFirstResponder];
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
}

//OLD METHOD: Keeping for reference for now...
/*
 #pragma mark UIActionSheet Delegate
 -(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
 {
 if(imageView != nil && ![[imageView.gestureRecognizers objectAtIndex:0] isEnabled])
 [[imageView.gestureRecognizers objectAtIndex:0] setEnabled:YES];
 
 if([actionSheet tag] == kUIACTIONSHEETTAGPICTURE)
 {
 if(buttonIndex == kSAVEDBUTTONINDEX)
 {
 UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
 [pickerController setDelegate:self];
 [pickerController setMediaTypes:[NSArray arrayWithObject:kStillImages]];
 [pickerController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
 [self presentViewController:pickerController animated:YES completion:NULL];
 }
 else if(buttonIndex == kTAKEMEDIA)
 {
 if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
 {
 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Camera Detected" message:@"Your device doesn't have a camera." delegate:self cancelButtonTitle:@"Darn..." otherButtonTitles:nil];
 [alert show];
 return;
 }
 UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
 [pickerController setDelegate:self];
 [pickerController setMediaTypes:[NSArray arrayWithObject:kStillImages]];
 [pickerController setSourceType:UIImagePickerControllerSourceTypeCamera];
 [self presentViewController:pickerController animated:YES completion:NULL];
 }
 else if(buttonIndex == [actionSheet cancelButtonIndex])
 {
 if(imageView == nil)
 [self creatMissingImageView];
 }
 
 }
 else if([actionSheet tag] == kUIACTIONSHEETTAGVIDEO)
 {
 if(buttonIndex == kSAVEDBUTTONINDEX)
 {
 UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
 [pickerController setDelegate:self];
 [pickerController setMediaTypes:[NSArray arrayWithObject:kVideoCamera]];
 [pickerController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
 [self presentViewController:pickerController animated:YES completion:NULL];
 }
 else if(buttonIndex == kTAKEMEDIA)
 {
 if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
 {
 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Camera Detected" message:@"Your device doesn't have a camera." delegate:self cancelButtonTitle:@"Darn..." otherButtonTitles:nil];
 [alert show];
 return;
 }
 UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
 [pickerController setDelegate:self];
 [pickerController setMediaTypes:[NSArray arrayWithObject:kVideoCamera]];
 [pickerController setSourceType:UIImagePickerControllerSourceTypeCamera];
 [self presentViewController:pickerController animated:YES completion:NULL];
 }
 else if(buttonIndex == [actionSheet cancelButtonIndex])
 {
 if(imageView == nil)
 [self creatMissingImageView];
 }
 }
 else if([actionSheet tag] == kUIACTIONSHEETTAGAUDIO)
 {
 if(buttonIndex == kSAVEDBUTTONINDEX)
 {
 
 }
 else if(buttonIndex == kTAKEMEDIA)
 {
 
 recorderView = [[UIView alloc]initWithFrame:CGRectMake(135, 214, 75, 75)];
 [recorderView setBackgroundColor:[UIColor greenColor]];
 UIImageView *recorderImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 75, 75)];
 [recorderImageView setImage:[UIImage imageNamed:@"siri-logo.png"]];
 
 UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(stopRecordingManually)];
 [tapGesture setNumberOfTapsRequired:1];
 [tapGesture setNumberOfTouchesRequired:1];
 [recorderImageView addGestureRecognizer:tapGesture];
 [recorderImageView setUserInteractionEnabled:YES];
 [recorderView addSubview:recorderImageView];
 [self.view addSubview:recorderView];
 
 AVAudioSession *audioSession = [AVAudioSession sharedInstance];
 [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
 [audioSession setActive:YES error:nil];
 
 takenAudio = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:kMomemtAudio_temp]];
 
 recorder = [[AVAudioRecorder alloc] initWithURL:takenAudio settings:nil error:nil];
 [recorder setDelegate:self];
 [recorder prepareToRecord];
 [recorder record];
 }
 else if(buttonIndex == [actionSheet cancelButtonIndex])
 {
 
 }
 }
 }
 */

/*-(IBAction)playTestFile:(id)sender
 {
 NSString *path = [[NSBundle mainBundle] pathForResource:@"TestAudio"
 ofType:@"mp4"];
 SystemSoundID soundID;
 AudioServicesCreateSystemSoundID(
 (__bridge CFURLRef)[NSURL fileURLWithPath:path], &soundID);
 AudioServicesPlaySystemSound (soundID);
 *************************
 
 NSString *file = [[NSBundle mainBundle] pathForResource:@"TestAudio" ofType:@"mp4"];
 NSURL *audioURL = [NSURL URLWithString:file];
 NSData *fileData = [NSData dataWithContentsOfFile:file];
 AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithData:fileData error:NULL];
 [player setDelegate:self];
 [player setVolume:1];
 [player play];
 }*/

@end
