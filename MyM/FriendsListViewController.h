/*
 * MyM: Map Your Moments "A Digital Travelogue"
 *
 * Developed using iOS and AWS for CSC Special Topics: Cloud Computing, Spring 2013 by
 * Adam Cumiskey, Dave Hand, Tim Honeywell, Marcelo Mazzotti, Justin Wagner, and Steven Zilberberg
 *
 * FriendsListViewController.h
 * View for the user's friends list. The view displays all friendships that a user currently has with the profile image and
 * name of the friend displayed in a cell of the table view. User's can swipe left or right on a friend's name to bring up
 * a delete button which will allow them to unfriend the friend. The friends are stored in a sectioned array, with sections
 * determined by the beginning letter of the friend's "name" field. A search bar is provided which checks for any friend's names
 * that contain the current search string and displays them. User's profile pictures are retrieved from the gravatar profile
 * associated with the email with which they registered their MyM account. The + button at the top right of the view's navigation
 * bar takes the user to a new view that lists all users on MyM and allows them to add these user's as friends by clicking on
 * their name or by clicking the top right navigation bar button to add a user by their email address.
 *
 */

#import <UIKit/UIKit.h>
#import "Moment.h"

@interface FriendsListViewController : UIViewController <UITableViewDataSource,
                                    UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate>

- (id)initWithSectionIndexes:(BOOL)showSectionIndexes;

- (void)scrollTableViewToSearchBarAnimated:(BOOL)animated;

- (void)loadFriends;
- (void)addFriendButton;

@property(nonatomic, assign, readonly) BOOL showSectionIndexes;

@property(nonatomic, strong, readonly) UITableView *tableView;
@property(nonatomic, strong, readonly) UISearchBar *searchBar;

@property (strong, nonatomic) User *user;

@end
