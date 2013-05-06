/*
 * MyM: Map Your Moments "A Digital Travelogue"
 *
 * Developed using iOS and AWS for CSC Special Topics: Cloud Computing, Spring 2013 by
 * Adam Cumiskey, Dave Hand, Tim Honeywell, Marcelo Mazzotti, Justin Wagner, and Steven Zilberberg
 *
 * FriendAccountViewController.h
 * Display for a friend's account information. The view shows the friend's username
 * as the title. The table view includes the friend's username and profile pic, full name,
 * and email each in their respective cell. At the bottom of a view is a delete friend button
 * to remove the friend from your friends list
 *
 */

#import <UIKit/UIKit.h>
#import "Moment.h"

@interface FriendAccountViewController : UITableViewController <UIAlertViewDelegate>

@property (strong, nonatomic) User *user;
@property (nonatomic) NSString *email;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *username;


@end
