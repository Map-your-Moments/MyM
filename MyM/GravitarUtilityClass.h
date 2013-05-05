/*
 * MyM: Map Your Moments "A Digital Travelogue"
 *
 * Developed using iOS and AWS for CSC Special Topics: Cloud Computing, Spring 2013 by
 * Adam Cumiskey, Dave Hand, Tim Honeywell, Marcelo Mazzotti, Justin Wagner, and Steven Zilberberg
 *
 * GravitarUtilityClass.h
 * Helper class which defines functions to retrieve gravitar profile images from a user's email
 */

#import <Foundation/Foundation.h>

@interface GravitarUtilityClass : NSObject

+ (UIImage *)gravitarImageForUser:(NSString *)user;

+ (NSURL*) getGravatarURL:(NSString*) emailAddress;
+ (NSData *) requestGravatar:(NSURL*) gravatarURL;

@end
