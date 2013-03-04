//
//  SignInViewController.h
//  MyM
//
//  Created by Steven Zilberberg on 3/4/13.
//  Copyright (c) 2013 MyM Co. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignInViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIImageView *icon_mym;
@property (strong, nonatomic) IBOutlet UITextField *txtUsername;
@property (strong, nonatomic) IBOutlet UITextField *txtPassword;

- (IBAction)signInButton:(id)sender;
- (IBAction)registerButton:(id)sender;
@end
