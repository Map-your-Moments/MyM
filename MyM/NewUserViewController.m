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
- (IBAction)createNewUserButtonPress;
@end

@implementation NewUserViewController

- (IBAction)createNewUserButtonPress
{
    if ([self.usernameTextField.text length] == 0)   {
        NSLog(@"Username is empty");
    } else if ([self.passwordTextField.text length] < 8) {
        NSLog(@"Password is too short - 8");
    } else if (![self.passwordTextField.text isEqualToString:self.confirmPasswordTextField.text]) {
        NSLog(@"Password and ConfirmPassword are not equal");
    } else if ([self.fullNameTextField.text length] == 0) {
        NSLog(@"FullName is empty");
    } else if ([self.emailTextField.text rangeOfString:@"@"].location == NSNotFound) {
        NSLog(@"Please enter a valid email");
    } else if (![self.emailTextField.text isEqualToString:self.confirmEmailTextField.text]) {
        NSLog(@"Email and ConfirmEmail are not equal");
    } else {
        NSArray *usersQueryResult = nil;
        DynamoDBQueryRequest *dynamoDBQueryRequest = [[DynamoDBQueryRequest alloc] initWithTableName:@"mym-login-database"
                                                                                     andHashKeyValue:[[DynamoDBAttributeValue alloc] initWithS:self.usernameTextField.text]];
        @try {
            DynamoDBQueryResponse *dynamoDBQueryResponse = [[AmazonClientManager amazonDynamoDBClient] query:dynamoDBQueryRequest];
            usersQueryResult = [dynamoDBQueryResponse.items copy];
            
            NSLog(@"%@", dynamoDBQueryResponse.description);
        }
        @catch (AmazonClientException *exception) {
            NSLog(@"%@", exception.description);
        }
        
        if ([usersQueryResult count]) {
            NSLog(@"Username already exists");
        } else {
            NSLog(@"ALL GOOD");
        }
    }
}
@end
