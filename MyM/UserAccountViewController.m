/*
 * MyM: Map Your Moments "A Digital Travelogue"
 *
 * Developed using iOS and AWS for CSC Special Topics: Cloud Computing, Spring 2013 by
 * Adam Cumiskey, Dave Hand, Tim Honeywell, Marcelo Mazzotti, Justin Wagner, and Steven Zilberberg
 *
 * UserAccountViewController.m
 * Display for a user's account information. The table view includes the friend's username and profile pic, password,
 * and email each in their respective cell. At the bottom of the view is a delete account button
 * to permanently delete the current user's account. If a user clicks on the password field an alert displays
 * asking for their current password. If they input their password correctly, then the user is given another
 * alert view to input and confirm their new password, which then updates in the database. This is the same 
 * for clicking on the  email field. If the user wishes to fully delete their account they can press the 
 * delete account button and go through a confirmation alert to delete their account. If the deletion is successful, 
 * they are returned to the sign in view. The number of friends a user has is displayed in the last cell of the table
 * view. If that cell is clicked the view changes to the user's friends list.
 *
 */

#import "UserAccountViewController.h"
#import "SearchBarTableViewController.h"
#import "Constants.h"
#import "UtilityClass.h"
#import "AJNotificationView.h"
#import "FriendUtilityClass.h"

#define BANNER_DEFAULT_TIME 2

@interface UserAccountViewController ()
{
}

@property (strong, nonatomic) NSArray *sectionHeaders;
@property (nonatomic) NSDictionary *jsonDeleteAccount;
@property (nonatomic) NSDictionary *jsonEditPassword;
@property (nonatomic) NSDictionary *jsonEditEmail;

- (IBAction)deleteUserAlert:(id)sender;
@end

@implementation UserAccountViewController

//Sets the navigation bar to be visible, sets the title of the view
//and changes the name of the back button to "Back"
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationItem setTitle:@"Settings"];
}

//Loads the view and initializes the section headers and the DeleteUser button
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self createDeleteUserButton];
    
    self.sectionHeaders = [[NSArray alloc] initWithObjects:@"Username", @"Password", @"Email", @"Friends", nil];
}

//safety measure against bug that is caused by the view changing
//when an AJNotification is being displayed
- (void)viewDidDisappear:(BOOL)animated
{
    [AJNotificationView hideCurrentNotificationViewAndClearQueue];
}

#pragma mark - Table view data source

// Return the number of sections.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sectionHeaders count];
}

//Displays the header title of the sections
-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.sectionHeaders objectAtIndex:section];
}

// Return the number of rows in the section.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

