//
//  MomentViewController.m
//  MyM
//
//  Created by Steven Zilberberg on 3/25/13.
//  Copyright (c) 2013 MyM Co. All rights reserved.
//

#import "MomentViewController.h"
#import "Constants.h"

@interface MomentViewController ()

@end

@implementation MomentViewController
@synthesize contentView;
@synthesize captionTextField;
@synthesize tagTextField;
@synthesize tripButton;
@synthesize trips;

@synthesize momentContent;
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
	// Do any additional setup after loading the view.
    textView = nil;
    imageView = nil;
    
    [self.captionTextField addTarget:self action:@selector(hideKeybord:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.tagTextField addTarget:self action:@selector(hideKeybord:) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Share" style:UIBarButtonItemStyleDone target:self action:@selector(share:)];
    
    [self setTitle:@"Create Moment"];
    
    
    NSUserDefaults *ud = [[NSUserDefaults alloc] initWithUser:[currentUser username]];
    self.trips = [ud valueForKey:@"Trips"];
    
    [self doWork];
}

-(void)doWork
{
    if(imageView != nil && [[imageView.gestureRecognizers objectAtIndex:0] isEnabled])
    {
        [[imageView.gestureRecognizers objectAtIndex:0] setEnabled:NO];
        return;
    }
    
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
        //[self performSelector:@selector(presentVideoSelector) withObject:nil afterDelay:0];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not Yet Implemented" message:@"Video Moments are not yet completed" delegate:self cancelButtonTitle:@"Boo..." otherButtonTitles: nil];
        [alert show];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if(contentType == kTAGMOMENTAUDIO){
        //Set audio
        NSLog(@"Audio Content");
        //[self performSelector:@selector(presentAudioSelector) withObject:nil afterDelay:0];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not Yet Implemented" message:@"Audio Moments are not yet completed" delegate:self cancelButtonTitle:@"Boo..." otherButtonTitles: nil];
        [alert show];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark Present ContentViews

-(void)presentTextView
{
    UIImage *backgroundImage = [UIImage imageNamed:@"notepad_background.png"];
    //UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
    textView = [[UITextView alloc]initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height)];
    [textView setTag:kTAGMOMENTTEXT];
    [textView setBackgroundColor:[UIColor colorWithPatternImage:backgroundImage]];
    [textView setFont:[UIFont fontWithName:@"Arial" size:24]];
    [self.contentView addSubview:textView];
}


-(void)presentImageSelector
{
    NSLog(@"Displaying Picker");
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
}

-(void)share:(id)sender
{
    NSString *title = [self.captionTextField text];
    NSArray *tags = [[self.tagTextField text] componentsSeparatedByString:@","];
    NSDate *currentDate = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
    NSString *tripID = [[self.tripButton titleLabel]text];
    Content *content = self.momentContent;
    
    if(title != nil)
    {
        if([tags count] != 0)
        {
            Moment *newMoment = [[Moment alloc] initWithTitle:title withTags:tags andUser:currentUser andContent:content andDate:currentDate andCoords:*(currentLocation) andComments:nil andTripID:tripID];
            newMoment = newMoment;
        }
    }
}

- (IBAction)hideKeybord:(id)sender {
    [self.captionTextField resignFirstResponder];
    [self.tagTextField resignFirstResponder];
    if(textView != nil)
        [textView resignFirstResponder];
}

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
            
            tempFile = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:kMomemtAudio_temp]];
            
            recorder = [[AVAudioRecorder alloc] initWithURL:tempFile settings:nil error:nil];
            [recorder setDelegate:self];
            [recorder prepareToRecord];
            [recorder record];
        }
    }
}

-(void)stopRecordingManually
{
    NSLog(@"Stop recording");
    [recorderView removeFromSuperview];
    [recorder stop];
    [self playAudio];
}

-(void)playAudio
{
    NSLog(@"Playing...");
    NSString *file = [[NSBundle mainBundle] resourcePath];
    file = [file stringByAppendingString:@"TestAudio.mp4"];
    NSURL *audioURL = [NSURL URLWithString:file];//[NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:kMomemtAudio_temp]]; //[NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"TestAudio" ofType:@"m4a"]];
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:audioURL error:nil];
    [player setDelegate:self];
    [player setVolume:1];
    [player play];
}

