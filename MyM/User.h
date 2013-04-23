//
//  User.h
//  MyM
//
//  Created by Adam on 3/6/13.
//  Copyright (c) 2013 MyM Co. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MomentDataController.h"
#import "UserSettings.h"

@interface User : NSObject
@property (nonatomic) NSString *token;
@property (nonatomic) UIImage *profileImage;
@property (nonatomic) NSURL *profileImageURL;
@property (nonatomic) NSString *username;
@property (nonatomic) NSString *password; // should be encrypted
@property (nonatomic) NSDate *dateJoined;
@property (nonatomic) NSString *email;
@property (nonatomic) UserSettings *settings;
@property (nonatomic) MomentDataController *moments;
@property (nonatomic) NSMutableArray *friends;

-(id)initWithUserName:(NSString *)theUsername andPassword:(NSString *)thePassword andDateJoined:(NSDate *)theDate andEmail:(NSString *)theEmail andSettings:(UserSettings *)theSettings andMoments:(MomentDataController *)theMoments andFriends:(NSMutableArray *)theFriends andToken:(NSString *)theToken;

@end
