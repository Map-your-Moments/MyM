/*
 * MyM: Map Your Moments "A Digital Travelogue"
 *
 * Developed using iOS and AWS for CSC Special Topics: Cloud Computing, Spring 2013 by
 * Adam Cumiskey, Dave Hand, Tim Honeywell, Marcelo Mazzotti, Justin Wagner, and Steven Zilberberg
 *
 * FriendsListViewController.m
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

#import "FriendsListViewController.h"
#import "UtilityClass.h"
#import "GravitarUtilityClass.h"
#import "FriendAccountViewController.h"
#import "AJNotificationView.h"
#import "SearchBarTableViewController.h"
#import "AddFriendSearchBarTableViewController.h"

//default display time for AJNotifications
#define BANNER_DEFAULT_TIME 2

//alert view tag for friendship deletion
#define TAG_DELETE 1

#define screenWidth [[UIScreen mainScreen] applicationFrame].size.width
#define screenHeight [[UIScreen mainScreen] applicationFrame].size.height

#define screenWidth [[UIScreen mainScreen] applicationFrame].size.width
#define screenHeight [[UIScreen mainScreen] applicationFrame].size.height

static NSString * const kSearchBarTableViewControllerDefaultTableViewCellIdentifier = @"kSearchBarTableViewControllerDefaultTableViewCellIdentifier";

@interface FriendsListViewController ()

@property(nonatomic, copy) NSArray *friends;
@property(nonatomic, copy) NSArray *sections;

@property(nonatomic, copy) NSArray *filteredFriends;
@property(nonatomic, copy) NSString *currentSearchString;

@property(nonatomic, strong, readwrite) UITableView *tableView;
@property(nonatomic, strong, readwrite) UISearchBar *searchBar;

@property(nonatomic, strong) UISearchDisplayController *strongSearchDisplayController;

@property (nonatomic) NSArray *jsonGetFriends;
@property (nonatomic) NSDictionary *jsonAddFriend;
@property (nonatomic) NSDictionary *jsonDeleteFriend;

@property (nonatomic) UITextField *textField;

@property (nonatomic) NSString* addEmail;
@property (nonatomic) NSString* deleteEmail;

- (IBAction)addFriendAlert:(id)sender;
- (IBAction)deleteFriendAlert:(id)sender;

@end

@implementation FriendsListViewController

// Disposes of any resources that can be recreated.
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

//Initialization for FriendsList view. Sets the title
//and sets the boolean to use section indexes
- (id)initWithSectionIndexes:(BOOL)showSectionIndexes
{
    if ((self = [super initWithNibName:nil bundle:nil])) {
        self.title = @"Friends";
        
        _showSectionIndexes = showSectionIndexes;
        
    }
    
    return self;
}

//When the view appears, loads the users friends
-(void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self loadFriends];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

//Sets up the table view and the search bar
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight-42)];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self.view addSubview:self.tableView];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    self.searchBar.placeholder = @"Search";
    self.searchBar.delegate = self;
    
    [self.searchBar sizeToFit];
    
    self.strongSearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.searchDisplayController.searchResultsDataSource = self;
    self.searchDisplayController.searchResultsDelegate = self;
    self.searchDisplayController.delegate = self;
    
    
}

//shows the scroll bar for a brief moment when the view appears
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (animated) {
        [self.tableView flashScrollIndicators];
    }
}

//safety measure which makes sure AJNotifications don't bug out
//when the view disappears while one is active
- (void)viewDidDisappear:(BOOL)animated
{
    [AJNotificationView hideCurrentNotificationViewAndClearQueue];
}

//moves the table view up to the search bar when the search icon
//is clicked on the section index control
- (void)scrollTableViewToSearchBarAnimated:(BOOL)animated
{
    NSAssert(YES, @"This method should be handled by a subclass!");
}

#pragma mark - TableView Delegate and DataSource

//sets the section index control display titles
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (tableView == self.tableView && self.showSectionIndexes) {
        return [[NSArray arrayWithObject:UITableViewIndexSearch] arrayByAddingObjectsFromArray:[[UILocalizedIndexedCollation currentCollation] sectionIndexTitles]];
    } else {
        return nil;
    }
}

//sets the title of each of the table view's sections
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tableView && self.showSectionIndexes) {
        if ([[self.sections objectAtIndex:section] count] > 0) {
            return [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section];
        } else {
            return nil;
        }
    } else {
        return nil;
    }
}

//sets the section index control connections with section headers
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if ([title isEqualToString:UITableViewIndexSearch]) {
        [self scrollTableViewToSearchBarAnimated:NO];
        return NSNotFound;
    } else {
        return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index] - 1; // -1 because we add the search symbol
    }
}

//sets the number of sections displayed in the table
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.tableView) {
        if (self.showSectionIndexes) {
            return self.sections.count;
        } else {
            return 1;
        }
    } else {
        return 1;
    }
}

//sets the number of rows displayed in the table view determined
//by the number of friends and how the view is being displayed
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        if (self.showSectionIndexes) {
            return [[self.sections objectAtIndex:section] count];
        } else {
            return self.friends.count;
        }
    } else {
        return self.filteredFriends.count;
    }
}

//Displays the correct name and profile image of each friend in the cell where
//their respective json string object is located. A default profile image
//is displayed if no gravatar image for the friend's email exists. 
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSearchBarTableViewControllerDefaultTableViewCellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kSearchBarTableViewControllerDefaultTableViewCellIdentifier];
    }
    
    if (tableView == self.tableView) {
        if (self.showSectionIndexes) {
            NSString* cellName = [[[self.sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"name"];
            cell.textLabel.text = cellName;
            
            NSString* cellEmail = [[[self.sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"email"];
            
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(queue, ^{
                dispatch_async(dispatch_get_main_queue(), ^ {
                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
                });
            
                NSData *gravPic = self.jsonGetFriends ? [GravitarUtilityClass requestGravatar:[GravitarUtilityClass getGravatarURL:cellEmail]] : nil;
                dispatch_async(dispatch_get_main_queue(), ^ {
                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            
                    if(gravPic)
                    {
                        cell.imageView.image = [UIImage imageWithData:gravPic];
                    }
                    else
                        cell.imageView.image = [UIImage imageNamed:@"DefaultProfilePic.png"];

                });
            });
            
            if(!cell.imageView.image)
            {
                cell.imageView.image = [UIImage imageNamed:@"DefaultProfilePic.png"];
            }

        }
        else {
            NSString* cellName = [[self.friends objectAtIndex:indexPath.row] objectForKey:@"name"];
            cell.textLabel.text = cellName;
            
            NSString* cellEmail = [[self.friends objectAtIndex:indexPath.row] objectForKey:@"email"];
            
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(queue, ^{
                dispatch_async(dispatch_get_main_queue(), ^ {
                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
                });
                
                NSData *gravPic = self.jsonGetFriends ? [GravitarUtilityClass requestGravatar:[GravitarUtilityClass getGravatarURL:cellEmail]] : nil;
                dispatch_async(dispatch_get_main_queue(), ^ {
                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                    
                    if(gravPic)
                    {
                        cell.imageView.image = [UIImage imageWithData:gravPic];
                    }
                    else
                        cell.imageView.image = [UIImage imageNamed:@"DefaultProfilePic.png"];
                    
                });
            });
            
            if(!cell.imageView.image)
            {
                cell.imageView.image = [UIImage imageNamed:@"DefaultProfilePic.png"];
            }
        }
    }
    else {
        NSString* cellName = [[self.filteredFriends objectAtIndex:indexPath.row] objectForKey:@"name"];
        cell.textLabel.text = cellName;
        
        NSString* cellEmail = [[self.filteredFriends objectAtIndex:indexPath.row] objectForKey:@"email"];
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            dispatch_async(dispatch_get_main_queue(), ^ {
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            });
            
            NSData *gravPic = self.jsonGetFriends ? [GravitarUtilityClass requestGravatar:[GravitarUtilityClass getGravatarURL:cellEmail]] : nil;
            dispatch_async(dispatch_get_main_queue(), ^ {
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                
                if(gravPic)
                {
                    cell.imageView.image = [UIImage imageWithData:gravPic];
                }
                else
                    cell.imageView.image = [UIImage imageNamed:@"DefaultProfilePic.png"];
                
            });
        });
        
        if(!cell.imageView.image)
        {
            cell.imageView.image = [UIImage imageNamed:@"DefaultProfilePic.png"];
        }
    }
    
    return cell;
}

//Pushes a friend account view controller which displays the friend's profile pic,
//username, full name, and email when you click their name in the friends list. A delete
//friend button is also displayed at the bottom of the pushed view. 
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *email, *username, *name;

    if (tableView == self.tableView) {
        if (self.showSectionIndexes) {
            email = [[[self.sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"email"];
            username = [[[self.sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"username"];
            name = [[[self.sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"name"];
        } else {
            email = [[self.friends objectAtIndex:indexPath.row] objectForKey:@"email"];
            username = [[self.friends objectAtIndex:indexPath.row] objectForKey:@"username"];
            name = [[self.friends objectAtIndex:indexPath.row] objectForKey:@"name"];
        }
    } else {
        email = [[self.filteredFriends objectAtIndex:indexPath.row] objectForKey:@"email"];
        username = [[self.filteredFriends objectAtIndex:indexPath.row] objectForKey:@"username"];
        name = [[self.filteredFriends objectAtIndex:indexPath.row] objectForKey:@"name"];
    }
    
    FriendAccountViewController *vc = [[FriendAccountViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [vc setUser:_user];
    [vc setEmail:email];
    [vc setUsername:username];
    [vc setName:name];

    [self.navigationController pushViewController:vc animated:YES];
        
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - Delete Friends

//swiping from the left or right on a friend's name displays a delete button.
//If the button is pressed then a delete friend alert is displayed to confirm
//the removal of the friend. 
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        if (tableView == self.tableView) {
            if (self.showSectionIndexes) {
                _deleteEmail = [[[self.sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"email"];
            } else {
                _deleteEmail = [[self.friends objectAtIndex:indexPath.row] objectForKey:@"email"];
            }
        } else {
            _deleteEmail = [[self.filteredFriends objectAtIndex:indexPath.row] objectForKey:@"email"];
        }
        [self deleteFriendAlert:self];
    }
}

//Sends a server request to delete a friend from the user's friendships.
//Reloads the friends list after a deletion is successfully made.
- (void)deleteFriend
{
    NSString *user = [_user token];
    NSDictionary *jsonDictionary = @{ @"access_token" : user, @"email": _deleteEmail };
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^ {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        });
        self.jsonDeleteFriend = [UtilityClass SendJSON:jsonDictionary toAddress:@"http://54.225.76.23:3000/deletefriend"];
        dispatch_async(dispatch_get_main_queue(), ^ {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            if(self.jsonDeleteFriend)
            {
                if([self.jsonDeleteFriend[@"deleted"] boolValue])
                {
                    NSLog(@"%@ successfully removed from friends list.", _deleteEmail);
                    [self loadFriends];
                    [self.searchDisplayController setActive:NO animated:YES];
                    NSString *title = _deleteEmail;
                    title = [title stringByAppendingString:@" successfully removed from friends list"];
                    [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeGreen
                                                   title:title
                                         linedBackground:AJLinedBackgroundTypeDisabled
                                               hideAfter:BANNER_DEFAULT_TIME];
                }
                else
                {
                    NSLog(@"%@ could not be removed from your friends list. Try again.", _deleteEmail);
                    NSString *title = _deleteEmail;
                    title = [title stringByAppendingString:@" could not be removed from your friends list"];
                    [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeRed
                                                   title:title
                                         linedBackground:AJLinedBackgroundTypeDisabled
                                               hideAfter:BANNER_DEFAULT_TIME];
                }
            }
            else
            {
                NSLog(@"Http request failed.");
                [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeRed
                                               title:@"Server request failed"
                                     linedBackground:AJLinedBackgroundTypeDisabled
                                           hideAfter:BANNER_DEFAULT_TIME];
            }
        });
    });
}

//Generates the delete friend alert asking for confirmation on the deletion
- (IBAction)deleteFriendAlert:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Deleting Friend"
                          message:@"Are you sure you want to unfriend this person?"
                          delegate:self
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@"Confirm", nil];
    alert.tag = TAG_DELETE;
    [alert show];
}

#pragma mark - Search Delegate

//sets the displayed friends for a search to nil and the current search string
//to blank.
- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    self.filteredFriends = nil;
    self.currentSearchString = @"";
}

//sets the displayed friends for a search to nil and the current search string to nil
- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    self.filteredFriends = nil;
    self.currentSearchString = nil;
}

//displays friends whose names contain the current search string. When the search string
//changes the search tableview is updated with the correct listing of friends. 
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    if (searchString.length > 0) { // Should always be the case
        NSArray *personsToSearch = _friends;
        if (self.currentSearchString.length > 0 && [searchString rangeOfString:self.currentSearchString].location == 0) { // If the new search string starts with the last search string, reuse the already filtered array so searching is faster
            personsToSearch = self.filteredFriends;
        }
        
        self.filteredFriends = [personsToSearch filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name contains[cd] %@", searchString]];
    } else {
        self.filteredFriends = _friends;
    }
    
    self.currentSearchString = searchString;
    
    return YES;
}

#pragma mark - Get Friends

//Pulls the current user's friends from the server as an array of JSON strings.
//The sections are generated from the friends' names and each respective index
//in the friends list is loaded with a friend JSON string. 
- (void)loadFriends
{
    NSString *user = [_user token];
    NSDictionary *jsonDictionary = @{ @"access_token" : user};
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^ {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        });
        self.jsonGetFriends = [UtilityClass GetFriendsJSON:jsonDictionary toAddress:@"http://54.225.76.23:3000/friends"];
        dispatch_async(dispatch_get_main_queue(), ^ {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            if(self.jsonGetFriends)
            {
                _friends = [[NSArray alloc ] initWithArray: self.jsonGetFriends];
                NSMutableArray *mutableFriends = [_friends mutableCopy];
                [_user setFriends:mutableFriends];
            }
            else
            {
                NSLog(@"Http request for friends list failed.");
                [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeRed
                                               title:@"Could not retrieve your friends list"
                                     linedBackground:AJLinedBackgroundTypeDisabled
                                           hideAfter:BANNER_DEFAULT_TIME];
            }
            
            UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
            
            NSMutableArray *unsortedSections = [[NSMutableArray alloc] initWithCapacity:[[collation sectionTitles] count]];
            
            for (NSUInteger i = 0; i < [[collation sectionTitles] count]; i++) {
                [unsortedSections addObject:[NSMutableArray array]];
            }
            
            for (NSDictionary* friend in _friends) {
                NSString* name = [friend objectForKey:@"name"];
                NSInteger index = [collation sectionForObject:name collationStringSelector:@selector(description)];
                [[unsortedSections objectAtIndex:index] addObject:friend];
            }
            
            NSMutableArray *sortedSections = [[NSMutableArray alloc] initWithCapacity:unsortedSections.count];
            for (NSMutableArray *section in unsortedSections) {
                [sortedSections addObject:[collation sortedArrayFromArray:section collationStringSelector:@selector(description)]];
            }
            
            self.sections = sortedSections;
            [self.tableView reloadData];
        });
    });
}

#pragma mark - Add Friend

//generates an addfriendalert action
- (void)addFriendButton
{
    NSLog(@"Add a Friend");
    [self addFriendAlert:self];
}

//pushes the current view to the list of all users for adding friends
- (IBAction)addFriendAlert:(id)sender
{
    AddFriendSearchBarTableViewController *vc = [[AddFriendSearchBarTableViewController alloc] initWithSectionIndexes:YES];
    [vc setUser:_user];
    [self.navigationController pushViewController:vc animated:YES];
    
}

#pragma mark - Alert Views

//Determines what action to take for each button index of an alert
//depending on the alert tag
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString* detailString = _textField.text;
    NSLog(@"Email is: %@", detailString); //Put it on the debugger
    if(alertView.tag == TAG_DELETE && buttonIndex == 0)
    {
        return;
    }
    if(alertView.tag == TAG_DELETE && buttonIndex == 1)
    {
        [self deleteFriend];
    }
}

@end