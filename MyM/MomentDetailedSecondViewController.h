/*
 * MyM: Map Your Moments "A Digital Travelogue"
 *
 * Developed using iOS and AWS for CSC Special Topics: Cloud Computing, Spring 2013 by
 * Adam Cumiskey, Dave Hand, Tim Honeywell, Marcelo Mazzotti, Justin Wagner, and Steven Zilberberg
 *
 * MomentDetailedSecondViewController.h
 * 
 *
 */

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "Moment.h"

@interface MomentDetailedSecondViewController : UITableViewController <UIActionSheetDelegate>

//Public variables
@property (strong, nonatomic) NSString *currentUser;
@property (strong, nonatomic) Moment *targetMoment;

//Basic functions of detailedView
-(void)playMovie;
-(void)setContentFooter:(int)contentType;

//Creates string of tags
-(NSString*)createTagString;

//Deletes selected moment
-(void)deleteMoment;

@end
