//
//  TestingViewController.m
//  MyM
//
//  Created by Steven Zilberberg on 4/3/13.
//  Copyright (c) 2013 MyM Co. All rights reserved.
//

#import "TestingViewController.h"
#import "MomentViewController.h"
#import "Constants.h"

@interface TestingViewController ()

@end

@implementation TestingViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)textButton:(id)sender {
    MomentViewController *momentView = [[MomentViewController alloc] initWithNibName:@"MomentCreateView" bundle:nil];
    [momentView setContentType:kTAGMOMENTTEXT];
    [self.navigationController pushViewController:momentView animated:YES];
}

- (IBAction)soundButton:(id)sender {
    MomentViewController *momentView = [[MomentViewController alloc] initWithNibName:@"MomentCreateView" bundle:nil];
    [momentView setContentType:kTAGMOMENTAUDIO];
    [self.navigationController pushViewController:momentView animated:YES];
}

- (IBAction)pictureButton:(id)sender {
    MomentViewController *momentView = [[MomentViewController alloc] initWithNibName:@"MomentCreateView" bundle:nil];
    [momentView setContentType:kTAGMOMENTPICTURE];
    [self.navigationController pushViewController:momentView animated:YES];
}

- (IBAction)videoButton:(id)sender {
    MomentViewController *momentView = [[MomentViewController alloc] initWithNibName:@"MomentCreateView" bundle:nil];
    [momentView setContentType:kTAGMOMENTVIDEO];
    [self.navigationController pushViewController:momentView animated:YES];
}
@end
