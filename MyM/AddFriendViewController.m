/*
 * MyM: Map Your Moments "A Digital Travelogue"
 *
 * Developed using iOS and AWS for CSC Special Topics: Cloud Computing, Spring 2013 by
 * Adam Cumiskey, Dave Hand, Tim Honeywell, Marcelo Mazzotti, Justin Wagner, and Steven Zilberberg
 *
 * AddFriendViewController.m
 * Displays a tableview of all users currently registered on MyM. A user can click on a name
 * to send a friend request to that user. A user can also search for a user's name in the search bar
 * and click on their name to send them a friend request. Furthermore, if a user clicks the top right
 * navigation bar button he/she can send a friend request to a specified email of a user if the email exists.
 *
 */

#import "AddFriendViewController.h"
#import "UtilityClass.h"
#import "GravitarUtilityClass.h"
#import "AJNotificationView.h"
#import "SearchBarTableViewController.h"

#define BANNER_DEFAULT_TIME 2

#define TAG_ADD_EMAIL 1
#define TAG_ADD 2

#define screenWidth [[UIScreen mainScreen] applicationFrame].size.width
#define screenHeight [[UIScreen mainScreen] applicationFrame].size.height

#define screenWidth [[UIScreen mainScreen] applicationFrame].size.width
#define screenHeight [[UIScreen mainScreen] applicationFrame].size.height

static NSString * const kSearchBarTableViewControllerDefaultTableViewCellIdentifier = @"kSearchBarTableViewControllerDefaultTableViewCellIdentifier";

@interface AddFriendViewController ()

@property(nonatomic, copy) NSArray *users;
@property(nonatomic, copy) NSArray *sections;

@property(nonatomic, copy) NSArray *filteredUsers;
@property(nonatomic, copy) NSString *currentSearchString;

@property(nonatomic, strong, readwrite) UITableView *tableView;
@property(nonatomic, strong, readwrite) UISearchBar *searchBar;

@property(nonatomic, strong) UISearchDisplayController *strongSearchDisplayController;

@property (nonatomic) NSArray *jsonGetUsers;
@property (nonatomic) NSDictionary *jsonAddFriend;
@property (nonatomic) NSDictionary *jsonAddFriendByEmail;

@property (nonatomic) UITextField *textField;

@property (nonatomic) NSString* addEmail;

@end

@implementation AddFriendViewController

// Dispose of any resources that can be recreated.
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

//Initializes the view's title and boolean for showing sections
- (id)initWithSectionIndexes:(BOOL)showSectionIndexes
{
    if ((self = [super initWithNibName:nil bundle:nil])) {
        self.title = @"Add Friends";
        
        _showSectionIndexes = showSectionIndexes;
        
    }
    return self;
}

//Loads all the users into the table view when the view appears
-(void) viewWillAppear:(BOOL)animated
{
    [self loadUsers];
}

//loads the tableview and the search bar
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

//displays the scroll bar for a brief second
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (animated) {
        [self.tableView flashScrollIndicators];
        //[_searchBar becomeFirstResponder];
    }
}

//safety measure against bug that may appear when a
//AJNotification is displaying when the view changes
- (void)viewDidDisappear:(BOOL)animated
{
    [AJNotificationView hideCurrentNotificationViewAndClearQueue];
}

//scrolls table view to the search bar
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
//by the number of users and how the view is being displayed
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        if (self.showSectionIndexes) {
            return [[self.sections objectAtIndex:section] count];
        } else {
            return self.users.count;
        }
    } else {
        return self.filteredUsers.count;
    }
}

