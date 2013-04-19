//
//  SignInViewController.m
//  MyM
//
//  Created by Steven Zilberberg on 3/4/13.
//  Copyright (c) 2013 MyM Co. All rights reserved.
//

#import "SignInViewController.h"
#import "NewUserViewController.h"
#import "AmazonClientManager.h"
#import "MapViewController.h"
#import "UtilityClass.h"

#import "AJNotificationView.h"

#define BANNER_DEFAULT_TIME 3

@interface SignInViewController()
@property (weak, nonatomic) IBOutlet UIImageView *icon_mym;
@property (weak, nonatomic) IBOutlet UITextField *txtUsername;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *signInActivityIndicator;

@property (nonatomic) NSDictionary *jsonLogin;

- (IBAction)signInButton:(id)sender;
- (IBAction)registerButton:(id)sender;
@end

@implementation SignInViewController

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
}

/* >>>>>>>>>>>>>>>>>>>>> signInButton:
 Log In logic
 >>>>>>>>>>>>>>>>>>>>>>>> */
- (IBAction)signInButton:(id)sender
{    
    if ([self.txtUsername.text length] == 0) { //Check if txtUsername is empty
        [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeRed
                                       title:@"Username is empty"
                             linedBackground:AJLinedBackgroundTypeDisabled
                                   hideAfter:BANNER_DEFAULT_TIME];
        NSLog(@"Username is empty");
    } else if ([self.txtPassword.text length] == 0) { //Check if txtPassword is empty
        [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeRed
                                       title:@"Password is empty"
                             linedBackground:AJLinedBackgroundTypeDisabled
                                   hideAfter:BANNER_DEFAULT_TIME];
        NSLog(@"Password is empty");
    } else {
        [self.signInButton setTitle:@"" forState:UIControlStateDisabled];
        self.view.userInteractionEnabled = NO;
        self.signInButton.enabled = NO;
        [self.signInActivityIndicator startAnimating];
        NSString *jsonString = [NSString stringWithFormat:@"username=%@&password=%@", self.txtUsername.text, self.txtPassword.text];
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            self.jsonLogin = [UtilityClass SendJSON:jsonString];
            dispatch_async(dispatch_get_main_queue(), ^ {
                [self finishLogIn];
            });
        });
    }

}

/* >>>>>>>>>>>>>>>>>>>>> finishLogIn
 Once the asyng JSON request is done, finish the Log In
 >>>>>>>>>>>>>>>>>>>>>>>> */
- (void)finishLogIn
{
    if (self.jsonLogin) { //Check if the query resulted in a match
        if ([self.jsonLogin[@"logged_in"] boolValue]) {
            if (self.jsonLogin[@"valid_email"]) { //Check if the user already validated his email
                [self logIn];
                NSLog(@"YOU ARE IN, WELCOME");
            } else { //User still needs to validate his email
                self.txtPassword.text = @"";
                [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeOrange
                                               title:@"Please verify your email address"
                                     linedBackground:AJLinedBackgroundTypeDisabled
                                           hideAfter:BANNER_DEFAULT_TIME];
                NSLog(@"You are just missing the security Code");
            }
        } else {
            [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeRed
                                           title:@"Username and/or Password is wrong"
                                 linedBackground:AJLinedBackgroundTypeDisabled
                                       hideAfter:BANNER_DEFAULT_TIME];
            NSLog(@"username and/or password wrong");
        }
    } else {
        [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeRed
                                       title:@"Could not connect to the server"
                             linedBackground:AJLinedBackgroundTypeDisabled
                                   hideAfter:BANNER_DEFAULT_TIME];
        NSLog(@"Could not connect to the server");
    }
    self.view.userInteractionEnabled = YES;
    [self.view endEditing:YES];

    self.signInButton.enabled = YES;
    [self.signInActivityIndicator stopAnimating];
}

/* >>>>>>>>>>>>>>>>>>>>> registerButton:
 Push the New Use View
 >>>>>>>>>>>>>>>>>>>>>>>> */
- (IBAction)registerButton:(id)sender
{
    [self.view endEditing:YES];
    NewUserViewController *newUserViewController = [[NewUserViewController alloc] initWithNibName:@"NewUserView" bundle:nil];
    [self.navigationController pushViewController:newUserViewController animated:YES];
}

/* >>>>>>>>>>>>>>>>>>>>> logIn
 Generate the User object and clear the interface
 >>>>>>>>>>>>>>>>>>>>>>>> */
- (void)logIn
{
    User *user = [[User alloc] initWithUserName:self.txtUsername.text
                                    andPassword:nil
                                  andDateJoined:nil
                                       andEmail:nil
                                    andSettings:nil
                                     andMoments:nil
                                     andFriends:nil];
    
    self.txtPassword.text = @"";
    self.txtUsername.text = @"";
    [self.view endEditing:YES];
    
    MapViewController *mapViewController = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil];
    [mapViewController setUser:user];
    [self.navigationController pushViewController:mapViewController animated:YES];
}

/* >>>>>>>>>>>>>>>>>>>>> textFieldShouldReturn:
 Logic for NEXT and DONE keys
 >>>>>>>>>>>>>>>>>>>>>>>> */
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSInteger nextTag = textField.tag + 1;
    
    UIResponder *nextResponder = [textField.superview viewWithTag:nextTag];
    
    if (nextResponder) {
        [nextResponder becomeFirstResponder];
    } else if (nextTag == 3) {//Last tag in the UI
        [self.signInButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    } else {
        [textField resignFirstResponder];
    }
    
    return NO;
}

/* >>>>>>>>>>>>>>>>>>>>> backgroundTap:
 Backgroun Tap to close the keyboard
 >>>>>>>>>>>>>>>>>>>>>>>> */
- (IBAction)backgroundTap:(UITapGestureRecognizer *)sender
{
    [self.view endEditing:YES];
}

@end