-(IBAction)playTestFile:(id)sender
{
    /*NSString *path = [[NSBundle mainBundle] pathForResource:@"TestAudio"
                                                     ofType:@"mp4"];
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID(
                                     (__bridge CFURLRef)[NSURL fileURLWithPath:path], &soundID);
    AudioServicesPlaySystemSound (soundID);*/
    //*************************
    
    NSString *file = [[NSBundle mainBundle] pathForResource:@"TestAudio" ofType:@"mp4"];
    NSURL *audioURL = [NSURL URLWithString:file];
    NSData *fileData = [NSData dataWithContentsOfFile:file];
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithData:fileData error:NULL];
    [player setDelegate:self];
    [player setVolume:1];
    [player play];
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

#pragma mark UIImagePickerController Delegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"Picture Selected");
    
    UIImage *img = [info valueForKey:UIImagePickerControllerOriginalImage];
    imageView = [[UIImageView alloc] initWithImage:img];
    [imageView setFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height)];
    
    UILongPressGestureRecognizer *holdDownRecognizer = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(presentImageSelector)];
    [holdDownRecognizer setNumberOfTapsRequired:0];
    [holdDownRecognizer setNumberOfTouchesRequired:1];
    [holdDownRecognizer setMinimumPressDuration:0.5];
    
    [imageView setUserInteractionEnabled:YES];
    [imageView addGestureRecognizer:holdDownRecognizer];
    [imageView setTag:kTAGMOMENTPICTURE];
    
    [self.contentView addSubview:imageView];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    if([[info valueForKey:UIImagePickerControllerMediaType] isEqualToString:kVideoCamera])
    {
        NSLog(@"Is Video File");
    
        NSURL *videoURL = [info valueForKey:UIImagePickerControllerMediaURL];
        
        moviePlayer =  [[MPMoviePlayerController alloc]
                        initWithContentURL:videoURL];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(moviePlayBackDidFinish:)
                                                     name:MPMoviePlayerPlaybackDidFinishNotification
                                                   object:moviePlayer];
        moviePlayer.movieSourceType = MPMovieSourceTypeFile;
        moviePlayer.view.backgroundColor = [UIColor clearColor];
        moviePlayer.controlStyle = MPMovieControlStyleDefault;
        moviePlayer.shouldAutoplay = YES;
        [moviePlayer prepareToPlay];
        [self.view addSubview:moviePlayer.view];
        [moviePlayer setFullscreen:YES animated:YES];
        [moviePlayer play];
    }
}

-(IBAction)playMovie
{
    NSURL *url = [NSURL URLWithString:@"http://www.ebookfrenzy.com/ios_book/movie/movie.mov"];
    moviePlayer =  [[MPMoviePlayerController alloc]
                    initWithContentURL:url];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:moviePlayer];
    
    
    moviePlayer.controlStyle = MPMovieControlStyleDefault;
    moviePlayer.shouldAutoplay = YES;
    [self.view addSubview:moviePlayer.view];
    [moviePlayer setFullscreen:YES animated:YES];
}

- (void) moviePlayBackDidFinish:(NSNotification*)notification {
    MPMoviePlayerController *player = [notification object];
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:MPMoviePlayerPlaybackDidFinishNotification
     object:moviePlayer];
    
    if ([player respondsToSelector:@selector(setFullscreen:animated:)])
    {
        [player.view removeFromSuperview];
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"No Picture Selected");
    if(imageView == nil)
    {
        [self creatMissingImageView];
    }
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

-(void)creatMissingImageView
{
    UIImage *img = [UIImage imageNamed:@"missing_logo.png"];
    imageView = [[UIImageView alloc] initWithImage:img];
    [imageView setFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height)];
    
    UILongPressGestureRecognizer *holdDownRecognizer = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(doWork)];
    [holdDownRecognizer setNumberOfTapsRequired:0];
    [holdDownRecognizer setNumberOfTouchesRequired:1];
    [holdDownRecognizer setMinimumPressDuration:0.5];
    
    [imageView setUserInteractionEnabled:YES];
    [imageView addGestureRecognizer:holdDownRecognizer];
    
    [self.contentView addSubview:imageView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
