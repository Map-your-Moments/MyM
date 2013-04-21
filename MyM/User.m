//
//  User.m
//  MyM
//
//  Created by Adam on 3/6/13.
//  Copyright (c) 2013 MyM Co. All rights reserved.
//

#import "User.h"

@implementation User
@synthesize username, password, dateJoined, email, settings, moments, friends, profileImage, profileImageURL;

/* Main constructor for the User class */
-(id)initWithUserName:(NSString *)theUsername andPassword:(NSString *)thePassword andDateJoined:(NSDate *)theDate andEmail:(NSString *)theEmail andSettings:(UserSettings *)theSettings andMoments:(MomentDataController *)theMoments andFriends:(NSMutableArray *)theFriends
{
    username   = theUsername;
    password   = thePassword;
    dateJoined = theDate;
    email      = theEmail;
    settings   = theSettings;
    moments    = theMoments;
    friends    = theFriends;
    
#warning Geturl for profile pic?
    
    return self;
}

@end
