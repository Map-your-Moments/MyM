//
//  MomentDataController.m
//  MyM
//
//  Created by Adam on 3/6/13.
//  Copyright (c) 2013 MyM Co. All rights reserved.
//

#import "MomentDataController.h"

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

/* Add a moment to the dataController
   This method will need to eventually support 
   adding to aws as well
 */
-(void)addMomentToMomentsWithMoment:(Moment *)moment
{
    [self.moments addObject:moment];
}

/* Remove the moment at the selected index
   This will only remove it from the dataController for now.
   More code will be needed to remove it from aws as well
 */
-(void)removeMomentAtIndex:(NSUInteger)index
{
    [self.moments removeObjectAtIndex:index];
}

/* Remove all moments in the dataController
   This method will also need aws support eventually
 */
-(void)removeAllMoments
{
    [self.moments removeAllObjects];
}

@end