//Displays the correct name and profile image of each user in the cell where
//their respective json string object is located. A default profile image
//is displayed if no gravatar image for the user's email exists.
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
            
                NSData *gravPic = self.jsonGetUsers ? [GravitarUtilityClass requestGravatar:[GravitarUtilityClass getGravatarURL:cellEmail]] : nil;
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
            NSString* cellName = [[self.users objectAtIndex:indexPath.row] objectForKey:@"name"];
            cell.textLabel.text = cellName;
            
            NSString* cellEmail = [[self.users objectAtIndex:indexPath.row] objectForKey:@"email"];
            
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(queue, ^{
                dispatch_async(dispatch_get_main_queue(), ^ {
                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
                });
                
                NSData *gravPic = self.jsonGetUsers ? [GravitarUtilityClass requestGravatar:[GravitarUtilityClass getGravatarURL:cellEmail]] : nil;
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
        NSString* cellName = [[self.filteredUsers objectAtIndex:indexPath.row] objectForKey:@"name"];
        cell.textLabel.text = cellName;
        
        NSString* cellEmail = [[self.filteredUsers objectAtIndex:indexPath.row] objectForKey:@"email"];
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            dispatch_async(dispatch_get_main_queue(), ^ {
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            });
            
            NSData *gravPic = self.jsonGetUsers ? [GravitarUtilityClass requestGravatar:[GravitarUtilityClass getGravatarURL:cellEmail]] : nil;
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

//calls an addFriend alert to add the friend at the selected index
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
        if (self.showSectionIndexes) {
            _addEmail = [[[self.sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"email"];
        } else {
            _addEmail = [[self.users objectAtIndex:indexPath.row] objectForKey:@"email"];
        }
    } else {
        _addEmail = [[self.filteredUsers objectAtIndex:indexPath.row] objectForKey:@"email"];
    }
    [self addFriendByClickAlert:self];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - Search Delegate

//sets the displayed users for a search to nil and the current search string
//to blank.
- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    self.filteredUsers = nil;
    self.currentSearchString = @"";
}

//sets the displayed users for a search to nil and the current search string to nil
- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    self.filteredUsers = nil;
    self.currentSearchString = nil;
}

//displays users whose names contain the current search string. When the search string
//changes the search tableview is updated with the correct listing of users.
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    if (searchString.length > 0) { // Should always be the case
        NSArray *personsToSearch = _users;
        if (self.currentSearchString.length > 0 && [searchString rangeOfString:self.currentSearchString].location == 0) { // If the new search string starts with the last search string, reuse the already filtered array so searching is faster
            personsToSearch = self.filteredUsers;
        }
        
        self.filteredUsers = [personsToSearch filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name contains[cd] %@", searchString]];
    } else {
        self.filteredUsers = _users;
    }
    
    self.currentSearchString = searchString;
    
    return YES;
}

#pragma mark - Get Users

//Pulls all the users from the server as an array of JSON strings.
//The sections are generated from the users' names and each respective index
//in the table view is loaded with a user JSON string.
- (void)loadUsers
{
    NSDictionary *jsonDictionary = @{};
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^ {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        });
        self.jsonGetUsers = [UtilityClass GetFriendsJSON:jsonDictionary toAddress:@"http://54.225.76.23:3000/get_all_users"];
        dispatch_async(dispatch_get_main_queue(), ^ {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            if(self.jsonGetUsers)
            {
                _users = [[NSArray alloc ] initWithArray: self.jsonGetUsers];
            }
            else
            {
                //NSLog(@"Http request for friends list failed.");
                [AJNotificationView showNoticeInView:self.tableView type:AJNotificationTypeRed
                                               title:@"Could not retrieve your friends list"
                                     linedBackground:AJLinedBackgroundTypeDisabled
                                           hideAfter:BANNER_DEFAULT_TIME];
            }
            
            UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
            
            NSMutableArray *unsortedSections = [[NSMutableArray alloc] initWithCapacity:[[collation sectionTitles] count]];
            
            for (NSUInteger i = 0; i < [[collation sectionTitles] count]; i++) {
                [unsortedSections addObject:[NSMutableArray array]];
            }
            
            for (NSDictionary* user in _users) {
                NSString* name = [user objectForKey:@"name"];
                NSInteger index = [collation sectionForObject:name collationStringSelector:@selector(description)];
                [[unsortedSections objectAtIndex:index] addObject:user];
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

//calls for an addFriendByEmail alert to be displayed
- (void)addFriendByEmailButton
{
    //NSLog(@"Add a Friend");
    [self addFriendByEmailAlert:self];
}

//Generates an alert with a text field where a user
//can input a potential friend's email and send a friend
//request to them.
- (IBAction)addFriendByEmailAlert:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Friend Request"
                          message:@"Please enter the user's email\n\n\n"
                          delegate:self
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@"Send", nil];
    
    _textField = [[UITextField alloc] init];
    [_textField setBackgroundColor:[UIColor whiteColor]];
    _textField.borderStyle = UITextBorderStyleRoundedRect;
    _textField.frame = CGRectMake(15, 75, 255, 30);
    _textField.font = [UIFont fontWithName:@"ArialMT" size:20];
    _textField.adjustsFontSizeToFitWidth = YES;
    _textField.minimumFontSize = 10;
    _textField.placeholder = @"email@example.com";
    _textField.textAlignment = NSTextAlignmentCenter;
    _textField.keyboardAppearance = UIKeyboardAppearanceDefault;
    [_textField becomeFirstResponder];
    [alert addSubview:_textField];
    
    alert.tag = TAG_ADD_EMAIL;
    [alert show];
    
}

//Action that generates a send friend request alert
//when a user's name is clicked in the table view
- (IBAction)addFriendByClickAlert:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Friend Request"
                          message:nil
                          delegate:self
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@"Send", nil];
    alert.tag = TAG_ADD;
    [alert show];
    
}


