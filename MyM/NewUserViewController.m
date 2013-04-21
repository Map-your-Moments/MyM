//
//  NewUserViewController.m
//  MyM
//
//  Created by Marcelo Mazzotti on 25/3/13.
//  Copyright (c) 2013 MyM Co. All rights reserved.
//

#import "NewUserViewController.h"
#import "UtilityClass.h"

#import "AJNotificationView.h"

#define BANNER_DEFAULT_TIME 3

@interface NewUserViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *fullNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmEmailTextField;

@property (nonatomic) UIBarButtonItem *createNewUserButton;
@property (nonatomic) NSDictionary *jsonNewUser;
@end

@implementation NewUserViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.usernameTextField becomeFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.createNewUserButton = [[UIBarButtonItem alloc] initWithTitle:@"Create" style:UIBarButtonItemStyleDone target:self action:@selector(createNewUserButtonPress)];
    self.navigationItem.rightBarButtonItem = self.createNewUserButton;
}

/* >>>>>>>>>>>>>>>>>>>>> createNewUserButtonPress
 Cretes a New User
 >>>>>>>>>>>>>>>>>>>>>>>> */
- (void)createNewUserButtonPress
{
    if ([self.usernameTextField.text length] == 0) { //Check if userTextField is empty
        [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeRed
                                       title:@"Username is empty"
                             linedBackground:AJLinedBackgroundTypeDisabled
                                   hideAfter:BANNER_DEFAULT_TIME];
        NSLog(@"Username is empty");
    } else if ([self.passwordTextField.text length] < 8) { //Check if passwordTextField is too short
        [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeRed
                                       title:@"Password is too short, at least 8 characters"
                             linedBackground:AJLinedBackgroundTypeDisabled
                                   hideAfter:BANNER_DEFAULT_TIME];
        NSLog(@"Password is too short - 8");
    } else if (![self.passwordTextField.text isEqualToString:self.confirmPasswordTextField.text]) { //Check if passwordTextField and confirmPasswordTextField are equal
        [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeRed
                                       title:@"Passwords are not equal"
                             linedBackground:AJLinedBackgroundTypeDisabled
                                   hideAfter:BANNER_DEFAULT_TIME];
        NSLog(@"Password and ConfirmPassword are not equal");
    } else if ([self.fullNameTextField.text length] == 0) { //Check if fullNameTextField is empty
        [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeRed
                                       title:@"Name field is empty"
                             linedBackground:AJLinedBackgroundTypeDisabled
                                   hideAfter:BANNER_DEFAULT_TIME];
        NSLog(@"FullName is empty");
    } else if ([self.emailTextField.text rangeOfString:@"@"].location == NSNotFound) { //Check if emailTextField has an @
        [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeRed
                                       title:@"Email is not valid"
                             linedBackground:AJLinedBackgroundTypeDisabled
                                   hideAfter:BANNER_DEFAULT_TIME];
        NSLog(@"Please enter a valid email");
    } else if (![self.emailTextField.text isEqualToString:self.confirmEmailTextField.text]) { //Check if emailTextField and confirmEmailTextField are equal
        [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeRed
                                       title:@"Emails are not equal"
                             linedBackground:AJLinedBackgroundTypeDisabled
                                   hideAfter:BANNER_DEFAULT_TIME];
        NSLog(@"Email and ConfirmEmail are not equal");
    } else {
        NSDictionary *jsonDictionary = @{ @"user": @{ @"username" : self.usernameTextField.text, @"password" : self.passwordTextField.text, @"email" : self.emailTextField.text, @"name" : self.fullNameTextField.text} };
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            self.jsonNewUser = [UtilityClass SendJSON:jsonDictionary toAddress:@"http://54.225.76.23:3000/users"];
            dispatch_async(dispatch_get_main_queue(), ^ {
                if (self.jsonNewUser) {
                    if ([self.jsonNewUser[@"created"] boolValue]) {
                        [self.delegate newUserCreated];
                        [self.navigationController popToRootViewControllerAnimated:YES];
                        NSLog(@"Your account was created successfully");
                    } else {
                        [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeRed
                                                       title:@"Username already exists"
                                             linedBackground:AJLinedBackgroundTypeDisabled
                                                   hideAfter:BANNER_DEFAULT_TIME];
                        NSLog(@"Username already exists");
                    }
                } else {
                    [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeRed
                                                   title:@"Could not connect to the server"
                                         linedBackground:AJLinedBackgroundTypeDisabled
                                               hideAfter:BANNER_DEFAULT_TIME];
                    NSLog(@"Could not connect to the server");
                }
            });

        });        
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSInteger nextTag = textField.tag + 1;
    
    UIResponder *nextResponder = [textField.superview viewWithTag:nextTag];
    
    if (nextResponder) {
        [nextResponder becomeFirstResponder];
    } else if (nextTag == 7) {
        [[textField.superview viewWithTag:1] becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    
    return NO;
}
@end
