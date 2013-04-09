//
//  MomentViewController.h
//  MyM
//
//  Created by Steven Zilberberg on 3/25/13.
//  Copyright (c) 2013 MyM Co. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVAudioPlayer.h>
#import "Moment.h"

@interface MomentViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate>
{
    IBOutlet UITextView *textView;
    IBOutlet UIImageView *imageView;
    
    MPMoviePlayerController *moviePlayer;
    
    UIView *recorderView;
    NSURL *tempFile;
}

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet UITextField *captionTextField;
@property (strong, nonatomic) IBOutlet UITextField *tagTextField;
@property (strong, nonatomic) IBOutlet UIButton *tripButton;

@property (strong, nonatomic) NSArray *trips;
@property (strong, nonatomic) Content *momentContent;

@property int contentType;
@property CLLocationCoordinate2D *currentLocation;
@property (strong, nonatomic) User *currentUser;

@property (strong, nonatomic) AVAudioRecorder *recorder;

-(void)presentTextView;
-(void)presentImageSelector;
-(void)presentVideoSelector;
- (void)share:(id)sender;

- (IBAction)hideKeybord:(id)sender;

@end
