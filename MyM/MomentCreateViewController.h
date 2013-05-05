/*
 * MyM: Map Your Moments "A Digital Travelogue"
 *
 * Developed using iOS and AWS for CSC Special Topics: Cloud Computing, Spring 2013 by
 * Adam Cumiskey, Dave Hand, Tim Honeywell, Marcelo Mazzotti, Justin Wagner, and Steven Zilberberg
 *
 * MomentCreateViewController.h
 * File summary.
 *
 */

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
