/*
 * MyM: Map Your Moments "A Digital Travelogue"
 *
 * Developed using iOS and AWS for CSC Special Topics: Cloud Computing, Spring 2013 by
 * Adam Cumiskey, Dave Hand, Tim Honeywell, Marcelo Mazzotti, Justin Wagner, and Steven Zilberberg
 *
 * UtilityClass.m
 * Helper class which defines functions to send requests to the server and to resize images.
 */

#import <Foundation/Foundation.h>

@interface UtilityClass : NSObject

+ (NSDictionary *)SendJSON:(NSDictionary *)jsonDictionary toAddress:(NSString *)address;

+ (NSArray *)GetFriendsJSON: (NSDictionary *)jsonDictionary toAddress:(NSString *)address;

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

@end
