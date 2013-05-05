/*
 * MyM: Map Your Moments "A Digital Travelogue"
 *
 * Developed using iOS and AWS for CSC Special Topics: Cloud Computing, Spring 2013 by
 * Adam Cumiskey, Dave Hand, Tim Honeywell, Marcelo Mazzotti, Justin Wagner, and Steven Zilberberg
 *
 * NewUserViewController.h
 * 
 *
 */

#import <UIKit/UIKit.h>
#import "AmazonClientManager.h"

@protocol NewUserDelegate <NSObject>
- (void)newUserCreated;
@end

@interface NewUserViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) id<NewUserDelegate> delegate;
@end