//Send a server request to add a user as a friend
- (void)addFriend
{
    NSString *user = [_user token];
    
    NSDictionary *jsonDictionary = @{  @"access_token" : user,  @"email" : _addEmail };
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^ {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        });
        self.jsonAddFriend = [UtilityClass SendJSON:jsonDictionary toAddress:@"http://54.225.76.23:3000/createfriend/"];
        dispatch_async(dispatch_get_main_queue(), ^ {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            if(self.jsonAddFriend)
            {
                if(![self.jsonAddFriend[@"friends"] boolValue])
                {
                    if([self.jsonAddFriend[@"exists"] boolValue])
                    {
                        if([self.jsonAddFriend[@"created"] boolValue])
                        {
                            //NSLog(@"Friend request sent.");
                            [self.tableView scrollRectToVisible:self.searchBar.frame animated:YES];
                            [AJNotificationView showNoticeInView:self.tableView type:AJNotificationTypeGreen
                                                           title:@"Friend request email successfully sent"
                                                 linedBackground:AJLinedBackgroundTypeDisabled
                                                       hideAfter:BANNER_DEFAULT_TIME];
                        }
                        else
                        {
                            //NSLog(@"Friend request failed to send.");
                            [self.tableView scrollRectToVisible:self.searchBar.frame animated:YES];
                            [AJNotificationView showNoticeInView:self.tableView type:AJNotificationTypeRed
                                                           title:@"Failed to send friend request"
                                                 linedBackground:AJLinedBackgroundTypeDisabled
                                                       hideAfter:BANNER_DEFAULT_TIME];
                        }
                    }
                    else
                    {
                        //NSLog(@"Friend does not exist.");
                        [self.tableView scrollRectToVisible:self.searchBar.frame animated:YES];
                        [AJNotificationView showNoticeInView:self.tableView type:AJNotificationTypeRed
                                                       title:@"User does not exist"
                                             linedBackground:AJLinedBackgroundTypeDisabled
                                                   hideAfter:BANNER_DEFAULT_TIME];
                    }
                }
                else
                {
                    //NSLog(@"Already friends with this person.");
                    [self.tableView scrollRectToVisible:self.searchBar.frame animated:YES];
                    [AJNotificationView showNoticeInView:self.tableView type:AJNotificationTypeRed
                                                   title:@"You are already friends with this person"
                                         linedBackground:AJLinedBackgroundTypeDisabled
                                               hideAfter:BANNER_DEFAULT_TIME];
                }
            }
            else if(!self.jsonAddFriend)
            {
                //NSLog(@"Http request failed.");
                [AJNotificationView showNoticeInView:self.tableView type:AJNotificationTypeRed
                                               title:@"Server request failed"
                                     linedBackground:AJLinedBackgroundTypeDisabled
                                           hideAfter:BANNER_DEFAULT_TIME];
            }
        });
    });

}

#pragma mark - Alert Views

//Determines the action to take depending upon the alert's tag and the
//index of the button that was clicked
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString* detailString = _textField.text;
    //NSLog(@"Email is: %@", detailString); //Put it on the debugger
    if (alertView.tag == TAG_ADD_EMAIL && ([_textField.text length] <= 0 || buttonIndex == 0)){
        _textField.text = NULL;
        return; //If cancel or 0 length string the string doesn't matter
    }
    if (alertView.tag == TAG_ADD_EMAIL && buttonIndex == 1) {
        _addEmail = _textField.text;
        [self addFriend];
    }
    if(alertView.tag == TAG_ADD && buttonIndex == 0)
    {
        return;
    }
    if(alertView.tag == TAG_ADD && buttonIndex == 1)
    {
        [self addFriend];
    }
}

@end