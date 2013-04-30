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
#define SCREEN_HEIGHT [[UIScreen mainScreen] applicationFrame].size.height

@interface SignInViewController() <NewUserDelegate>
@property (weak, nonatomic) IBOutlet UITextField *txtUsername;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *signInActivityIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *aboutImageView;
@property (weak, nonatomic) IBOutlet UIImageView *aboutIcon;
@property (weak, nonatomic) IBOutlet UIView *aboutView;

@property (nonatomic) NSDictionary *jsonLogin;
@property (nonatomic) NSData *userPicture;

- (IBAction)signInButton:(id)sender;
- (IBAction)registerButton:(id)sender;
@end

@implementation SignInViewController

float initialTouchPoint;
bool startInsideAboutImageView;
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint contentTouchPoint = [[touches anyObject] locationInView:self.aboutImageView];
    if (CGRectContainsPoint(self.aboutImageView.bounds, contentTouchPoint)) {
        initialTouchPoint = contentTouchPoint.y;
        startInsideAboutImageView = YES;
    } else {
        startInsideAboutImageView = NO;
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (startInsideAboutImageView) {
        CGPoint pointInView = [[touches anyObject] locationInView:self.view];
        float yTarget = pointInView.y - initialTouchPoint;
        if(yTarget < SCREEN_HEIGHT - self.aboutView.frame.size.height)
            yTarget = SCREEN_HEIGHT - self.aboutView.frame.size.height;
        else if( yTarget > SCREEN_HEIGHT - self.aboutImageView.frame.size.height)
            yTarget = SCREEN_HEIGHT - self.aboutImageView.frame.size.height;
        
        [UIView animateWithDuration:.1
                         animations:^{
                             [self.aboutView setFrame:CGRectMake(self.aboutView.frame.origin.x, yTarget, self.aboutView.frame.size.width, self.aboutView.frame.size.height)];
                         }];
    }
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self aboutViewFinalPosition:touches];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self aboutViewFinalPosition:touches];
}

- (void)aboutViewFinalPosition:(NSSet *)touches
{
    NSString *iconImage = nil;
    if (startInsideAboutImageView) {
        CGPoint endTouchPoint = [[touches anyObject] locationInView:self.view];
        float yTarget = endTouchPoint.y - initialTouchPoint;
        if(yTarget < SCREEN_HEIGHT - self.aboutView.frame.size.height / 2) {
            yTarget = SCREEN_HEIGHT - self.aboutView.frame.size.height;
            iconImage = @"glyphicons_195_circle_info";
        }
        else {
            yTarget = SCREEN_HEIGHT - self.aboutImageView.frame.size.height;
            iconImage = @"glyphicons_213_up_arrow.png";
        }
        
        [UIView animateWithDuration:.5
                         animations:^{
                             [self.aboutView setFrame:CGRectMake(self.aboutView.frame.origin.x, yTarget, self.aboutView.frame.size.width, self.aboutView.frame.size.height)];
                             self.aboutIcon.image = [UIImage imageNamed:iconImage];
                         }];
    }
}

- (void)newUserCreated
{
    [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeGreen
                                   title:@"Your account was created successfully"
                         linedBackground:AJLinedBackgroundTypeDisabled
                               hideAfter:BANNER_DEFAULT_TIME];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.view endEditing:YES];
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
        NSDictionary *jsonDictionary = @{ @"username" : self.txtUsername.text, @"password" : self.txtPassword.text};
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            dispatch_async(dispatch_get_main_queue(), ^ {
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            });
            self.jsonLogin = [UtilityClass SendJSON:jsonDictionary toAddress:@"http://54.225.76.23:3000/login/"];
            self.userPicture = self.jsonLogin ? [UtilityClass requestGravatar:[UtilityClass getGravatarURL:self.jsonLogin[@"email"]]] : nil;
            dispatch_async(dispatch_get_main_queue(), ^ {
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                if (self.jsonLogin) { //Check if the query resulted in a match
                    if ([self.jsonLogin[@"logged_in"] boolValue]) {
                        if (!self.jsonLogin[@"valid_email"]) { //Check if the user already validated his email
                            [self logIn];
                            NSLog(@"You are in");
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
                        self.txtPassword.text = @"";
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
            });
        });
    }
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [AJNotificationView hideCurrentNotificationViewAndClearQueue];
}

/* >>>>>>>>>>>>>>>>>>>>> registerButton:
 Push the New Use View
 >>>>>>>>>>>>>>>>>>>>>>>> */
- (IBAction)registerButton:(id)sender
{
    self.txtPassword.text = @"";
    self.txtUsername.text = @"";
    [self.view endEditing:YES];
    NewUserViewController *newUserViewController = [[NewUserViewController alloc] initWithNibName:@"NewUserView" bundle:nil];
    newUserViewController.delegate = self;
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
                                     andFriends:nil
                               andProfileImage:self.userPicture
                                       andToken:self.jsonLogin[@"access_token"]];
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
