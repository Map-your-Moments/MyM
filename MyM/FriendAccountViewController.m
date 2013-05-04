/*
 * MyM: Map Your Moments "A Digital Travelogue"
 *
 * Developed using iOS and AWS for CSC Special Topics: Cloud Computing, Spring 2013 by
 * Adam Cumiskey, Dave Hand, Tim Honeywell, Marcelo Mazzotti, Justin Wagner, and Steven Zilberberg
 *
 * FriendAccountViewController.m
 * Display for a friend's account information. The view shows the friend's username
 * as the title. The table view includes the friend's username and profile pic, full name,
 * and email each in their respective cell. At the bottom of a view is a delete friend button
 * to remove the friend from your friends list
 *
 */

#import "FriendAccountViewController.h"
#import "Constants.h"
#import "UtilityClass.h"
#import "AJNotificationView.h"
#import "FriendUtilityClass.h"
#import "GravitarUtilityClass.h"

#define BANNER_DEFAULT_TIME 2

@interface FriendAccountViewController ()
{
}

@property (strong, nonatomic) NSArray *sectionHeaders;
@property (nonatomic) NSDictionary *jsonDeleteFriend;

- (IBAction)deleteFriendAlert:(id)sender;

@end

@implementation FriendAccountViewController

//initialization of tableview which is set to Grouped style
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    
    return self;
}

//Loads the view, sets the title to the friend's name, creates te delete friend button
//and initializes each of the section headers for each cell of the grouped tableview
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = _name;
    
    [self createDeleteFriendButton];
    
    self.sectionHeaders = [[NSArray alloc] initWithObjects:@"Username", @"Name", @"Email", nil];
}

//safety measure for AJNotification bug that occurs when a notification
//is being displayed when the view changes
- (void)viewDidDisappear:(BOOL)animated
{
    [AJNotificationView hideCurrentNotificationViewAndClearQueue];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
//The first cell displays the friend's username and profile pic
//The second cell displays the friend's name
//The third cell displays the friend's email
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    switch([indexPath section])
    {
        case 0:
        {
            cell.textLabel.text = _username;
            
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(queue, ^{
                dispatch_async(dispatch_get_main_queue(), ^ {
                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
                });
                
                NSData *gravPic = [GravitarUtilityClass requestGravatar:[GravitarUtilityClass getGravatarURL:_email]];
                dispatch_async(dispatch_get_main_queue(), ^ {
                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                    
                    if(gravPic)
                    {
                        UIImage *cellImg = [UIImage imageWithData:gravPic];
                        cellImg = [UtilityClass imageWithImage:cellImg scaledToSize:CGSizeMake(35,35)];
                        
                        cell.imageView.image = cellImg;
                    }
                    
                });
            });
            
            if(!cell.imageView.image)
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

//Deselects the cell after it is clicked
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark UIAlertView Delegate

//If the confirm button is clicked on a delete friend alert
//then then the friend is removed from the user's friends list
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

//Creates the display button for deleting a friend and sets
//it as a footer for the tableView
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

//when the delete friend button is pressed, a delete friend alert is called
- (void)deleteFriendButton
{
    NSLog(@"Delete Account");
    [self deleteFriendAlert:self];
}

//displays a delete friend alert for confirming the friend deletion
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

//Sends a JSON request to delete a friendship on the server
//If the friendship is successfully deleted then we return
//to the last view controller
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
