//
//  UserAccountViewController.m
//  MyM
//
//  Created by Steven Zilberberg on 4/21/13.
//  Copyright (c) 2013 MyM Co. All rights reserved.
//

#import "UserAccountViewController.h"
#import "SearchBarTableViewController.h"
#import "User.h"
#import "Constants.h"
#import "UtilityClass.h"
#import "AJNotificationView.h"
#import "FriendUtilityClass.h"

#define BANNER_DEFAULT_TIME 2

@interface UserAccountViewController ()
{
//    NSString *kStillImages;
//    NSString *kVideoCamera;
//    NSString *kMomemtAudio_temp;
}

@property (strong, nonatomic) NSArray *sectionHeaders;
@property (strong, nonatomic) NSMutableDictionary *userInformation;
@property (nonatomic) NSDictionary *jsonDeleteAccount;
@property (nonatomic) NSDictionary *jsonEditPassword;

- (IBAction)deleteUserAlert:(id)sender;

@end

@implementation UserAccountViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self createDeleteUserButton];
    
//    kStillImages = @"public.image";
//    kVideoCamera = @"public.movie";
//    kMomemtAudio_temp = @"MomemtAudio_temp";
    
    self.sectionHeaders = [[NSArray alloc] initWithObjects:@"Username", @"Password", @"Email", @"Friends", nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [AJNotificationView hideCurrentNotificationViewAndClearQueue];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.sectionHeaders count];
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.sectionHeaders objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

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
            FriendUtilityClass *fUtility = [[FriendUtilityClass alloc] init];
            
            NSArray *friendList = [fUtility getFriends:[_user token]];
            
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch([indexPath section])
    {
        case 0:
        {
            NSLog(@"Touched Username");
            //[self.navigationController popViewControllerAnimated:YES];
            break;
        }
        case 1:
        {
            NSLog(@"Touched Password");
            [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeOrange
                                           title:@"Editing password is not implemented yet"
                                 linedBackground:AJLinedBackgroundTypeDisabled
                                       hideAfter:BANNER_DEFAULT_TIME];
            
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Change Password" message:@"Confirm Current Password" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
//            [alert setAlertViewStyle:UIAlertViewStyleSecureTextInput];
//            [alert setTag:kUIAlertSettingsConfirmChange];
//            [alert show];
            break;
        }
        case 2:
        {
            NSLog(@"Touched Email");

            [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeOrange
                                           title:@"Editing email is not implemented yet"
                                 linedBackground:AJLinedBackgroundTypeDisabled
                                       hideAfter:BANNER_DEFAULT_TIME];
            break;
        }
        case 3:
        {
            NSLog(@"Touched Friends");
            SearchBarTableViewController *vc = [[SearchBarTableViewController alloc] initWithSectionIndexes:YES];
            [vc setUser:_user];
            [self.navigationController pushViewController:vc animated:YES];
            break;
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
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([alertView tag] == kUIAlertSettingsConfirmChange)
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
                return;
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Change Password" message:@"Enter a new password" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
                [alert setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
                [[alert textFieldAtIndex:0] setSecureTextEntry:YES];
                [[alert textFieldAtIndex:0]setPlaceholder:@"New Password"];
                [[alert textFieldAtIndex:1]setPlaceholder:@"Confirm Password"];
                [alert setTag:kUIAlertSettingsVerifyChange];
                [alert show];
            }
        }
    }
    else if([alertView tag] == kUIAlertSettingsVerifyChange)
    {
        if(buttonIndex != [alertView cancelButtonIndex])
        {
            NSString *newPassword = [[alertView textFieldAtIndex:0] text];
            NSString *confirmedPwd = [[alertView textFieldAtIndex:1] text];
            
            if(![newPassword isEqualToString:confirmedPwd])
            {
                [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeRed
                                               title:@"Passwords do not match"
                                     linedBackground:AJLinedBackgroundTypeDisabled
                                           hideAfter:BANNER_DEFAULT_TIME];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Change Password" message:@"Enter a new password" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
                [alert setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
                [[alert textFieldAtIndex:0] setSecureTextEntry:YES];
                [[alert textFieldAtIndex:0]setPlaceholder:@"New Password"];
                [[alert textFieldAtIndex:1]setPlaceholder:@"Confirm Password"];
                [alert setTag:kUIAlertSettingsVerifyChange];
                [alert show];
            }
            else
            {
                [_user setPassword:newPassword];
                
                NSDictionary *jsonDictionary = @{ @"user": @{ @"username" : [_user username], @"password" : newPassword, @"email" : [_user email], @"name" : [_user name]} };
                
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
    else if([alertView tag] == kUIAlertDeleteAccount)
    {
        if(buttonIndex != [alertView cancelButtonIndex])
        {
            [self deleteUserAccount];
        }
    }
}

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

- (void)deleteUserButton
{
    NSLog(@"Delete Account");
    [self deleteUserAlert:self];
}

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
