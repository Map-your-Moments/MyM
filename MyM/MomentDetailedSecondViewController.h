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

@interface MomentDetailedSecondViewController : UITableViewController

@property (strong, nonatomic) Moment *targetMoment;

-(void)playMovie;
-(void)setContentFooter:(int)contentType;

@end
