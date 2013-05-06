/*
 * MyM: Map Your Moments "A Digital Travelogue"
 *
 * Developed using iOS and AWS for CSC Special Topics: Cloud Computing, Spring 2013 by
 * Adam Cumiskey, Dave Hand, Tim Honeywell, Marcelo Mazzotti, Justin Wagner, and Steven Zilberberg
 *
 * FriendUtilityClass.h
 * Helper class which defines functions to do server requests to get a list of a user's friends
 * and get an email address based on a user's username
 */

#import <Foundation/Foundation.h>

@interface FriendUtilityClass : NSObject

@property(nonatomic, copy) NSArray *friends;

+ (NSArray *)getFriends:(NSString *)token;
+ (NSString *)getEmailFromUsername:(NSString *)username;

@end
