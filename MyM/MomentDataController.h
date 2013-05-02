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

@property (nonatomic, retain) NSMutableArray *moments;

-(void)addMomentToMomentsWithMoment:(Moment *)moment;
- (void)addMomentToMomentsAndServerWithMoment:(Moment *)moment;
-(void)removeMomentAtIndex:(NSUInteger)index;
-(void)removeMomentFromMomentsAndServerAtIndex:(NSUInteger)index;
-(void)removeAllMoments;

-(NSUInteger)countOfMoments;

-(Moment *)objectInMomentsAtIndex:(NSUInteger)index;


@end
