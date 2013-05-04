//
//  MomentCreateViewController.h
//  MyM
//
//  Created by Steven Zilberberg on 5/3/13.
//  Copyright (c) 2013 MyM Co. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import "Moment.h"
#import "MapViewController.h"
#import "AmazonClientManager.h"
#import "S3UtilityClass.h"

@interface MomentCreateViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate, UIAlertViewDelegate>

//IBOUTLETS For View
@property (strong, nonatomic) IBOutlet UITextField *captionTextField;
@property (strong, nonatomic) IBOutlet UITextField *tagTextField;

//Passed Data about user and location Type
@property int contentType;
@property CLLocationCoordinate2D currentLocation;
@property (strong, nonatomic) User *currentUser;

//Core Functions of View
-(void)detectMomentType;
-(void)presentText;
-(void)presentAudio;
-(void)presentImage;
-(void)presentVideo;
-(void)playMedia;
-(void)stopRecording;
-(void)share;

//Helper Functions
-(UITapGestureRecognizer*)createTapGestureForContent;
-(void)nillObjects;
-(void)hideKeyboard;

@end
