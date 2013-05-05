//
//  AddFriendViewController.m
//  MyM
//
//  Created by Justin Wagner on 4/3/13.
//  Copyright (c) 2013 MyM Co. All rights reserved.
//

#import "AddFriendViewController.h"
#import "UtilityClass.h"
#import "GravitarUtilityClass.h"
#import "AJNotificationView.h"
#import "SearchBarTableViewController.h"

#define BANNER_DEFAULT_TIME 2
#define TAG_ADD_EMAIL 1
#define TAG_DELETE 2
#define TAG_ADD 3

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

- (IBAction)addFriendAlert:(id)sender;

@end

@implementation AddFriendViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (id)initWithSectionIndexes:(BOOL)showSectionIndexes
{
    if ((self = [super initWithNibName:nil bundle:nil])) {
        self.title = @"Add Friends";
        
        _showSectionIndexes = showSectionIndexes;
        
    }
    return self;
}

-(void) viewWillAppear:(BOOL)animated
{
    [self loadUsers];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 416)];
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (animated) {
        [self.tableView flashScrollIndicators];
        //[_searchBar becomeFirstResponder];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [AJNotificationView hideCurrentNotificationViewAndClearQueue];
}

- (void)scrollTableViewToSearchBarAnimated:(BOOL)animated
{
    NSAssert(YES, @"This method should be handled by a subclass!");
}

#pragma mark - TableView Delegate and DataSource

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (tableView == self.tableView && self.showSectionIndexes) {
        return [[NSArray arrayWithObject:UITableViewIndexSearch] arrayByAddingObjectsFromArray:[[UILocalizedIndexedCollation currentCollation] sectionIndexTitles]];
    } else {
        return nil;
    }
}

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

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if ([title isEqualToString:UITableViewIndexSearch]) {
        [self scrollTableViewToSearchBarAnimated:NO];
        return NSNotFound;
    } else {
        return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index] - 1; // -1 because we add the search symbol
    }
}

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

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    self.filteredUsers = nil;
    self.currentSearchString = @"";
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    self.filteredUsers = nil;
    self.currentSearchString = nil;
}

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
                NSLog(@"Http request for friends list failed.");
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

- (void)addFriendByEmailButton
{
    NSLog(@"Add a Friend");
    [self addFriendByEmailAlert:self];
}

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
                            NSLog(@"Friend request sent.");
                            [AJNotificationView showNoticeInView:self.tableView type:AJNotificationTypeGreen
                                                           title:@"Friend request email successfully sent"
                                                 linedBackground:AJLinedBackgroundTypeDisabled
                                                       hideAfter:BANNER_DEFAULT_TIME];
                        }
                        else
                        {
                            NSLog(@"Friend request failed to send.");
                            [AJNotificationView showNoticeInView:self.tableView type:AJNotificationTypeRed
                                                           title:@"Failed to send friend request"
                                                 linedBackground:AJLinedBackgroundTypeDisabled
                                                       hideAfter:BANNER_DEFAULT_TIME];
                        }
                    }
                    else
                    {
                        NSLog(@"Friend does not exist.");
                        [AJNotificationView showNoticeInView:self.tableView type:AJNotificationTypeRed
                                                       title:@"User does not exist"
                                             linedBackground:AJLinedBackgroundTypeDisabled
                                                   hideAfter:BANNER_DEFAULT_TIME];
                    }
                }
                else
                {
                    NSLog(@"Already friends with this person.");
                    [AJNotificationView showNoticeInView:self.tableView type:AJNotificationTypeRed
                                                   title:@"You are already friends with this person"
                                         linedBackground:AJLinedBackgroundTypeDisabled
                                               hideAfter:BANNER_DEFAULT_TIME];
                }
            }
            else if(!self.jsonAddFriend)
            {
                NSLog(@"Http request failed.");
                [AJNotificationView showNoticeInView:self.tableView type:AJNotificationTypeRed
                                               title:@"Server request failed"
                                     linedBackground:AJLinedBackgroundTypeDisabled
                                           hideAfter:BANNER_DEFAULT_TIME];
            }
        });
    });

}

#pragma mark - Alert Views

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString* detailString = _textField.text;
    NSLog(@"Email is: %@", detailString); //Put it on the debugger
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