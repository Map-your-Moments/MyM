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

/* Add a moment locally */
- (void)addMomentToMomentsWithMoment:(Moment *)moment
{
    [self.moments addObject:moment];
}

/* Add a moment to the dataController and the server */
- (void)addMomentToMomentsAndServerWithMoment:(Moment *)moment
{
    [self.moments addObject:moment];
    
    NSData *momentData = [NSKeyedArchiver archivedDataWithRootObject:moment];
    NSString *key = [NSString stringWithFormat:@"%@/%@", moment.user, moment.ID];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        });
        
        @try{
            S3PutObjectRequest *request = [[S3PutObjectRequest alloc] initWithKey:key
                                                                         inBucket:kS3BUCKETNAME];
            request.data = momentData;
            [request addMetadataWithValue:moment.title forKey:@"title"];
            [request addMetadataWithValue:moment.user forKey:@"user"];
            S3PutObjectResponse *response = [[AmazonClientManager amazonS3Client] putObject:request];
            if(response.error != nil)
                NSLog(@"Error: %@", response.error);
        }
        @catch (AmazonClientException *exception) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:exception.message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            NSLog(@"Exception: %@", exception);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
    });
}

- (void)removeMomentAtIndex:(NSUInteger)index
{
    [self.moments removeObjectAtIndex:index];
}

/* Remove the moment at the selected index
   This moment is used to remove a moment.
            *** Caution!!! ***
   This method should not be used if you 
   just want to remove the moment locally,
   as it will remove it from the server as
   well.
 */
-(void)removeMomentFromMomentsAndServerAtIndex:(NSUInteger)index
{
    [self.moments removeObjectAtIndex:index];
    
    Moment *moment = [self.moments objectAtIndex:index];
    NSString *key = [NSString stringWithFormat:@"%@/%@", moment.user, moment.ID];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        });
        
        @try{
            S3DeleteObjectRequest *request = [[S3DeleteObjectRequest alloc] init];
            [request setKey:key];
            S3DeleteObjectResponse *response = [[AmazonClientManager amazonS3Client] deleteObject:request];
            if(response.error != nil)
                NSLog(@"Error: %@", response.error);
        }
        @catch (AmazonClientException *exception) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:exception.message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            NSLog(@"Exception: %@", exception);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
    });
}

/* Remove all moments in the dataController
   Leave this without aws support, so that it can clear the local data
 */
-(void)removeAllMoments
{
    [self.moments removeAllObjects];
}

@end
