//
//  S3UtilityClass.m
//  MyM
//
//  Created by Adam on 4/30/13.
//  Copyright (c) 2013 MyM Co. All rights reserved.
//

#import "S3UtilityClass.h"

@implementation S3UtilityClass
@synthesize dataController;


+ (void)addMomentToS3:(Moment *)moment
{
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

+ (void)removeMomentFromS3:(Moment *)moment
{
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


/*     This group of methods updates the moments on the map from the S3 server
 *
 * Logical Structure :::
 *         -dataController is cleared
 *         -each s3 folder that the user has access to will list all of the keys
 *             for the objects in them and add them to an array
 *         -the getMomentPreviews for keys will take the keys and create moment previews for
 *             each one
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
    [self getMomentPreviewsForKeys:keys];
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
    NSArray *friends = [NSArray arrayWithArray:[FriendUtilityClass getFriends:[user token]]];
    
    // Add the user's moments
    [objectKeys addObjectsFromArray:[self listMomentsInS3Folder:[NSString stringWithFormat:@"%@/", user.username]]];
    
    // Add the friend's moments
    for(NSDictionary *friend in friends) {
        [objectKeys addObjectsFromArray:[self listMomentsInS3Folder:[NSString stringWithFormat:@"%@/", [friend valueForKey:@"username"]]]];
    }
    
    return objectKeys;
}

- (void)getMomentPreviewsForKeys:(NSArray *)keys
{
    for (S3ObjectSummary *object in keys) {
        
        Moment *moment;
        
        // get the coordinates by parsing the string
        NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"/_"];
        NSArray *tokens = [object.key componentsSeparatedByCharactersInSet:set];
        double latitude = [[tokens objectAtIndex:1] doubleValue];
        double longitude = [[tokens objectAtIndex:2] doubleValue];
        CLLocationCoordinate2D coords = CLLocationCoordinate2DMake( latitude, longitude );
        
        // get the title and user name from the metadata
        @try {
            S3GetObjectMetadataRequest *request = [[S3GetObjectMetadataRequest alloc] initWithKey:object.key withBucket:kS3BUCKETNAME];
            S3GetObjectMetadataResponse *response = [[AmazonClientManager amazonS3Client] getObjectMetadata:request];
            
            moment = [[Moment alloc] initWithTitle:[response getMetadataForKey:@"title"]
                                           andUser:[response getMetadataForKey:@"user"]
                                        andContent:nil
                                           andDate:nil
                                         andCoords:coords
                                       andComments:nil
                                             andID:[NSString stringWithFormat:@"%@_%@_%@", tokens[1], tokens[2], tokens[3]]];
            
            if(response.error != nil)
                NSLog(@"Error: %@", response.error);
        }
        @catch (AmazonClientException *exception) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:exception.message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            NSLog(@"Exception: %@", exception);
        }
        
        [dataController addMomentToMomentsWithMoment:moment];
    }
}

// This method will return the moment with the content.
// Only use this when requesting an individual moment.
+ (Moment *)getMomentWithKey:(NSString *)key
{
    Moment *moment;
    
    @try{
        S3GetObjectRequest *request = [[S3GetObjectRequest alloc] initWithKey:key withBucket:kS3BUCKETNAME];
        S3GetObjectResponse *response = [[AmazonClientManager amazonS3Client] getObject:request];
        
        // get the data for the moment, then use the KeyedUnarchiver to convert it back to a moment object.
        // temp moment will get overwritten everytime this method is called.
        NSData *momentData = response.body;
        moment = [NSKeyedUnarchiver unarchiveObjectWithData:momentData];
        
        if(response.error != nil)
            NSLog(@"Error: %@", response.error);
    }
    @catch (AmazonClientException *exception) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:exception.message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        NSLog(@"Exception: %@", exception);
    }
    return moment;
}

@end
