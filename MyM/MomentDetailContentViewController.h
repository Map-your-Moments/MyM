//
//  MomentDetailContentViewController.h
//  MyM
//
//  Created by Steven Zilberberg on 5/4/13.
//  Copyright (c) 2013 MyM Co. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "Moment.h"

@interface MomentDetailContentViewController : UIViewController

@property (strong, nonatomic) Moment *desiredMoment;

-(void)detailedInformation;

@end
