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

@interface SignInViewController()
@property (weak, nonatomic) IBOutlet UIImageView *icon_mym;
@property (weak, nonatomic) IBOutlet UITextField *txtUsername;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UITextField *txtVerificationCode;
@property (strong, nonatomic) NSArray *usersQueryResult;
@end

@implementation SignInViewController
- (IBAction)verifyButton:(UIButton *)sender
{
    if ([self.txtVerificationCode.text length] == 0) {
        NSLog(@"Verification code is empty");
    } else {
        DynamoDBAttributeValue *userVerificationCode = [[self.usersQueryResult lastObject] objectForKey:@"email-confirm"];
        if ([userVerificationCode.n isEqualToString:self.txtVerificationCode.text]) {
            @try {
                DynamoDBAttributeValue *userUsernameD = [[self.usersQueryResult lastObject] objectForKey:@"username"];
                DynamoDBAttributeValue *userEmail = [[self.usersQueryResult lastObject] objectForKey:@"email"];
                NSString *userUsername = userUsernameD.s;
                DynamoDBAttributeValue *n = [[DynamoDBAttributeValue alloc] initWithS:userUsername];
                DynamoDBAttributeValue *z = [[DynamoDBAttributeValue alloc] initWithS:userEmail.s];
                DynamoDBAttributeValue       *attr       = [[DynamoDBAttributeValue alloc] initWithN:@"1"];
                DynamoDBAttributeValueUpdate *attrUpdate = [[DynamoDBAttributeValueUpdate alloc] initWithValue:attr andAction:@"PUT"];
                
                DynamoDBUpdateItemRequest    *request = [[DynamoDBUpdateItemRequest alloc] initWithTableName:@"mym-login-database"
                                                                                                      andKey:[[DynamoDBKey alloc] initWithHashKeyElement:n andRangeKeyElement:z]
                                                                                         andAttributeUpdates:[NSMutableDictionary dictionaryWithObject:attrUpdate forKey:@"email-confirm"]];
                [[AmazonClientManager amazonDynamoDBClient] updateItem:request];
            }
            @catch (AmazonClientException *exception) {
                NSLog(@"%@", exception.description);
            }
            
            NSLog(@"YOU ARE IN, WELCOME");
        } else {
            NSLog(@"Wrong verification code");
        }
    }
}

- (IBAction)signInButton:(id)sender
{
    if ([self.txtUsername.text length] == 0) {
        NSLog(@"Username is empty");
    } else if ([self.txtPassword.text length] == 0) {
        NSLog(@"Password is empty");
    } else {
        
        DynamoDBQueryRequest *dynamoDBQueryRequest = [[DynamoDBQueryRequest alloc] initWithTableName:@"mym-login-database"
                                                                                     andHashKeyValue:[[DynamoDBAttributeValue alloc] initWithS:self.self.txtUsername.text]];
        @try {
            DynamoDBQueryResponse *dynamoDBQueryResponse = [[AmazonClientManager amazonDynamoDBClient] query:dynamoDBQueryRequest];
            self.usersQueryResult = [dynamoDBQueryResponse.items copy];
        }
        @catch (AmazonClientException *exception) {
            NSLog(@"%@", exception.description);
        }
        
        if ([self.usersQueryResult count] == 1) {
            DynamoDBAttributeValue *userPassword = [[self.usersQueryResult lastObject] objectForKey:@"password"];
            
            if ([userPassword.s isEqualToString:self.txtPassword.text]) {
                DynamoDBAttributeValue *userEmail = [[self.usersQueryResult lastObject] objectForKey:@"email-confirm"];
                if ([userEmail.n integerValue] == 1) {
                    self.txtUsername.hidden = NO;
                    self.txtPassword.hidden = NO;
                    self.txtVerificationCode.hidden = YES;
                    NSLog(@"YOU ARE IN, WELCOME");
                } else {
                    self.txtVerificationCode.hidden = NO;
                    self.txtUsername.hidden = YES;
                    self.txtPassword.hidden = YES;
                }
            } else {
                NSLog(@"username or password wrong");
            }
        }
    }
}

- (IBAction)registerButton:(id)sender
{
    NewUserViewController *newUserViewController = [[NewUserViewController alloc] initWithNibName:@"NewUserView" bundle:nil];
    [self presentViewController:newUserViewController animated:YES completion:nil];
}

@end
