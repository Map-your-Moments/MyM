/*
 * MyM: Map Your Moments "A Digital Travelogue"
 *
 * Developed using iOS and AWS for CSC Special Topics: Cloud Computing, Spring 2013 by
 * Adam Cumiskey, Dave Hand, Tim Honeywell, Marcelo Mazzotti, Justin Wagner, and Steven Zilberberg
 *
 * GravitarUtilityClass.m
 * Helper class which defines functions to retrieve gravitar profile images from a user's email
 */

#import "GravitarUtilityClass.h"
#import "NSString+MD5.h"
#import "FriendUtilityClass.h"


@implementation GravitarUtilityClass

//Returns the gravitar data for a user's profile picture based on the username
+ (UIImage *)gravitarImageForUser:(NSString *)user
{
    NSString *email = [FriendUtilityClass getEmailFromUsername:user];
    NSURL *gravitarURL = [self getGravatarURL:email];
    NSData *gravitarData = [self requestGravatar:gravitarURL];
    return [UIImage imageWithData:gravitarData];
}

//Requests the URL for a profile picture by providing the account's email address
+ (NSURL*) getGravatarURL:(NSString*) emailAddress
{
	NSString *curatedEmail = [[emailAddress stringByTrimmingCharactersInSet:
							   [NSCharacterSet whitespaceCharacterSet]]
							  lowercaseString];
	
	NSString *gravatarEndPoint = [NSString stringWithFormat:@"http://www.gravatar.com/avatar/%@?s=80&d=https%%3A%%2F%%2Fs3.amazonaws.com%%2Fmym-csc470%%2FDefaultProfilePic@2x.png", [curatedEmail MD5]];
	
	return [NSURL URLWithString:gravatarEndPoint];
}

//Requests the profile picture from gravatar with the specified URL
+ (NSData *) requestGravatar:(NSURL*) gravatarURL
{
	NSError *error;
	NSData* data = [[NSData alloc] initWithContentsOfURL:gravatarURL
												 options:NSDataReadingUncached error:&error];
    return data ? data : nil;
}

@end