//Sets what to display in each cell of the table view
//The first cell displays the users's username and profile pic
//The second cell displays the user's password in a secured view
//The third cell displays the user's email
//The fourth cell displays the user's friend count
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    switch([indexPath section])
    {
        case 0:
        {
            cell.textLabel.text = [_user username];
            [cell setUserInteractionEnabled:NO];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            
            if([_user profileImage])
            {

                UIImage *cellImg = [UIImage imageWithData:[_user profileImage]];
                cellImg = [UtilityClass imageWithImage:cellImg scaledToSize:CGSizeMake(35,35)];
                
                cell.imageView.image = cellImg;
            }
            else
            {
                UIImage *cellImg = [UIImage imageNamed:@"DefaultProfilePic.png"];
                cellImg = [UtilityClass imageWithImage:cellImg scaledToSize:CGSizeMake(35,35)];
                
                cell.imageView.image = cellImg;
            }
            break;
        }
        case 1:
        {
            NSString *password = [_user password];
            if(password == nil)
                password = @"Testing";
            NSString *securedView = @"";
            for(int c = 0; c < [password length]; c++)
                securedView = [securedView stringByAppendingString:@"\u25cf"]; //U+25CF: Puts a block dot
            cell.textLabel.text = securedView;
            break;
        }
        case 2:
        {
            cell.textLabel.text = [_user email];
            
            break;
        }
        case 3:
        {            
            NSArray *friendList = [FriendUtilityClass getFriends:[_user token]];
            
            if([friendList count] == 1)
            {
                cell.textLabel.text = [NSString stringWithFormat:@"%d Friend", [friendList count]];
            }
            else
            {
                cell.textLabel.text = [NSString stringWithFormat:@"%d Friends", [friendList count]];
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
//        case 4:
//        {
//            cell.textLabel.text = [NSString stringWithFormat:@"Other Settings"];
//            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//            break;
//        }
    }
    return cell;
}

#pragma mark - Table view delegate

//Determines what action to take when a cell of the table is selected.
//The first cell of the table cannot be selected.
//If the second cell is selected the user is prompted for a password change
//If the third cell is selected the user is prompted for an email change
//If the fourth cell is selected the friends list viewcontroller appears
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch([indexPath section])
    {
        case 0:
        {
            NSLog(@"Touched Username");
            break;
        }
        case 1:
        {
            NSLog(@"Touched Password");
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Change Password" message:@"Confirm Current Password" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
            [alert setAlertViewStyle:UIAlertViewStyleSecureTextInput];
            [alert setTag:kUIAlertSettingsConfirmChangePassword];
            [alert show];
            
            break;
        }
        case 2:
        {
            NSLog(@"Touched Email");
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Change Email" message:@"Confirm Current Password" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
            [alert setAlertViewStyle:UIAlertViewStyleSecureTextInput];
            [alert setTag:kUIAlertSettingsConfirmChangeEmail];
            [alert show];
            
            break;
        }
        case 3:
        {
            NSLog(@"Touched Friends");
            
            SearchBarTableViewController *vc = [[SearchBarTableViewController alloc] initWithSectionIndexes:YES];
            [vc setUser:_user];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
//        case 4:
//        {
//            NSLog(@"Touched Other");
//            [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeOrange
//                                           title:@"Not implemented in this build."
//                                 linedBackground:AJLinedBackgroundTypeDisabled
//                                       hideAfter:BANNER_DEFAULT_TIME];
//            break;
//        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark UIAlertView Delegate

//Determines what action to take for each button index of an alert
//depending on the alert tag
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([alertView tag] == kUIAlertSettingsConfirmChangePassword)
    {
        if(buttonIndex != [alertView cancelButtonIndex])
        {
            NSString *passwordEntered = [[alertView textFieldAtIndex:0] text];
            if(passwordEntered == nil)
                return;
            if(![passwordEntered isEqualToString:[_user password]])
            {
                [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeRed
                                               title:@"Incorrect password"
                                     linedBackground:AJLinedBackgroundTypeDisabled
                                           hideAfter:BANNER_DEFAULT_TIME];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Change Password" message:@"Password entered was incorrect" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
                [alert setAlertViewStyle:UIAlertViewStyleSecureTextInput];
                [[alert textFieldAtIndex:0] setSecureTextEntry:YES];
                [alert setTag:kUIAlertSettingsConfirmChangePassword];
                [alert show];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Change Password" message:@"Enter a new password" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
                [alert setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
                [[alert textFieldAtIndex:0] setSecureTextEntry:YES];
                [[alert textFieldAtIndex:0]setPlaceholder:@"New Password"];
                [[alert textFieldAtIndex:1]setPlaceholder:@"Confirm Password"];
                [alert setTag:kUIAlertSettingsVerifyPassword];
                [alert show];
            }
        }
    }
    else if([alertView tag] == kUIAlertSettingsVerifyPassword)
    {
        if(buttonIndex != [alertView cancelButtonIndex])
        {
            NSString *newPassword = [[alertView textFieldAtIndex:0] text];
            NSString *confirmedPwd = [[alertView textFieldAtIndex:1] text];
            
            if(![newPassword isEqualToString:confirmedPwd])
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Change Password" message:@"Passwords did not match" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
                [alert setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
                [[alert textFieldAtIndex:0] setSecureTextEntry:YES];
                [[alert textFieldAtIndex:0]setPlaceholder:@"New Password"];
                [[alert textFieldAtIndex:1]setPlaceholder:@"Confirm Password"];
                [alert setTag:kUIAlertSettingsVerifyPassword];
                [alert show];
            }
            else if([newPassword length] < 8)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Change Password" message:@"Password too short (8 character minimum)" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
                [alert setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
                [[alert textFieldAtIndex:0] setSecureTextEntry:YES];
                [[alert textFieldAtIndex:0]setPlaceholder:@"New Password"];
                [[alert textFieldAtIndex:1]setPlaceholder:@"Confirm Password"];
                [alert setTag:kUIAlertSettingsVerifyPassword];
                [alert show];
            }
            else
            {
                [_user setPassword:newPassword];
                
                NSDictionary *jsonDictionary = @{ @"user": @{ @"username" : [_user username], @"password" : newPassword, @"email" : [_user email], @"name" : [_user name]}, @"access_token": [_user token] };
                
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                dispatch_async(queue, ^{
                    dispatch_async(dispatch_get_main_queue(), ^ {
                        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
                    });
                    self.jsonEditPassword = [UtilityClass SendJSON:jsonDictionary toAddress:@"http://54.225.76.23:3000/edit_user"];
                    dispatch_async(dispatch_get_main_queue(), ^ {
                        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                        if(self.jsonEditPassword)
                        {
                            if([self.jsonEditPassword[@"updated"] boolValue])
                            {
                                [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeGreen
                                                               title:@"Password successfully changed"
                                                     linedBackground:AJLinedBackgroundTypeDisabled
                                                           hideAfter:BANNER_DEFAULT_TIME];
                                [self.tableView reloadData];
                            }
                            else
                            {
                                [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeRed
                                                               title:@"Failed to change password"
                                                     linedBackground:AJLinedBackgroundTypeDisabled
                                                           hideAfter:BANNER_DEFAULT_TIME];
                            }
                            
                        }
                        else
                        {
                            [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeRed
                                                           title:@"Server request failed"
                                                 linedBackground:AJLinedBackgroundTypeDisabled
                                                       hideAfter:BANNER_DEFAULT_TIME];
                        }
                    });
                });
            }
        }
    }
    else if([alertView tag] == kUIAlertSettingsConfirmChangeEmail)
    {
        if(buttonIndex != [alertView cancelButtonIndex])
        {
            NSString *passwordEntered = [[alertView textFieldAtIndex:0] text];
            if(passwordEntered == nil)
                return;
            if(![passwordEntered isEqualToString:[_user password]])
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Change Email" message:@"Password entered was incorrect" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
                [alert setAlertViewStyle:UIAlertViewStyleSecureTextInput];
                [[alert textFieldAtIndex:0] setSecureTextEntry:YES];
                [alert setTag:kUIAlertSettingsConfirmChangeEmail];
                [alert show];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Change Email" message:@"Enter a new email" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
                [alert setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
                [[alert textFieldAtIndex:0] setSecureTextEntry:NO];
                [[alert textFieldAtIndex:1] setSecureTextEntry:NO];
                [[alert textFieldAtIndex:0]setPlaceholder:@"new@example.com"];
                [[alert textFieldAtIndex:1]setPlaceholder:@"confirm@example.com"];
                [alert setTag:kUIAlertSettingsVerifyEmail];
                [alert show];
            }
        }
    }
    else if([alertView tag] == kUIAlertSettingsVerifyEmail)
    {
        if(buttonIndex != [alertView cancelButtonIndex])
        {
            NSString *newEmail = [[alertView textFieldAtIndex:0] text];
            NSString *confirmedEmail = [[alertView textFieldAtIndex:1] text];
            
            if(![newEmail isEqualToString:confirmedEmail])
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Change Email" message:@"Emails did not match" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
                [alert setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
                [[alert textFieldAtIndex:0] setSecureTextEntry:NO];
                [[alert textFieldAtIndex:1] setSecureTextEntry:NO];
                [[alert textFieldAtIndex:0]setPlaceholder:@"new@example.com"];
                [[alert textFieldAtIndex:1]setPlaceholder:@"confirm@example.com"];
                [alert setTag:kUIAlertSettingsVerifyEmail];
                [alert show];
            }
            else if ([newEmail rangeOfString:@"@"].location == NSNotFound) //Check if emailTextField has an @
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Change Email" message:@"Invalid email entered" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
                [alert setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
                [[alert textFieldAtIndex:0] setSecureTextEntry:NO];
                [[alert textFieldAtIndex:1] setSecureTextEntry:NO];
                [[alert textFieldAtIndex:0]setPlaceholder:@"new@example.com"];
                [[alert textFieldAtIndex:1]setPlaceholder:@"confirm@example.com"];
                [alert setTag:kUIAlertSettingsVerifyEmail];
                [alert show];
            }
            else
            {
                [_user setEmail:newEmail];
                
                NSDictionary *jsonDictionary = @{ @"user": @{ @"username" : [_user username], @"password" : [_user password], @"email" : newEmail, @"name" : [_user name]}, @"access_token": [_user token] };
                
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                dispatch_async(queue, ^{
                    dispatch_async(dispatch_get_main_queue(), ^ {
                        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
                    });
                    self.jsonEditEmail = [UtilityClass SendJSON:jsonDictionary toAddress:@"http://54.225.76.23:3000/edit_user"];
                    dispatch_async(dispatch_get_main_queue(), ^ {
                        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                        if(self.jsonEditEmail)
                        {
                            if([self.jsonEditEmail[@"updated"] boolValue])
                            {
                                [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeGreen
                                                               title:@"Email successfully changed"
                                                     linedBackground:AJLinedBackgroundTypeDisabled
                                                           hideAfter:BANNER_DEFAULT_TIME];
                                [self.tableView reloadData];
                            }
                            else
                            {
                                [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeRed
                                                               title:@"Failed to change email"
                                                     linedBackground:AJLinedBackgroundTypeDisabled
                                                           hideAfter:BANNER_DEFAULT_TIME];
                            }
                            
                        }
                        else
                        {
                            [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeRed
                                                           title:@"Server request failed"
                                                 linedBackground:AJLinedBackgroundTypeDisabled
                                                       hideAfter:BANNER_DEFAULT_TIME];
                        }
                    });
                });
            }
        }
    }
}

#pragma mark UIActionSheet
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == kSAVEDBUTTONINDEX)
    {
        UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
        //There is a warning here. I am not sure why but disregard
        [pickerController setDelegate:self];
        [pickerController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        [self presentViewController:pickerController animated:YES completion:NULL];
    }
    else if(buttonIndex == kTAKEMEDIA)
    {
        UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
        //There is a warning here. I am not sure why but disregard
        [pickerController setDelegate:self];
        [pickerController setSourceType:UIImagePickerControllerSourceTypeCamera];
        [self presentViewController:pickerController animated:YES completion:NULL];

    }
}

//Creates the display button for deleting the user account and sets
//it as a footer for the tableView
- (void)createDeleteUserButton
{
    // create a UIButton (Delete Account button)
    UIImage *deleteImage = [UIImage imageNamed:@"delete~iphone.png"];
    UIButton *btnDelete = [UIButton buttonWithType:UIButtonTypeCustom];
    btnDelete.frame = CGRectMake(-10, 25, self.view.bounds.size.width - 20, 40);
    btnDelete.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    btnDelete.titleLabel.shadowColor = [UIColor lightGrayColor];
    btnDelete.titleLabel.shadowOffset = CGSizeMake(0, -1);
    [btnDelete setTitle:@"Delete Account" forState:UIControlStateNormal];
    [btnDelete setBackgroundImage:[deleteImage resizableImageWithCapInsets:UIEdgeInsetsMake(20, 5, 5 ,5)] forState:UIControlStateNormal];
    [btnDelete setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnDelete addTarget:self action:@selector(deleteUserButton) forControlEvents:UIControlEventTouchUpInside];
    
    //create a footer view on the bottom of the tabeview
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(20, 0, 280, 100)];
    [footerView addSubview:btnDelete];
    
    self.tableView.tableFooterView = footerView;
}

//when the delete user button is pressed, a delete user alert is called
- (void)deleteUserButton
{
    NSLog(@"Delete Account");
    [self deleteUserAlert:self];
}

//displays a delete user alert for confirming the account deletion
- (IBAction)deleteUserAlert:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Deleting Account"
                          message:@"Are you sure you want to permanently delete your account?"
                          delegate:self
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@"Confirm", nil];
    alert.tag = kUIAlertDeleteAccount;
    [alert show];
}

