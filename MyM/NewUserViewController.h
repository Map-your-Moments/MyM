//
//  NewUserViewController.h
//  MyM
//
//  Created by Marcelo Mazzotti on 25/3/13.
//  Copyright (c) 2013 MyM Co. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AmazonClientManager.h"

@protocol NewUserDelegate <NSObject>
- (void)newUserCreated;
@end

@interface NewUserViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) id<NewUserDelegate> delegate;
@end