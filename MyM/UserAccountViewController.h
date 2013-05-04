/*
 * MyM: Map Your Moments "A Digital Travelogue"
 *
 * Developed using iOS and AWS for CSC Special Topics: Cloud Computing, Spring 2013 by
 * Adam Cumiskey, Dave Hand, Tim Honeywell, Marcelo Mazzotti, Justin Wagner, and Steven Zilberberg
 *
 * UserAccountViewController.h
 * Display for a user's account information. The table view includes the friend's username and profile pic, password,
 * and email each in their respective cell. At the bottom of the view is a delete account button
 * to permanently delete the current user's account. If a user clicks on the password field an alert displays
 * asking for their current password. If they input their password correctly, then the user is given another
 * alert view to input and confirm their new password, which then updates in the database. This is the same
 * for clicking on the  email field. If the user wishes to fully delete their account they can press the
 * delete account button and go through a confirmation alert to delete their account. If the deletion is successful,
 * they are returned to the sign in view.
 *
 */

#import <UIKit/UIKit.h>
#import "Moment.h"

@interface UserAccountViewController : UITableViewController <UIAlertViewDelegate>

@property (strong, nonatomic) User *user;

@end
