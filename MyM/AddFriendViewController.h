/*
 * MyM: Map Your Moments "A Digital Travelogue"
 *
 * Developed using iOS and AWS for CSC Special Topics: Cloud Computing, Spring 2013 by
 * Adam Cumiskey, Dave Hand, Tim Honeywell, Marcelo Mazzotti, Justin Wagner, and Steven Zilberberg
 *
 * AddFriendViewController.h
 * Displays a tableview of all users currently registered on MyM. A user can click on a name
 * to send a friend request to that user. A user can also search for a user's name in the search bar
 * and click on their name to send them a friend request. Furthermore, if a user clicks the top right
 * navigation bar button he/she can send a friend request to a specified email of a user if the email exists.
 *
 */

#import <UIKit/UIKit.h>
#import "Moment.h"

@interface AddFriendViewController : UIViewController <UITableViewDataSource,
                                    UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate>

- (id)initWithSectionIndexes:(BOOL)showSectionIndexes;

- (void)scrollTableViewToSearchBarAnimated:(BOOL)animated;

- (void)loadUsers;
- (void)addFriend;

@property(nonatomic, assign, readonly) BOOL showSectionIndexes;

@property(nonatomic, strong, readonly) UITableView *tableView;
@property(nonatomic, strong, readonly) UISearchBar *searchBar;

@property (strong, nonatomic) User *user;

@end
