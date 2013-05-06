/*
 * MyM: Map Your Moments "A Digital Travelogue"
 *
 * Developed using iOS and AWS for CSC Special Topics: Cloud Computing, Spring 2013 by
 * Adam Cumiskey, Dave Hand, Tim Honeywell, Marcelo Mazzotti, Justin Wagner, and Steven Zilberberg
 *
 * FriendUtilityClass.m
 * Helper class which defines functions to do server requests to get a list of a user's friends 
 * and get an email address based on a user's username 
 */

#import "FriendUtilityClass.h"
#import "UtilityClass.h"

@implementation FriendUtilityClass

@synthesize friends;

+ (NSArray *)getFriends:(NSString *)token
{
    NSDictionary *jsonDictionary = @{ @"access_token" : token};
    
    NSArray *jsonGetFriends = [UtilityClass GetFriendsJSON:jsonDictionary toAddress:@"http://54.225.76.23:3000/friends"];
    
    NSArray *friends;
    if(jsonGetFriends) {
        friends = [[NSArray alloc ] initWithArray: jsonGetFriends];
    }
    else {
        //NSLog(@"Http request for friends list failed.");
    }
    
    return friends;
}

+ (NSString *)getEmailFromUsername:(NSString *)username
{
    NSDictionary *jsonDictionary = @{ @"username" : username };
    
    NSDictionary *response = [UtilityClass SendJSON:jsonDictionary toAddress:@"http://54.225.76.23:3000/get_user"];
    
    NSString *email;
    if(response) {
        email = [response valueForKey:@"email"];
    }
    else {
        //NSLog(@"HTTP request for email failed");
    }
    
    return email;
}

@end
