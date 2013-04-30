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
#import "Constants.h"

@interface S3UtilityClass : NSObject

@property (nonatomic) MomentDataController *dataController;
@property (nonatomic) Moment *tempMoment;

- (MomentDataController *)updateMomentsForUser:(NSString *)user;

@end
