//
//  UserAccountViewController.h
//  MyM
//
//  Created by Steven Zilberberg on 4/21/13.
//  Copyright (c) 2013 MyM Co. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Moment.h"

@interface FriendAccountViewController : UITableViewController <UIAlertViewDelegate>

@property (strong, nonatomic) User *user;
@property (nonatomic) NSString *email;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *username;
@property (nonatomic) UIImage *profileImage;


@end
