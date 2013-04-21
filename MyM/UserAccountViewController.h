//
//  UserAccountViewController.h
//  MyM
//
//  Created by Steven Zilberberg on 4/21/13.
//  Copyright (c) 2013 MyM Co. All rights reserved.
//

#import <UIKit/UIKit.h>

@class User;

@interface UserAccountViewController : UITableViewController

@property (strong, nonatomic) User *targetuser;

@end
