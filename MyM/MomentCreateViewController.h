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
#import "Moment.h"
#import "MapViewController.h"

@interface MomentCreateViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate, UIAlertViewDelegate>
{
    MPMoviePlayerController *moviePlayer;
    AVAudioRecorder *recorder;
    
    UIView *recorderView;
}
@property (strong, nonatomic) IBOutlet UIImageView *testingImage;

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet UITextField *captionTextField;
@property (strong, nonatomic) IBOutlet UITextField *tagTextField;
@property (strong, nonatomic) IBOutlet UIButton *tripButton;

@property (strong, nonatomic) NSArray *trips;

@property int contentType;
@property CLLocationCoordinate2D currentLocation;
@property (strong, nonatomic) User *currentUser;
@property (strong, nonatomic) MomentDataController *dataController;

@property (strong, nonatomic) AVAudioRecorder *recorder;

@property (nonatomic, weak) id<mapProtocol> delegate;

-(void)detectMoementType;
-(void)presentTextView;
-(void)presentImageSelector;
-(void)presentVideoSelector;
-(void)share:(id)sender;

-(void)playVideo;

- (IBAction)hideKeybord:(id)sender;
- (IBAction)playMedia:(id)sender;

@end
