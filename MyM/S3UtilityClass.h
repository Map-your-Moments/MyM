/*
 * MyM: Map Your Moments "A Digital Travelogue"
 *
 * Developed using iOS and AWS for CSC Special Topics: Cloud Computing, Spring 2013 by
 * Adam Cumiskey, Dave Hand, Tim Honeywell, Marcelo Mazzotti, Justin Wagner, and Steven Zilberberg
 *
 * S3UtilityClass.h
 * 
 *
 */

#import <Foundation/Foundation.h>
#import "AmazonClientManager.h"
#import "MomentDataController.h"
#import "Moment.h"
#import "Constants.h"
#import "FriendUtilityClass.h"
#import "User.h"

@interface S3UtilityClass : NSObject

@property (nonatomic) MomentDataController *dataController;

+ (void)addMomentToS3:(Moment *)moment;
+ (void)removeMomentFromS3:(Moment *)moment;

- (MomentDataController *)updateMomentsForUser:(User *)user;

+ (Moment *)getMomentWithKey:(NSString *)key;

@end
