//
//  UserAccountViewController.h
//  MyM
//
//  Created by Steven Zilberberg on 4/21/13.
//  Copyright (c) 2013 MyM Co. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Moment.h"

@interface UserAccountViewController : UITableViewController <UIAlertViewDelegate>

@property (strong, nonatomic) User *user;

@end
