//
//  MomentDetailViewController.h
//  MyM
//
//  Created by Adam on 4/17/13.
//  Copyright (c) 2013 MyM Co. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Moment.h"

@interface MomentDetailViewController : UIViewController

@property (nonatomic, strong) Moment *moment;

@property (nonatomic, strong) UILabel *username;
@property (nonatomic, strong) UILabel *caption;
@property (nonatomic, strong) UIView *content;

@end
