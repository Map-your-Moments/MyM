/*
 * MyM: Map Your Moments "A Digital Travelogue"
 *
 * Developed using iOS and AWS for CSC Special Topics: Cloud Computing, Spring 2013 by
 * Adam Cumiskey, Dave Hand, Tim Honeywell, Marcelo Mazzotti, Justin Wagner, and Steven Zilberberg
 *
 * SearchBarTableViewController.m
 * View for the friends list's search bar. Sets the search bar to be hidden when the view loads.
 * Has a method for scrolling the view to the search bar when the section index icon is selected.
 *
 */

#import "SearchBarTableViewController.h"

@implementation SearchBarTableViewController

#pragma mark - Initializer

//Initializes the view with the title "Friends"
- (id)initWithSectionIndexes:(BOOL)showSectionIndexes
{
    if ((self = [super initWithSectionIndexes:showSectionIndexes])) {
        self.title = @"Friends";
    }
    
    return self;
}

//loads the search bar display and adds a + button to the right side of the
//navigation bar for adding friends
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /*
     Default behavior:
     The search bar scrolls along with the table view.
    */
    
    self.tableView.tableHeaderView = self.searchBar;
    
    // The search bar is hidden when the view becomes visible the first time
    self.tableView.contentOffset = CGPointMake(0, CGRectGetHeight(self.searchBar.bounds));
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                   target:self action:@selector(addFriendButton)];
    
    self.navigationItem.rightBarButtonItem = addButton;
}

//moves the table view up to display the search bar
- (void)scrollTableViewToSearchBarAnimated:(BOOL)animated
{
    [self.tableView scrollRectToVisible:self.searchBar.frame animated:animated];
}

@end