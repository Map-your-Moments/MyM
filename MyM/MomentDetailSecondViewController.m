//
//  MomentDetailSecondViewController.m
//  MyM
//
//  Created by Steven Zilberberg on 5/4/13.
//  Copyright (c) 2013 MyM Co. All rights reserved.
//

#import "MomentDetailSecondViewController.h"

@interface MomentDetailSecondViewController ()
{
    Content *momentContent;
    NSArray *sections;
    NSArray *momentDataArray;
}

@end

@implementation MomentDetailSecondViewController
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
    }
    
    sections = [[NSArray alloc] initWithObjects:@"Moment Title", @"Date Created", @"Moment Created By", @"Moment Type", nil];
    momentDataArray = [[NSArray alloc] initWithObjects:[targetMoment title], [targetMoment date], [targetMoment user], contentTypeString, nil];
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
    }
    
    cell.textLabel.text = cellData;
    
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
