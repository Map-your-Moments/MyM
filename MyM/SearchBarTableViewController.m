//
//  FKRDefaultSearchBarTableViewController.m
//  TableViewSearchBar
//


#import "SearchBarTableViewController.h"

@implementation SearchBarTableViewController

#pragma mark - Initializer

- (id)initWithSectionIndexes:(BOOL)showSectionIndexes
{
    if ((self = [super initWithSectionIndexes:showSectionIndexes])) {
        self.title = @"Friends";
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
    self.tableView.contentOffset = CGPointMake(0, CGRectGetHeight(self.searchBar.bounds));
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:@"Add"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(addFriendButton)];
    self.navigationItem.rightBarButtonItem = addButton;
}

- (void)scrollTableViewToSearchBarAnimated:(BOOL)animated
{
    [self.tableView scrollRectToVisible:self.searchBar.frame animated:animated];
}

@end