/*
 * MyM: Map Your Moments "A Digital Travelogue"
 *
 * Developed using iOS and AWS for CSC Special Topics: Cloud Computing, Spring 2013 by
 * Adam Cumiskey, Dave Hand, Tim Honeywell, Marcelo Mazzotti, Justin Wagner, and Steven Zilberberg
 *
 * NewUserViewController.m
 * View to create a new account
 *
 */

#import "NewUserViewController.h"
#import "UtilityClass.h"

#import "AJNotificationView.h"

#define BANNER_DEFAULT_TIME 2

@interface NewUserViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *fullNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmEmailTextField;

@property (nonatomic) UIBarButtonItem *createNewUserButton;
@property (nonatomic) UIBarButtonItem *activityIndicatorButton;
@property (nonatomic) UIActivityIndicatorView *activityIndicator;
@property (nonatomic) NSDictionary *jsonNewUser;
@end

@implementation NewUserViewController

-(UIActivityIndicatorView *)activityIndicator
{
    if (!_activityIndicator) _activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 310, 20)];
    return _activityIndicator;
}

- (UIBarButtonItem *)activityIndicatorButton
{
    if (!_activityIndicatorButton) _activityIndicatorButton = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
    return _activityIndicatorButton;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.usernameTextField becomeFirstResponder];
}

/* >>>>>>>>>>>>>>>>>>>>> viewWillDisappear:
 Clear all the AJNotifications
 >>>>>>>>>>>>>>>>>>>>>>>> */
-(void)viewWillDisappear:(BOOL)animated
{
    [AJNotificationView hideCurrentNotificationViewAndClearQueue];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.createNewUserButton = [[UIBarButtonItem alloc] initWithTitle:@"Create" style:UIBarButtonItemStyleDone target:self action:@selector(createNewUserButtonPress)];
    self.navigationItem.title = @"Registering";
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
        [self.usernameTextField becomeFirstResponder];
        NSLog(@"Username is empty");
    } else if ([self.fullNameTextField.text length] == 0) { //Check if fullNameTextField is empty
        [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeRed
                                       title:@"Name field is empty"
                             linedBackground:AJLinedBackgroundTypeDisabled
                                   hideAfter:BANNER_DEFAULT_TIME];
        [self.fullNameTextField becomeFirstResponder];
        NSLog(@"FullName is empty");
    } else if ([self.passwordTextField.text length] < 8) { //Check if passwordTextField is too short
        [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeRed
                                       title:@"Password must be at least 8 characters"
                             linedBackground:AJLinedBackgroundTypeDisabled
                                   hideAfter:BANNER_DEFAULT_TIME];
        [self.passwordTextField becomeFirstResponder];
        NSLog(@"Password is too short - 8");
    } else if (![self.passwordTextField.text isEqualToString:self.confirmPasswordTextField.text]) { //Check if passwordTextField and confirmPasswordTextField are equal
        [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeRed
                                       title:@"Passwords are not equal"
                             linedBackground:AJLinedBackgroundTypeDisabled
                                   hideAfter:BANNER_DEFAULT_TIME];
        [self.confirmPasswordTextField becomeFirstResponder];
        NSLog(@"Password and ConfirmPassword are not equal");
    } else if ([self.emailTextField.text rangeOfString:@"@"].location == NSNotFound) { //Check if emailTextField has an @
        [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeRed
                                       title:@"Email is not valid"
                             linedBackground:AJLinedBackgroundTypeDisabled
                                   hideAfter:BANNER_DEFAULT_TIME];
        [self.emailTextField becomeFirstResponder];
        NSLog(@"Please enter a valid email");
    } else if (![self.emailTextField.text isEqualToString:self.confirmEmailTextField.text]) { //Check if emailTextField and confirmEmailTextField are equal
        [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeRed
                                       title:@"Emails are not equal"
                             linedBackground:AJLinedBackgroundTypeDisabled
                                   hideAfter:BANNER_DEFAULT_TIME];
        [self.confirmEmailTextField becomeFirstResponder];
        NSLog(@"Email and ConfirmEmail are not equal");
    } else { //We still need to check if the username is not under use
        [self navigationItem].rightBarButtonItem = self.activityIndicatorButton;
        [self.activityIndicator startAnimating];
        [self.view endEditing:YES];
        self.navigationItem.hidesBackButton = YES;
        self.view.userInteractionEnabled = NO;
        
        //Prepare JSON Dictionary
        NSDictionary *jsonDictionary = @{ @"user": @{ @"username" : self.usernameTextField.text, @"password" : self.passwordTextField.text, @"email" : self.emailTextField.text, @"name" : self.fullNameTextField.text} };
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            dispatch_async(dispatch_get_main_queue(), ^ {
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            });
            self.jsonNewUser = [UtilityClass SendJSON:jsonDictionary toAddress:@"http://54.225.76.23:3000/users"];
            dispatch_async(dispatch_get_main_queue(), ^ {
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

                if (self.jsonNewUser) { // Account was created
                    if ([self.jsonNewUser[@"created"] boolValue]) {
                        [self.navigationController popToRootViewControllerAnimated:YES];
                        [self.delegate newUserCreated];
                        NSLog(@"Your account was created successfully");
                    } else { // Username already exists
                        [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeRed
                                                       title:@"Username already exists"
                                             linedBackground:AJLinedBackgroundTypeDisabled
                                                   hideAfter:BANNER_DEFAULT_TIME];
                        [self.usernameTextField becomeFirstResponder];
                        NSLog(@"Username already exists");
                    }
                } else { //Could connect to the server
                    [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeRed
                                                   title:@"Could not connect to the server"
                                         linedBackground:AJLinedBackgroundTypeDisabled
                                               hideAfter:BANNER_DEFAULT_TIME];
                    NSLog(@"Could not connect to the server");
                }
                [self navigationItem].rightBarButtonItem = self.createNewUserButton;
                 self.navigationItem.hidesBackButton = NO;
                [self.activityIndicator stopAnimating];
                self.view.userInteractionEnabled = YES;
            });

        });        
    }
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
    } else if (nextTag == 7) {
        [[textField.superview viewWithTag:1] becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    
    return NO;
}

/* >>>>>>>>>>>>>>>>>>>>> createS3FolderForUser:
 Create a New S3 folder the new User
 >>>>>>>>>>>>>>>>>>>>>>>> */
- (void)createS3FolderForUser
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        });
        
        @try{
            S3PutObjectRequest *request = [[S3PutObjectRequest alloc] initWithKey:[NSString stringWithFormat:@"%@/", self.usernameTextField.text] inBucket:@"mym-csc470"];
            S3PutObjectResponse *response = [[AmazonClientManager amazonS3Client] putObject:request];
            if(response.error != nil) NSLog(@"Error: %@", response.error);
        }
        @catch (AmazonClientException *exception) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:exception.message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            NSLog(@"Exception: %@", exception);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
    });
}

@end
