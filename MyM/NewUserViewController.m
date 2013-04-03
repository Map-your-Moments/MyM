//
//  NewUserViewController.m
//  MyM
//
//  Created by Marcelo Mazzotti on 25/3/13.
//  Copyright (c) 2013 MyM Co. All rights reserved.
//

#import "NewUserViewController.h"

@interface NewUserViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *fullNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmEmailTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *userSubTypeSegmentedControl;
@property (strong, nonatomic) NSString *statusString;
@property (strong, nonatomic) NSString *statusTitleString;

- (IBAction)createNewUserButtonPress;
@end

@implementation NewUserViewController

- (IBAction)createNewUserButtonPress
{
    self.statusString = nil;
    self.statusTitleString = @"Error";
    
    if ([self.usernameTextField.text length] == 0)   {
        NSLog(@"Username is empty");
        self.statusString = @"Username field is empty";
    } else if ([self.passwordTextField.text length] < 8) {
        NSLog(@"Password is too short - 8");
        self.statusString = @"Password is too short, at least 8 characters";
    } else if (![self.passwordTextField.text isEqualToString:self.confirmPasswordTextField.text]) {
        NSLog(@"Password and ConfirmPassword are not equal");
        self.statusString = @"Passwords are not equal";
    } else if ([self.fullNameTextField.text length] == 0) {
        NSLog(@"FullName is empty");
        self.statusString = @"Name field is empty";
    } else if ([self.emailTextField.text rangeOfString:@"@"].location == NSNotFound) {
        NSLog(@"Please enter a valid email");
        self.statusString = @"Email is not valid";
    } else if (![self.emailTextField.text isEqualToString:self.confirmEmailTextField.text]) {
        NSLog(@"Email and ConfirmEmail are not equal");
        self.statusString = @"Emails are not equal";
    } else {
        NSArray *usersQueryResult = nil;
        DynamoDBQueryRequest *dynamoDBQueryRequest = [[DynamoDBQueryRequest alloc] initWithTableName:@"mym-login-database"
                                                                                     andHashKeyValue:[[DynamoDBAttributeValue alloc] initWithS:self.usernameTextField.text]];
        @try {
            DynamoDBQueryResponse *dynamoDBQueryResponse = [[AmazonClientManager amazonDynamoDBClient] query:dynamoDBQueryRequest];
            usersQueryResult = [dynamoDBQueryResponse.items copy];
        }
        @catch (AmazonClientException *exception) {
            NSLog(@"%@", exception.description);
        }
        
        if ([usersQueryResult count]) {
            NSLog(@"Username already exists");
            self.statusString = @"Username already exists";
        } else {  //Add the information to the database and send an email to the user
            @try {
                int verificationCode = (arc4random() % 99999999) + 10000000;
                NSMutableDictionary *items = [[NSMutableDictionary alloc] initWithCapacity:1];
                [items setValue:[[DynamoDBAttributeValue alloc] initWithS:self.usernameTextField.text] forKey:@"username"];
                [items setValue:[[DynamoDBAttributeValue alloc] initWithS:self.emailTextField.text] forKey:@"email"];
                [items setValue:[[DynamoDBAttributeValue alloc] initWithS:self.passwordTextField.text] forKey:@"password"];
                [items setValue:[[DynamoDBAttributeValue alloc] initWithS:self.fullNameTextField.text] forKey:@"name"];
                [items setValue:[[DynamoDBAttributeValue alloc] initWithN:[NSString stringWithFormat:@"%i", verificationCode]] forKey:@"email-confirm"];
                [items setValue:[[DynamoDBAttributeValue alloc] initWithN:[NSString stringWithFormat:@"%i", [self.userSubTypeSegmentedControl selectedSegmentIndex]]] forKey:@"sub-user"];
            
                DynamoDBPutItemRequest *dynamoDBPutItemRequest = [[DynamoDBPutItemRequest alloc] initWithTableName:@"mym-login-database" andItem:items];
                [[AmazonClientManager amazonDynamoDBClient] putItem:dynamoDBPutItemRequest];
                
                SESSendEmailRequest *sendEmailRequest = [[SESSendEmailRequest alloc] init];
                SESDestination *destination = [[SESDestination alloc] init];
                SESMessage *message = [[SESMessage alloc] init];
                SESBody *body = [[SESBody alloc] init];
                SESContent *contentBody = [[SESContent alloc] init];
                SESContent *contentSubject = [[SESContent alloc] init];
                
                sendEmailRequest.source = @"mapyourmoments.corp@gmail.com";
                destination.toAddresses = [NSMutableArray arrayWithObject:self.emailTextField.text];
                
                contentSubject.data = @"MyM - Email Confirm";
                contentBody.data = [NSString stringWithFormat: @"Welcome to MyM young traveler! Your verification code is: %i", verificationCode];
                
                sendEmailRequest.destination = destination;
                body.text = contentBody;
                message.body = body;
                message.subject = contentSubject;
                sendEmailRequest.message = message;
                
                [[AmazonClientManager amazonSESClient] sendEmail:sendEmailRequest];
            }
            @catch (AmazonServiceException *exception) {
                NSLog(@"%@", exception.message);
            }
            
            self.statusString = @"Your account was created successfully";
            self.statusTitleString = @"Success";
        }
        
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:self.statusTitleString message:self.statusString delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
    [alert show];
}

@end
