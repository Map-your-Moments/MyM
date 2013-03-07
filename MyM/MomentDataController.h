//
//  MomentDataController.h
//  MyM
//
//  Created by Adam on 3/6/13.
//  Copyright (c) 2013 MyM Co. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Moment;

@interface MomentDataController : NSObject

@property (nonatomic) NSMutableArray *moments;

/* Data Controller Methods */
-(NSUInteger)countOfMoments;
-(Moment *)objectInMomentsAtIndex:(NSUInteger)index;
-(void)addMomentToMomentsWithMoment:(Moment *)moment;
-(void)removeMomentAtIndex:(NSUInteger)index;
-(void)removeAllMoments;

@end
