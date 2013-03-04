//
//  SignInViewController.m
//  MyM
//
//  Created by Steven Zilberberg on 3/4/13.
//  Copyright (c) 2013 MyM Co. All rights reserved.
//

#import "SignInViewController.h"

@implementation SignInViewController
@synthesize icon_mym;
@synthesize txtUsername;
@synthesize txtPassword;

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
	// Do any additional setup after loading the view.
}


- (IBAction)signInButton:(id)sender
{
    NSLog(@"Signin");
}

- (IBAction)registerButton:(id)sender
{
    NSLog(@"Register");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
