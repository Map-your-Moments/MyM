/*
 * MyM: Map Your Moments "A Digital Travelogue"
 *
 * Developed using iOS and AWS for CSC Special Topics: Cloud Computing, Spring 2013 by
 * Adam Cumiskey, Dave Hand, Tim Honeywell, Marcelo Mazzotti, Justin Wagner, and Steven Zilberberg
 *
 * User.m
 * Class for a user
 *
 */

#import "User.h"

@implementation User
@synthesize username, name, password, dateJoined, email, settings, moments, friends, profileImage, token;

/* Main constructor for the User class */
-(id)initWithUserName:(NSString *)theUsername andName:(NSString *)theName andPassword:(NSString *)thePassword andDateJoined:(NSDate *)theDate andEmail:(NSString *)theEmail andSettings:(UserSettings *)theSettings andMoments:(MomentDataController *)theMoments andFriends:(NSMutableArray *)theFriends andProfileImage:(NSData *)theProfileImage andToken:(NSString *)theToken
{
    username   = theUsername;
    name       = theName;
    password   = thePassword;
    dateJoined = theDate;
    email      = theEmail;
    settings   = theSettings;
    moments    = theMoments;
    friends    = theFriends;
    token      = theToken;
    profileImage = theProfileImage;
    
    return self;
}

@end
