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

@interface SignInViewController()
@property (weak, nonatomic) IBOutlet UIImageView *icon_mym;
@property (weak, nonatomic) IBOutlet UITextField *txtUsername;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UITextField *txtVerificationCode;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UIButton *verifyButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@property (strong, nonatomic) NSArray *usersQueryResult;

- (IBAction)signInButton:(id)sender;
- (IBAction)registerButton:(id)sender;
@end

@implementation SignInViewController

- (void)viewDidLoad
{
    [self.navigationController setTitle:@"Log In"];
}

/* >>>>>>>>>>>>>>>>>>>>> verifyButton
 Check for the verification code
 >>>>>>>>>>>>>>>>>>>>>>>> */
- (IBAction)verifyButton:(UIButton *)sender
{
    NSString *statusString = nil;
    NSString *statusTitleString = @"Error";
    
    if ([self.txtVerificationCode.text length] == 0) { //Check if the verification code is empty
        NSLog(@"Verification code is empty");
        statusString = @"Verification Code is empty";
    } else {
        DynamoDBAttributeValue *userVerificationCode = [[self.usersQueryResult lastObject] objectForKey:@"email-confirm"];
        if ([userVerificationCode.n isEqualToString:self.txtVerificationCode.text]) { //Check if the verification code matches
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(queue, ^{
                @try {
                    //Replace the verification code with 1 (verified)
                    DynamoDBAttributeValue *userAttribute = [[DynamoDBAttributeValue alloc] initWithS:self.txtUsername.text];
                    DynamoDBAttributeValue *emailAttribute = [[DynamoDBAttributeValue alloc] initWithS:[[[self.usersQueryResult lastObject] objectForKey:@"email"] s]];
                    DynamoDBAttributeValueUpdate *attrUpdate = [[DynamoDBAttributeValueUpdate alloc] initWithValue:[[DynamoDBAttributeValue alloc] initWithN:@"1"] andAction:@"PUT"];
                    DynamoDBUpdateItemRequest *updateItemRequest = [[DynamoDBUpdateItemRequest alloc] initWithTableName:@"mym-login-database"
                                                                                                                 andKey:[[DynamoDBKey alloc] initWithHashKeyElement:userAttribute
                                                                                                                                                 andRangeKeyElement:emailAttribute]
                                                                                                    andAttributeUpdates:[NSMutableDictionary dictionaryWithObject:attrUpdate
                                                                                                                                                           forKey:@"email-confirm"]];
                    [[AmazonClientManager amazonDynamoDBClient] updateItem:updateItemRequest];
                }
                @catch (AmazonClientException *exception) {
                    NSLog(@"%@", exception.description);
                }
            });

            [self logIn];
            NSLog(@"YOU ARE IN, WELCOME");
        } else { //Verification code is wrong
            NSLog(@"Wrong verification code");
            statusString = @"Vefification Code is wrong";
        }
    }
    if (statusString) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:statusTitleString message:statusString delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
        [alert show];
    }
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
            //Query the database
            DynamoDBQueryRequest *dynamoDBQueryRequest = [[DynamoDBQueryRequest alloc] initWithTableName:@"mym-login-database"
                                                                                         andHashKeyValue:[[DynamoDBAttributeValue alloc] initWithS:self.self.txtUsername.text]];
            @try {
                DynamoDBQueryResponse *dynamoDBQueryResponse = [[AmazonClientManager amazonDynamoDBClient] query:dynamoDBQueryRequest];
                self.usersQueryResult = [dynamoDBQueryResponse.items copy];
            }
            @catch (AmazonClientException *exception) {
                NSLog(@"%@", exception.description);
            }
        if ([self.usersQueryResult count] == 1) { //Check if the query resulted in a match
            DynamoDBAttributeValue *userPassword = [[self.usersQueryResult lastObject] objectForKey:@"password"];
            
            if ([userPassword.s isEqualToString:self.txtPassword.text]) {
                DynamoDBAttributeValue *userEmail = [[self.usersQueryResult lastObject] objectForKey:@"email-confirm"];
                if ([userEmail.n integerValue] == 1) { //Check if the user already validated his email
                    [self logIn];
                    NSLog(@"YOU ARE IN, WELCOME");
                } else { //User still needs to validate his email
                    self.txtVerificationCode.hidden = NO;
                    self.txtUsername.hidden = YES;
                    self.txtPassword.hidden = YES;
                    self.verifyButton.hidden = NO;
                    self.signInButton.hidden = YES;
                    self.backButton.hidden = NO;
                    NSLog(@"You are just missing the security Code");
                }
            } else {
                NSLog(@"username and/or password wrong");
                statusString = @"Username and/or Password is wrong";
            }
        } else {
            NSLog(@"username and/or password wrong");
            statusString = @"Username and/or Password is wrong";
        }
    }
    
    if (statusString) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:statusTitleString message:statusString delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
        [alert show];
    }
}

/* >>>>>>>>>>>>>>>>>>>>> backButtonPressed
 Go back from the verification code to the login
 >>>>>>>>>>>>>>>>>>>>>>>> */
- (IBAction)backButtonPressed:(UIButton *)sender
{
    [self resetInterface];
}

/* >>>>>>>>>>>>>>>>>>>>> registerButton
 Open the New Use modal
 >>>>>>>>>>>>>>>>>>>>>>>> */
- (IBAction)registerButton:(id)sender
{
    NewUserViewController *newUserViewController = [[NewUserViewController alloc] initWithNibName:@"NewUserView" bundle:nil];
    [self.txtUsername resignFirstResponder];
    [self.txtPassword resignFirstResponder];
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
    self.txtUsername.hidden = NO;
    self.txtPassword.hidden = NO;
    self.txtVerificationCode.hidden = YES;
    self.verifyButton.hidden = YES;
    self.signInButton.hidden = NO;
    self.backButton.hidden = YES;
    self.txtPassword.text = @"";
    self.txtUsername.text = @"";
    self.txtVerificationCode.text = @"";
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
