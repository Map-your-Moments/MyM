//
//  UserAccountViewController.m
//  MyM
//
//  Created by Steven Zilberberg on 4/21/13.
//  Copyright (c) 2013 MyM Co. All rights reserved.
//

#import "FriendAccountViewController.h"
#import "Constants.h"
#import "UtilityClass.h"
#import "AJNotificationView.h"
#import "FriendUtilityClass.h"

#define BANNER_DEFAULT_TIME 2

@interface FriendAccountViewController ()
{
}

@property (strong, nonatomic) NSArray *sectionHeaders;
@property (nonatomic) NSDictionary *jsonDeleteFriend;

- (IBAction)deleteFriendAlert:(id)sender;

@end

@implementation FriendAccountViewController

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
    
    self.title = _name;
    
    [self createDeleteFriendButton];
    
    self.sectionHeaders = [[NSArray alloc] initWithObjects:@"Username", @"Name", @"Email", nil];
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
            cell.textLabel.text = _username;
            
            if(_profileImage)
            {
                UIImage *cellImg = _profileImage;
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
            NSString *name = _name;
            cell.textLabel.text = name;
            break;
        }
        case 2:
        {
            cell.textLabel.text = _email;
            
            break;
        }
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark UIAlertView Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([alertView tag] == kUIAlertDeleteAccount)
    {
        if(buttonIndex != [alertView cancelButtonIndex])
        {
            [self deleteFriend];
        }
    }
}

- (void)createDeleteFriendButton
{
    // create a UIButton (Delete Account button)
    UIImage *deleteImage = [UIImage imageNamed:@"delete~iphone.png"];
    UIButton *btnDelete = [UIButton buttonWithType:UIButtonTypeCustom];
    btnDelete.frame = CGRectMake(-10, 25, self.view.bounds.size.width - 20, 40);
    btnDelete.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    btnDelete.titleLabel.shadowColor = [UIColor lightGrayColor];
    btnDelete.titleLabel.shadowOffset = CGSizeMake(0, -1);
    [btnDelete setTitle:@"Delete Friend" forState:UIControlStateNormal];
    [btnDelete setBackgroundImage:[deleteImage resizableImageWithCapInsets:UIEdgeInsetsMake(20, 5, 5 ,5)] forState:UIControlStateNormal];
    [btnDelete setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnDelete addTarget:self action:@selector(deleteFriendButton) forControlEvents:UIControlEventTouchUpInside];
    
    //create a footer view on the bottom of the tabeview
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(20, 0, 280, 100)];
    [footerView addSubview:btnDelete];
    
    self.tableView.tableFooterView = footerView;
}

- (void)deleteFriendButton
{
    NSLog(@"Delete Account");
    [self deleteFriendAlert:self];
}

- (IBAction)deleteFriendAlert:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Deleting Friend"
                          message:@"Are you sure you want to unfriend this person?"
                          delegate:self
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@"Confirm", nil];
    alert.tag = kUIAlertDeleteAccount;
    [alert show];
}

- (void)deleteFriend
{
    NSString *user = [_user token];
    NSDictionary *jsonDictionary = @{ @"access_token" : user, @"email": _email };
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^ {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        });
        self.jsonDeleteFriend = [UtilityClass SendJSON:jsonDictionary toAddress:@"http://54.225.76.23:3000/deletefriend"];
        dispatch_async(dispatch_get_main_queue(), ^ {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            if(self.jsonDeleteFriend)
            {
                if([self.jsonDeleteFriend[@"deleted"] boolValue])
                {
                    NSLog(@"%@ successfully removed from friends list.", _email);
                    [self.navigationController popViewControllerAnimated:YES];
                }
                else
                {
                    NSLog(@"%@ could not be removed from your friends list. Try again.", _email);
                    NSString *title = _email;
                    title = [title stringByAppendingString:@" could not be removed from your friends list"];
                    [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeRed
                                                   title:title
                                         linedBackground:AJLinedBackgroundTypeDisabled
                                               hideAfter:BANNER_DEFAULT_TIME];
                }
            }
            else
            {
                NSLog(@"Http request failed.");
                [AJNotificationView showNoticeInView:self.view type:AJNotificationTypeRed
                                               title:@"Server request failed"
                                     linedBackground:AJLinedBackgroundTypeDisabled
                                           hideAfter:BANNER_DEFAULT_TIME];
            }
        });
    });
}

@end
