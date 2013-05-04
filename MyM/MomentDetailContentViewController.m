//
//  MomentDetailContentViewController.m
//  MyM
//
//  Created by Steven Zilberberg on 5/4/13.
//  Copyright (c) 2013 MyM Co. All rights reserved.
//

#import "MomentDetailContentViewController.h"
#import "MomentDetailSecondViewController.h"
#import "Constants.h"

#define MOMENT_CONTENTVIEW_X        20
#define MOMENT_CONTENTVIEW_Y        90
#define MOMENT_CONTENTVIEW_WIDTH    280
#define MOMENT_CONTENTVIEW_HEIGHT   180

@interface MomentDetailContentViewController ()
{
    Content *momentContent;
    
    int contentType;
    NSString *momentTitle;
    
    UITextField *momentTextField;
    UIImageView *momentImage;
    MPMoviePlayerViewController *moviePlayer;
}

@end

@implementation MomentDetailContentViewController
@synthesize desiredMoment;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(detailedInformation)];
    
    momentContent = [desiredMoment content];
    
    momentTitle = [desiredMoment title];
    contentType = [momentContent contentType];
    
    switch(contentType)
    {
        case kTAGMOMENTTEXT:
        {
            momentTextField = [[UITextField alloc] initWithFrame:CGRectMake(MOMENT_CONTENTVIEW_X, MOMENT_CONTENTVIEW_Y, MOMENT_CONTENTVIEW_WIDTH, MOMENT_CONTENTVIEW_HEIGHT * 2)];
            [momentTextField setText:(NSString*)[momentContent content]];
            break;
        }
        case kTAGMOMENTPICTURE:
        {
            momentImage = [[UIImageView alloc] initWithImage:(UIImage*)[momentContent content]];
            break;
        }
        case kTAGMOMENTAUDIO:
        {
            break;
        }
        case kTAGMOMENTVIDEO:
        {
            break;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)detailedInformation
{
    MomentDetailSecondViewController *child = [[MomentDetailSecondViewController alloc] initWithStyle:UITableViewStylePlain];
    [child setTargetMoment:desiredMoment];
    [self.navigationController pushViewController:child animated:YES];
}


@end
