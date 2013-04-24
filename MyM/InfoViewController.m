//
//  InfoViewController.m
//  MyM
//
//  Created by Steven Zilberberg on 4/24/13.
//  Copyright (c) 2013 MyM Co. All rights reserved.
//

#import "InfoViewController.h"


@implementation InfoViewController
@synthesize returnButton;

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
    
    //[self.returnButton addTarget:self action:@selector(returnView:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)returnView:(id)sender
{
    //NSLog(@"Released View");
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
