/*
 * MyM: Map Your Moments "A Digital Travelogue"
 *
 * Developed using iOS and AWS for CSC Special Topics: Cloud Computing, Spring 2013 by
 * Adam Cumiskey, Dave Hand, Tim Honeywell, Marcelo Mazzotti, Justin Wagner, and Steven Zilberberg
 *
 * AddFriendSearchBarTableViewController.m
 * View for the user list's search bar. Search bar visible when the view loads.
 * Has a method for scrolling the view to the search bar when the section index icon is selected.
 *
 */

#import "AddFriendSearchBarTableViewController.h"

@implementation AddFriendSearchBarTableViewController

#pragma mark - Initializer

//Initializes the view with the title "Add Friend"
- (id)initWithSectionIndexes:(BOOL)showSectionIndexes
{
    if ((self = [super initWithSectionIndexes:showSectionIndexes])) {
        self.title = @"Add Friend";
    }
    
    return self;
}

//Loads the view with the scroll bar visible at the top of the tableview
//The right navigation bar button is set to add friend's by email and brings
//up an alert view to accomplish this. 
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /*
     Default behavior:
     The search bar scrolls along with the table view.
    */
    
    // The search bar is visible when the view becomes visible the first time
    self.tableView.tableHeaderView = self.searchBar;
    
    UIBarButtonItem *addFriendByEmailButton = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                   target:self action:@selector(addFriendByEmailButton)];
    
    self.navigationItem.rightBarButtonItem = addFriendByEmailButton;
}

//scrolls the tableview to the search bar
- (void)scrollTableViewToSearchBarAnimated:(BOOL)animated
{
    [self.tableView scrollRectToVisible:self.searchBar.frame animated:animated];
}

@end