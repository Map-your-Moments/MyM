//
//  MomentDataController.m
//  MyM
//
//  Created by Adam on 3/6/13.
//  Copyright (c) 2013 MyM Co. All rights reserved.
//

#import "MomentDataController.h"
#import "Moment.h"
#import "AmazonClientManager.h"

@interface MomentDataController()
-(void)initializeDefaultDataList;
@end

@implementation MomentDataController

#pragma mark - initialization Methods

/* When called, will initialize an empty array for the moments array */
-(void)initializeDefaultDataList
{
    NSMutableArray *moments = [[NSMutableArray alloc] init];
    self.moments = moments;
}

/* Setter for the moments in the dataController */
-(void)setMoments:(NSMutableArray *)newList
{
    if(_moments != newList) {
        _moments = [newList mutableCopy];
    }
}

/* Initalize a new empty dataController if one does not already exist */
-(id)init
{
    if(self = [super init]) {
        [self initializeDefaultDataList];
        return self;
    } else return nil;
}

# pragma mark - dataController methods

/* Return the number of moments in the dataController */
-(NSUInteger)countOfMoments
{
    return [self.moments count];
}

/* Get the moment at the specified index */
-(Moment *)objectInMomentsAtIndex:(NSUInteger)index
{
    Moment *moment = [self.moments objectAtIndex:index];
    return moment;
}

/* Add a moment */
- (void)addMomentToMomentsWithMoment:(Moment *)moment
{
    [self.moments addObject:moment];
}

/* Remove a moment */
- (void)removeMomentAtIndex:(NSUInteger)index
{
    [self.moments removeObjectAtIndex:index];
}


/* Remove all moments in the dataController
 */
-(void)removeAllMoments
{
    [self.moments removeAllObjects];
}

@end
