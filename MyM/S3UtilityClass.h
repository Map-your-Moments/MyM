//
//  S3UtilityClass.h
//  MyM
//
//  Created by Adam on 4/30/13.
//  Copyright (c) 2013 MyM Co. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AmazonClientManager.h"
#import "MomentDataController.h"
#import "Moment.h"
#import "Constants.h"
#import "FriendUtilityClass.h"
#import "User.h"

@interface S3UtilityClass : NSObject

@property (nonatomic) MomentDataController *dataController;

+ (void)addMomentToS3:(Moment *)moment;
+ (void)removeMomentFromS3:(Moment *)moment;

- (MomentDataController *)updateMomentsForUser:(User *)user;

@end
