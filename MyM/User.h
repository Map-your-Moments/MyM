/*
 * MyM: Map Your Moments "A Digital Travelogue"
 *
 * Developed using iOS and AWS for CSC Special Topics: Cloud Computing, Spring 2013 by
 * Adam Cumiskey, Dave Hand, Tim Honeywell, Marcelo Mazzotti, Justin Wagner, and Steven Zilberberg
 *
 * User.h
 *
 *
 */

#import <Foundation/Foundation.h>
#import "MomentDataController.h"
#import "UserSettings.h"

@interface User : NSObject

@property (nonatomic) NSString *token;
@property (nonatomic) NSData *profileImage;
@property (nonatomic) NSString *username;
@property (nonatomic) NSString *password; // should be encrypted
@property (nonatomic) NSDate *dateJoined;
@property (nonatomic) NSString *email;
@property (nonatomic) UserSettings *settings;
@property (nonatomic) MomentDataController *moments;
@property (nonatomic) NSMutableArray *friends;
@property (nonatomic) NSString *name;

-(id)initWithUserName:(NSString *)theUsername andName:(NSString *)theName andPassword:(NSString *)thePassword andDateJoined:(NSDate *)theDate andEmail:(NSString *)theEmail andSettings:(UserSettings *)theSettings andMoments:(MomentDataController *)theMoments andFriends:(NSMutableArray *)theFriends andProfileImage:(NSData *)theProfileImage andToken:(NSString *)theToken;

@end
