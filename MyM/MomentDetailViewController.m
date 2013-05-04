//
//  MomentDetailViewController.m
//  MyM
//
//  Created by Adam on 4/17/13.
//  Copyright (c) 2013 MyM Co. All rights reserved.
//

#define screenWidth [[UIScreen mainScreen] applicationFrame].size.width
#define screenHeight [[UIScreen mainScreen] applicationFrame].size.height

#import "MomentDetailViewController.h"

@interface MomentDetailViewController ()

@end

@implementation MomentDetailViewController
@synthesize moment, username, caption, content;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.view setBackgroundColor:[UIColor colorWithRed:21 green:17 blue:54 alpha:1]];
    
    username = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, screenWidth-10, 20)];
    [username setText:moment.user];
    [self.view addSubview:username];
    
    caption = [[UILabel alloc] initWithFrame:CGRectMake(5, 50, screenWidth-10, 30)];
    [caption setText:moment.title];
    [self.view addSubview:caption];
    
    content = [[UIView alloc] initWithFrame:CGRectMake(0, 85, screenWidth, screenHeight-85)];
    [content setBackgroundColor:[UIColor blueColor]];
    [self.view addSubview:content];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
