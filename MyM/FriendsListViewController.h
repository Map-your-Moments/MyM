//
//  FriendsListViewController.h
//  MyM
//
//  Created by Justin Wagner on 4/3/13.
//  Copyright (c) 2013 MyM Co. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendsListViewController : UIViewController <UITableViewDataSource,
                                    UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate>

- (id)initWithSectionIndexes:(BOOL)showSectionIndexes;

- (void)scrollTableViewToSearchBarAnimated:(BOOL)animated;

@property(nonatomic, assign, readonly) BOOL showSectionIndexes;

@property(nonatomic, strong, readonly) UITableView *tableView;
@property(nonatomic, strong, readonly) UISearchBar *searchBar;

//@property (nonatomic) NSMutableArray *friends;

@end