//Sends a JSON request to delete the user on the server
//If the user is successfully deleted then we return
//to the sign in view controller
- (void)deleteUserAccount
{
    NSString *user = [_user token];
    NSDictionary *jsonDictionary = @{ @"access_token" : user};
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^ {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        });
        self.jsonDeleteAccount = [UtilityClass SendJSON:jsonDictionary toAddress:@"http://54.225.76.23:3000/delete_user"];
        dispatch_async(dispatch_get_main_queue(), ^ {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            if(self.jsonDeleteAccount)
            {
                if([self.jsonDeleteAccount[@"deleted"] boolValue])
                {
                    NSLog(@"Account deleted.");
                    [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeGreen
                                                   title:@"Account successfully deleted"
                                         linedBackground:AJLinedBackgroundTypeDisabled
                                               hideAfter:BANNER_DEFAULT_TIME];
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
                else
                {
                    NSLog(@"Failed to delete account.");
                    [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeRed
                                                   title:@"Failed to delete account"
                                         linedBackground:AJLinedBackgroundTypeDisabled
                                               hideAfter:BANNER_DEFAULT_TIME];
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
                
            }
            else
            {
                NSLog(@"Server request failed.");
                [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeRed
                                               title:@"Server request failed"
                                     linedBackground:AJLinedBackgroundTypeDisabled
                                           hideAfter:BANNER_DEFAULT_TIME];
            }
        });
    });
}

@end
