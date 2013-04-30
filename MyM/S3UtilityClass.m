//
//  S3UtilityClass.m
//  MyM
//
//  Created by Adam on 4/30/13.
//  Copyright (c) 2013 MyM Co. All rights reserved.
//

#import "S3UtilityClass.h"

@implementation S3UtilityClass
@synthesize dataController, tempMoment;

/*     This group of methods updates the moments on the map from the S3 server
 *
 * Logical Structure :::
 *         -dataController is cleared
 *         -each s3 folder that the user has access to will list all of the keys
 *             for the objects in them and add them to an array
 *         -the getAllObjectsFromKeys: method will take that array and get the data
 *             for each individual object, unarchive it, then add it to the dataController
 *
 *                            *** Caution ***
 *     The only method here that should be called outside of this block is the
 * updateMoments method to refresh the dataController. updateMoments has an
 * asynchronous block from where it calls it's helper functions, but the helper
 * functions themselves do not, thus if they are called directly they will cause
 * the UI to hang until they finish.
 */

- (MomentDataController *)updateMomentsForUser:(User *)user
{
    dataController = [[MomentDataController alloc] init];
    NSArray *keys = [NSArray arrayWithArray:[self listAllMomentsForUser:user]];
    [self getAllObjectsFromKeys:keys];
    return dataController;
}

- (NSArray *)listMomentsInS3Folder:(NSString *)folder
{
    NSArray *keys = [[NSArray alloc] init];
    
    @try{
        S3ListObjectsRequest *request = [[S3ListObjectsRequest alloc] init];
        [request setBucket:kS3BUCKETNAME];
        [request setPrefix:folder];
        [request setMarker:folder];
        S3ListObjectsResponse *response = [[AmazonClientManager amazonS3Client] listObjects:request];
        keys = response.listObjectsResult.objectSummaries;
        if(response.error != nil)
            NSLog(@"Error: %@", response.error);
    }
    @catch (AmazonClientException *exception) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:exception.message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        NSLog(@"Exception: %@", exception);
    }
    
    return keys;
}

- (NSArray *)listAllMomentsForUser:(User *)user
{
    NSMutableArray *objectKeys = [[NSMutableArray alloc] init];
    
    // Get the list of friends
    FriendUtilityClass *friendUtil = [[FriendUtilityClass alloc] init];
    NSArray *friends = [NSArray arrayWithArray:[friendUtil getFriends:[user token]]];
    
    // Add the user's moments
    [objectKeys addObjectsFromArray:[self listMomentsInS3Folder:[NSString stringWithFormat:@"%@/", user.username]]];
    
    // Add the friend's moments
    for(NSDictionary *friend in friends) {
        [objectKeys addObjectsFromArray:[self listMomentsInS3Folder:[NSString stringWithFormat:@"%@/", [friend valueForKey:@"username"]]]];
    }
    
    return objectKeys;
}

- (void)getMomentWithKey:(NSString *)key
{
    @try{
        S3GetObjectRequest *request = [[S3GetObjectRequest alloc] initWithKey:key withBucket:kS3BUCKETNAME];
        S3GetObjectResponse *response = [[AmazonClientManager amazonS3Client] getObject:request];
        
        // get the data for the moment, then use the KeyedUnarchiver to convert it back to a moment object.
        // temp moment will get overwritten everytime this method is called.
        NSData *momentData = response.body;
        tempMoment = [NSKeyedUnarchiver unarchiveObjectWithData:momentData];
        
        if(response.error != nil)
            NSLog(@"Error: %@", response.error);
    }
    @catch (AmazonClientException *exception) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:exception.message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        NSLog(@"Exception: %@", exception);
    }
}

- (void)getAllObjectsFromKeys:(NSArray *)keys
{
    for (S3ObjectSummary *object in keys) {
        [self getMomentWithKey:object.key];
        [dataController addMomentToMomentsWithMoment:tempMoment];
    }
}


@end
