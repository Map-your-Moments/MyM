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

@property (strong, nonatomic) NSArray *usersQueryResult;
@property (weak, nonatomic) IBOutlet UIButton *createButton;


- (IBAction)createNewUserButtonPress;
@end

@implementation NewUserViewController

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Create" style:UIBarButtonItemStyleDone target:self action:@selector(createNewUserButtonPress)];
}

/* >>>>>>>>>>>>>>>>>>>>> createNewUserButtonPress
 Cretes a New User
 >>>>>>>>>>>>>>>>>>>>>>>> */
- (IBAction)createNewUserButtonPress
{
    NSString *statusString = nil;
    NSString *statusTitleString = @"Error";
    
    if ([self.usernameTextField.text length] == 0) { //Check if userTextField is empty
        NSLog(@"Username is empty");
        statusString = @"Username field is empty";
    } else if ([self.passwordTextField.text length] < 8) { //Check if passwordTextField is too short
        NSLog(@"Password is too short - 8");
        statusString = @"Password is too short, at least 8 characters";
    } else if (![self.passwordTextField.text isEqualToString:self.confirmPasswordTextField.text]) { //Check if passwordTextField and confirmPasswordTextField are equal
        NSLog(@"Password and ConfirmPassword are not equal");
        statusString = @"Passwords are not equal";
    } else if ([self.fullNameTextField.text length] == 0) { //Check if fullNameTextField is empty
        NSLog(@"FullName is empty");
        statusString = @"Name field is empty";
    } else if ([self.emailTextField.text rangeOfString:@"@"].location == NSNotFound) { //Check if emailTextField has an @
        NSLog(@"Please enter a valid email");
        statusString = @"Email is not valid";
    } else if (![self.emailTextField.text isEqualToString:self.confirmEmailTextField.text]) { //Check if emailTextField and confirmEmailTextField are equal
        NSLog(@"Email and ConfirmEmail are not equal");
        statusString = @"Emails are not equal";
    } else {
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            //Query the server for the usernameTextField
            DynamoDBQueryRequest *dynamoDBQueryRequest = [[DynamoDBQueryRequest alloc] initWithTableName:@"mym-login-database"
                                                                                         andHashKeyValue:[[DynamoDBAttributeValue alloc] initWithS:self.usernameTextField.text]];
            @try {
                DynamoDBQueryResponse *dynamoDBQueryResponse = [[AmazonClientManager amazonDynamoDBClient] query:dynamoDBQueryRequest];
                self.usersQueryResult = [dynamoDBQueryResponse.items copy];
            }
            @catch (AmazonClientException *exception) {
                NSLog(@"%@", exception.description);
            }
        });
        
        if ([self.usersQueryResult count]) { //Check if the query result is empty or not
            NSLog(@"Username already exists");
            statusString = @"Username already exists";
        } else {  //Add the information to the database and send an email to the user
            @try {
                int verificationCode = (arc4random() % 99999999) + 10000000; //Generate a random verification code with 8 digits
                NSMutableDictionary *items = [[NSMutableDictionary alloc] initWithCapacity:1];
                [items setValue:[[DynamoDBAttributeValue alloc] initWithS:self.usernameTextField.text] forKey:@"username"];
                [items setValue:[[DynamoDBAttributeValue alloc] initWithS:self.emailTextField.text] forKey:@"email"];
                [items setValue:[[DynamoDBAttributeValue alloc] initWithS:self.passwordTextField.text] forKey:@"password"];
                [items setValue:[[DynamoDBAttributeValue alloc] initWithS:self.fullNameTextField.text] forKey:@"name"];
                [items setValue:[[DynamoDBAttributeValue alloc] initWithN:[NSString stringWithFormat:@"%i", verificationCode]] forKey:@"email-confirm"];
                [items setValue:[[DynamoDBAttributeValue alloc] initWithN:[NSString stringWithFormat:@"%i", [self.userSubTypeSegmentedControl selectedSegmentIndex]]] forKey:@"sub-user"];
                
                //Add the user to de database
                DynamoDBPutItemRequest *dynamoDBPutItemRequest = [[DynamoDBPutItemRequest alloc] initWithTableName:@"mym-login-database" andItem:items];
                [[AmazonClientManager amazonDynamoDBClient] putItem:dynamoDBPutItemRequest];
                
                //Send the email to the user
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
            
            //Acount was created successfully
            statusString = @"Your account was created successfully";
            statusTitleString = @"Success";
        }
        
    }
    
    //Show UIAlertView with result
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:statusTitleString message:statusString delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
    [alert show];
    
    if (![statusTitleString isEqualToString:@"Error"]) { //Check if the account was created successfully and close modal
        [self dismissViewControllerAnimated:YES completion:nil];
    }

}

/* >>>>>>>>>>>>>>>>>>>>> cancelButtonPress
 Close New User modal
 >>>>>>>>>>>>>>>>>>>>>>>> */
- (IBAction)cancelButtonPress:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

/* >>>>>>>>>>>>>>>>>>>>> textFieldDidBeginEditing
 Move the view when the keyboard is on
 >>>>>>>>>>>>>>>>>>>>>>>> */
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField.superview.frame.size.height > 400) { //Resize the view when the keyboard shows up
        [UIView animateWithDuration:1 animations:^{
            textField.superview.frame = CGRectMake(textField.superview.frame.origin.x, textField.superview.frame.origin.y, textField.superview.frame.size.width, textField.superview.frame.size.height - 216);
        }];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSInteger nextTag = textField.tag + 1;
    
    UIResponder *nextResponder = [textField.superview viewWithTag:nextTag];
    
    if (nextResponder) {
        [nextResponder becomeFirstResponder];
    } else if (nextTag == 7) {//Last tag in the UI
        [self.createButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    } else {
        [textField resignFirstResponder];
    }
    
    return NO;
}
@end
