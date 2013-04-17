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
@property (strong, nonatomic) NSArray *usersQueryResult;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UIButton *verifyButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@property (strong, nonatomic) NSString *statusString;
@property (strong, nonatomic) NSString *statusTitleString;

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
    self.statusString = nil;
    self.statusTitleString = @"Error";
    
    if ([self.txtVerificationCode.text length] == 0) { //Check if the verification code is empty
        NSLog(@"Verification code is empty");
        self.statusString = @"Verification Code is empty";
    } else {
        DynamoDBAttributeValue *userVerificationCode = [[self.usersQueryResult lastObject] objectForKey:@"email-confirm"];
        if ([userVerificationCode.n isEqualToString:self.txtVerificationCode.text]) { //Check if the verification code matches
            @try {
                
                //Replace the verification code with 1 (verified)
                DynamoDBAttributeValue *userAttribute = [[DynamoDBAttributeValue alloc] initWithS:self.txtUsername.text];
                DynamoDBAttributeValue *emailAttribute = [[DynamoDBAttributeValue alloc] initWithS:[[[self.usersQueryResult lastObject] objectForKey:@"email"] s]];
                DynamoDBAttributeValue       *attr       = [[DynamoDBAttributeValue alloc] initWithN:@"1"];
                DynamoDBAttributeValueUpdate *attrUpdate = [[DynamoDBAttributeValueUpdate alloc] initWithValue:attr andAction:@"PUT"];
                
                DynamoDBUpdateItemRequest    *request = [[DynamoDBUpdateItemRequest alloc] initWithTableName:@"mym-login-database"
                                                                                                      andKey:[[DynamoDBKey alloc] initWithHashKeyElement:userAttribute andRangeKeyElement:emailAttribute]
                                                                                         andAttributeUpdates:[NSMutableDictionary dictionaryWithObject:attrUpdate forKey:@"email-confirm"]];
                [[AmazonClientManager amazonDynamoDBClient] updateItem:request];
            }
            @catch (AmazonClientException *exception) {
                NSLog(@"%@", exception.description);
            }
            MapViewController *mapViewController = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil];
            [self.navigationController pushViewController:mapViewController animated:YES];
            NSLog(@"YOU ARE IN, WELCOME");
            self.txtPassword.text = @"";
        } else { //Verification code is wrong
            NSLog(@"Wrong verification code");
            self.statusString = @"Vefification Code is wrong";
        }
    }
    if (self.statusString) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:self.statusTitleString message:self.statusString delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
        [alert show];
    }
}

/* >>>>>>>>>>>>>>>>>>>>> signInButton
 Sign in logic
 >>>>>>>>>>>>>>>>>>>>>>>> */
- (IBAction)signInButton:(id)sender
{
    self.statusString = nil;
    self.statusTitleString = @"Error";
    
    if ([self.txtUsername.text length] == 0) { //Check if txtUsername is empty
        NSLog(@"Username is empty");
        self.statusString = @"Username is empty";
    } else if ([self.txtPassword.text length] == 0) { //Check if txtPassword is empty
        NSLog(@"Password is empty");
        self.statusString = @"Password is empty";
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
                    self.txtUsername.hidden = NO;
                    self.txtPassword.hidden = NO;
                    self.txtVerificationCode.hidden = YES;
                    self.verifyButton.hidden = YES;
                    self.signInButton.hidden = NO;
                    self.backButton.hidden = YES;
                    self.txtPassword.text = @"";
                    
                    User *user = [[User alloc] initWithUserName:self.txtUsername.text
                                                    andPassword:nil
                                                  andDateJoined:nil
                                                       andEmail:nil
                                                    andSettings:nil
                                                     andMoments:nil
                                                     andFriends:nil];
                    
                    MapViewController *mapViewController = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil];
                    [mapViewController setUser:user];
                    [self.navigationController pushViewController:mapViewController animated:YES];
                    
                    
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
                NSLog(@"username or password wrong");
                self.statusString = @"Username or Password is wrong";
            }
        }
    }
    if (self.statusString) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:self.statusTitleString message:self.statusString delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
        [alert show];
    }
}

/* >>>>>>>>>>>>>>>>>>>>> backButtonPressed
 Go back from the verification code
 >>>>>>>>>>>>>>>>>>>>>>>> */
- (IBAction)backButtonPressed:(UIButton *)sender
{
    self.txtUsername.hidden = NO;
    self.txtPassword.hidden = NO;
    self.txtVerificationCode.hidden = YES;
    self.verifyButton.hidden = YES;
    self.signInButton.hidden = NO;
    self.backButton.hidden = YES;
    self.txtPassword.text = @"";
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

@end
