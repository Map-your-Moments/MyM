//
//  AddFriendSearchBarTableViewController.m
//  TableViewSearchBar
//


#import "AddFriendSearchBarTableViewController.h"

@implementation AddFriendSearchBarTableViewController

#pragma mark - Initializer

- (id)initWithSectionIndexes:(BOOL)showSectionIndexes
{
    if ((self = [super initWithSectionIndexes:showSectionIndexes])) {
        self.title = @"Add Friend";
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /*
     Default behavior:
     The search bar scrolls along with the table view.
    */
    
    self.tableView.tableHeaderView = self.searchBar;
    
    // The search bar is hidden when the view becomes visible the first time
//    self.tableView.contentOffset = CGPointMake(0, CGRectGetHeight(self.searchBar.bounds));
    
    UIBarButtonItem *addFriendByEmailButton = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                   target:self action:@selector(addFriendByEmailButton)];
    
    self.navigationItem.rightBarButtonItem = addFriendByEmailButton;
}

- (void)scrollTableViewToSearchBarAnimated:(BOOL)animated
{
    [self.tableView scrollRectToVisible:self.searchBar.frame animated:animated];
}

@end