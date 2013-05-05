//
//  FriendsListViewController.m
//  MyM
//
//  Created by Justin Wagner on 4/3/13.
//  Copyright (c) 2013 MyM Co. All rights reserved.
//

#import "FriendsListViewController.h"
#import "UtilityClass.h"
#import "GravitarUtilityClass.h"
#import "FriendAccountViewController.h"
#import "AJNotificationView.h"
#import "SearchBarTableViewController.h"
#import "AddFriendSearchBarTableViewController.h"

#define BANNER_DEFAULT_TIME 2
#define TAG_ADD_EMAIL 1
#define TAG_DELETE 2
#define TAG_ADD 3

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (id)initWithSectionIndexes:(BOOL)showSectionIndexes
{
    if ((self = [super initWithNibName:nil bundle:nil])) {
        self.title = @"Friends";
        
        _showSectionIndexes = showSectionIndexes;
        
    }
    
    return self;
}

-(void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self loadFriends];
}

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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (animated) {
        [self.tableView flashScrollIndicators];
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
            return self.friends.count;
        }
    } else {
        return self.filteredFriends.count;
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

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    self.filteredFriends = nil;
    self.currentSearchString = @"";
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    self.filteredFriends = nil;
    self.currentSearchString = nil;
}

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

- (void)addFriendButton
{
    NSLog(@"Add a Friend");
    [self addFriendAlert:self];
}

- (IBAction)addFriendAlert:(id)sender
{
    AddFriendSearchBarTableViewController *vc = [[AddFriendSearchBarTableViewController alloc] initWithSectionIndexes:YES];
    [vc setUser:_user];
    [self.navigationController pushViewController:vc animated:YES];
    
}

#pragma mark - Alert Views

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