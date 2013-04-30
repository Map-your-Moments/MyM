//
//  FriendUtilityClass.m
//  MyM
//
//  Created by Justin Wagner on 4/30/13.
//  Copyright (c) 2013 MyM Co. All rights reserved.
//

#import "FriendUtilityClass.h"
#import "UtilityClass.h"

@implementation FriendUtilityClass

@synthesize friends;
@synthesize jsonGetFriends;

- (NSArray *)getFriends:user
{
    NSDictionary *jsonDictionary = @{ @"access_token" : user};
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^ {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        });
        jsonGetFriends = [UtilityClass GetFriendsJSON:jsonDictionary toAddress:@"http://54.225.76.23:3000/friends"];
        dispatch_async(dispatch_get_main_queue(), ^ {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            if(jsonGetFriends)
            {
                friends = [[NSArray alloc ] initWithArray: jsonGetFriends];
            }
            else
            {
                NSLog(@"Http request for friends list failed.");
            }
        });
    });

    
    
    return friends;
}

@end
