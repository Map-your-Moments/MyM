/*
 * MyM: Map Your Moments "A Digital Travelogue"
 *
 * Developed using iOS and AWS for CSC Special Topics: Cloud Computing, Spring 2013 by
 * Adam Cumiskey, Dave Hand, Tim Honeywell, Marcelo Mazzotti, Justin Wagner, and Steven Zilberberg
 *
 * MomentDetailedSecondViewController.m
 * This VC displays some more information about the moments and allows the user
 * to view the content
 */

#import "MomentDetailedSecondViewController.h"
#import "MomentContentViewController.h"

@interface MomentDetailedSecondViewController ()
{
    Content *momentContent;
    NSArray *sections;
    NSArray *momentDataArray;
}
@end

@implementation MomentDetailedSecondViewController
@synthesize targetMoment;

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
    
    momentContent = [targetMoment content];
    NSString *contentTypeString;
    
    switch([momentContent contentType])
    {
        case kTAGMOMENTTEXT:
            contentTypeString = @"Text";
            break;
        case kTAGMOMENTPICTURE:
            contentTypeString = @"Picture";
            break;
        case kTAGMOMENTAUDIO:
            contentTypeString = @"Audio";
            break;
        case kTAGMOMENTVIDEO:
            contentTypeString = @"Video";
            break;
        default:
            contentTypeString = @"Unknown";
            break;
    }
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString = [dateFormatter stringFromDate:[targetMoment date]];
    
    sections = [[NSArray alloc] initWithObjects:@"Moment Title", @"Date Created", @"Moment Created By", @"Moment Type", @"Content", nil];
    momentDataArray = [[NSArray alloc] initWithObjects:[targetMoment title], dateString, [targetMoment user], contentTypeString, @"Click to See Moment", nil];
}

-(void)viewContent
{
    NSLog(@"View Content");
    MomentContentViewController *child = [[MomentContentViewController alloc] init];
    [child setMomentContent:momentContent];
    [self.navigationController pushViewController:child animated:YES];
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
    return [sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [sections objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"Cell Identification";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if(cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    
    NSString *cellData;
    switch([indexPath section])
    {
        case 0:
            cellData = [momentDataArray objectAtIndex:0];
            break;
        case 1:
            cellData = [momentDataArray objectAtIndex:1];
            break;
        case 2:
            cellData = [momentDataArray objectAtIndex:2];
            break;
        case 3:
            cellData = [momentDataArray objectAtIndex:3];
            break;
        case 4:
            cellData = [momentDataArray objectAtIndex:4];
            break;
    }
    
    cell.textLabel.text = cellData;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath section] != 4)
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    else
    {
        [self viewContent];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

@end
