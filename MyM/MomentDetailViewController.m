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
@synthesize moment, name;

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
    // Do any additional setup after loading the view from its nib.
    
    [self.view setBackgroundColor:[UIColor colorWithRed:21 green:17 blue:54 alpha:1]];
    
    name = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, screenWidth-10, 20)];
    [name setText:@"name"];
    [self.view addSubview:name];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
