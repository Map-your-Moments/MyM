//
//  UserAccountViewController.m
//  MyM
//
//  Created by Steven Zilberberg on 4/21/13.
//  Copyright (c) 2013 MyM Co. All rights reserved.
//

#import "UserAccountViewController.h"
#import "FriendsListViewController.h"
#import "User.h"
#import "Constants.h"

@interface UserAccountViewController ()
{
    NSString *kTAGUSERINFORMATION_USERNAME;
    NSString *kTAGUSERINFORMATION_PASSWORD;
    NSString *kTAGUSERINFORMATION_EMAIL;
    NSString *kTAGUSERINFORMATION_DATEJOINED;
    NSString *kTAGUSERINFORMATION_FRIENDS;
    NSString *kTAGUSERINFORMATION_MOMENTS;
    NSString *kTAGUSERINFORMATION_OTHER;
    NSString *kTAGUSERINFORMATION_PROFILEURL;
}

@property (strong, nonatomic) NSArray *sectionHeaders;
@property (strong, nonatomic) NSMutableDictionary *userInformation;

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
    kTAGUSERINFORMATION_USERNAME = @"USERNAME";
    kTAGUSERINFORMATION_PASSWORD = @"PASSWORD";
    kTAGUSERINFORMATION_OTHER = @"OTHER";
    kTAGUSERINFORMATION_MOMENTS = @"MOMENTS";
    kTAGUSERINFORMATION_FRIENDS = @"FRIENDS";
    kTAGUSERINFORMATION_EMAIL = @"EMAIL";
    kTAGUSERINFORMATION_DATEJOINED = @"DATEJOINED";
    kTAGUSERINFORMATION_PROFILEURL = @"PROFILEURL";
    
    self.sectionHeaders = [[NSArray alloc] initWithObjects:@"Username", @"Password", @"Email", @"Date Joined", @"Friends", @"Moments", @"Other Settings", nil];
    
    self.userInformation = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[self.targetuser username], kTAGUSERINFORMATION_USERNAME, [self.targetuser profileImageURL], kTAGUSERINFORMATION_PROFILEURL , [self.targetuser password], kTAGUSERINFORMATION_PASSWORD, [self.targetuser email], kTAGUSERINFORMATION_EMAIL, [self.targetuser dateJoined], kTAGUSERINFORMATION_DATEJOINED, [self.targetuser friends], kTAGUSERINFORMATION_FRIENDS, [self.targetuser moments], [self.targetuser settings], kTAGUSERINFORMATION_OTHER, nil];
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
            cell.textLabel.text = [self.userInformation valueForKey:kTAGUSERINFORMATION_USERNAME];
            
            if([self.targetuser profileImage] == nil)
            {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    cell.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[self.userInformation valueForKey:kTAGUSERINFORMATION_PROFILEURL]]];
                    [self.targetuser setProfileImage:cell.imageView.image];
                    [self.view setNeedsDisplay];
                    self.view.contentMode = UIViewContentModeRedraw;
                    [self.tableView reloadData];
                });
            }
            else
            {
                cell.imageView.image = [self.targetuser profileImage];
            }
            break;
        }
        case 1:
        {
            NSString *password = [self.userInformation valueForKey:kTAGUSERINFORMATION_PASSWORD];
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
            cell.textLabel.text = [self.userInformation valueForKey:kTAGUSERINFORMATION_EMAIL];
            break;
        }
        case 3:
        {
            cell.textLabel.text = [self.userInformation valueForKey:kTAGUSERINFORMATION_DATEJOINED];
            break;
        }
        case 4:
        {
            NSMutableArray *friendList = [self.userInformation valueForKey:kTAGUSERINFORMATION_FRIENDS];
            cell.textLabel.text = [NSString stringWithFormat:@"%d Friends", [friendList count]];
            cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
            break;
        }
        case 5:
        {
            NSMutableArray *momentList = [self.userInformation valueForKey:kTAGUSERINFORMATION_MOMENTS];
            cell.textLabel.text = [NSString stringWithFormat:@"%d Moments", [momentList count]];
            cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
            break;
        }
        case 6:
        {
            cell.textLabel.text = [NSString stringWithFormat:@"View Other Settings"];
            cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
            break;
        }
    }
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

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
            [alert setTag:1];
            [alert show];
            break;
        }
        case 2:
        {
            NSLog(@"Touched Email");
            break;
        }
        case 3:
        {
            NSLog(@"Touched Date");
            break;
        }
        case 4:
        {
            NSLog(@"Touched Friends");
            FriendsListViewController *vc = [[FriendsListViewController alloc] initWithNibName:@"FriendsListViewController" bundle:nil];
            //[mapView removeAnnotations:mapView.annotations]; //!
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 5:
        {
#warning NEED TO IMPLEMENT
            NSLog(@"Touched Moments");
            break;
        }
        case 6:
        {
#warning NEED TO IMPLEMENT
            NSLog(@"Touched Other");
            break;
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark UIAlertView Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([alertView tag] == 1)        //Confirm password
    {
        NSString *passwordEntered = [[alertView textFieldAtIndex:0] text];
        if(passwordEntered == nil)
            return;
        if(![passwordEntered isEqualToString:[self.userInformation valueForKey:kTAGUSERINFORMATION_PASSWORD]])
            return;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Change Password" message:@"Enter a new password" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Change", nil];
        [alert setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
        [[alert textFieldAtIndex:0] setSecureTextEntry:YES];
        [[alert textFieldAtIndex:0]setPlaceholder:@"New Password"];
        [[alert textFieldAtIndex:1]setPlaceholder:@"Confirm Password"];
        [alert setTag:2];
        [alert show];
    }
    else if([alertView tag] == 2)
    {
        NSString *newPassword = [[alertView textFieldAtIndex:0] text];
        NSString *confirmedPwd = [[alertView textFieldAtIndex:1] text];
        if(![newPassword isEqualToString:confirmedPwd])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid" message:@"Passwords do not match" delegate:self cancelButtonTitle:@"Damn..." otherButtonTitles: nil];
            [alert show];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"Password successfully changed" delegate:self cancelButtonTitle:@"Cool" otherButtonTitles:nil];
            [alert show];
            [self.userInformation setValue:newPassword forKey:kTAGUSERINFORMATION_PASSWORD];
            [self.targetuser setPassword:newPassword];
            #warning UPDATE THE SERVER WITH NEW PASSWORD AS WELL AS USER INFORMATION
        }
    }
}

@end
