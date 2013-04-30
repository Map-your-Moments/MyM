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

- (NSArray *)getFriends:(NSString *)token
{
    NSDictionary *jsonDictionary = @{ @"access_token" : token};
    
    jsonGetFriends = [UtilityClass GetFriendsJSON:jsonDictionary toAddress:@"http://54.225.76.23:3000/friends"];
    
    if(jsonGetFriends) {
        friends = [[NSArray alloc ] initWithArray: jsonGetFriends];
    }
    else {
        NSLog(@"Http request for friends list failed.");
    }
    
    return friends;
}

@end
