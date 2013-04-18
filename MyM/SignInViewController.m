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

@interface SignInViewController() <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *icon_mym;
@property (weak, nonatomic) IBOutlet UITextField *txtUsername;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;

- (IBAction)signInButton:(id)sender;
- (IBAction)registerButton:(id)sender;
@end

@implementation SignInViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
}

/* >>>>>>>>>>>>>>>>>>>>> signInButton
 Sign in logic
 >>>>>>>>>>>>>>>>>>>>>>>> */
- (IBAction)signInButton:(id)sender
{
    NSString *statusString = nil;
    NSString *statusTitleString = @"Error";
    
    if ([self.txtUsername.text length] == 0) { //Check if txtUsername is empty
        NSLog(@"Username is empty");
        statusString = @"Username is empty";
    } else if ([self.txtPassword.text length] == 0) { //Check if txtPassword is empty
        NSLog(@"Password is empty");
        statusString = @"Password is empty";
    } else {
        NSDictionary *jsonLogin = [UtilityClass SendJSON:[NSString stringWithFormat:@"username=%@&password=%@", self.txtUsername.text, self.txtPassword.text]];
        if (jsonLogin) { //Check if the query resulted in a match
            if ([jsonLogin[@"logged_in"] boolValue]) {
                if (jsonLogin[@"valid_email"]) { //Check if the user already validated his email
                    [self logIn];
                    NSLog(@"YOU ARE IN, WELCOME");
                } else { //User still needs to validate his email
                    [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeOrange
                                                   title:@"Please verify your email address"
                                         linedBackground:AJLinedBackgroundTypeDisabled
                                               hideAfter:4];
                    NSLog(@"You are just missing the security Code");
                }
            } else {
                NSLog(@"username and/or password wrong");
                [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeRed
                                               title:@"Username and/or Password is wrong"
                                     linedBackground:AJLinedBackgroundTypeDisabled
                                           hideAfter:4];
//                statusString = @"Username and/or Password is wrong";
            }
        } else {
            NSLog(@"Error");
            statusString = @"Could not connect to the server";
        }
    }
    
    if (statusString) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:statusTitleString message:statusString delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
        [alert show];
    }
}

/* >>>>>>>>>>>>>>>>>>>>> registerButton
 Open the New Use modal
 >>>>>>>>>>>>>>>>>>>>>>>> */
- (IBAction)registerButton:(id)sender
{
    [self.view endEditing:YES];
    NewUserViewController *newUserViewController = [[NewUserViewController alloc] initWithNibName:@"NewUserView" bundle:nil];
    [self presentViewController:newUserViewController animated:YES completion:nil];
}

/* >>>>>>>>>>>>>>>>>>>>> textFieldDidBeginEditing
 Move the view when the keyboard is on
 >>>>>>>>>>>>>>>>>>>>>>>> */
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField.superview.frame.origin.y == 20) {
        [UIView animateWithDuration:0.5 animations:^{
            textField.superview.frame = CGRectMake(textField.superview.frame.origin.x, textField.superview.frame.origin.y - 40, textField.superview.frame.size.width, textField.superview.frame.size.height);
        }];
    }
}

/* >>>>>>>>>>>>>>>>>>>>> resetInterface
 Clear the interface
 >>>>>>>>>>>>>>>>>>>>>>>> */
- (void)resetInterface
{
    self.txtPassword.text = @"";
    self.txtUsername.text = @"";
    [self.txtUsername becomeFirstResponder];
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
    
    [self resetInterface];
    
    MapViewController *mapViewController = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil];
    [mapViewController setUser:user];
    [self.navigationController pushViewController:mapViewController animated:YES];
}


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

- (IBAction)backgroundTap:(UITapGestureRecognizer *)sender
{
    [self.view endEditing:YES];
}

@end
