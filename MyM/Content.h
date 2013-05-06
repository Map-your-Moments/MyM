/*
 * MyM: Map Your Moments "A Digital Travelogue"
 *
 * Developed using iOS and AWS for CSC Special Topics: Cloud Computing, Spring 2013 by
 * Adam Cumiskey, Dave Hand, Tim Honeywell, Marcelo Mazzotti, Justin Wagner, and Steven Zilberberg
 *
 * Content.h
 * 
 *
 */

#import <Foundation/Foundation.h>
#import "Constants.h"

@interface Content : NSObject <NSCoding, NSCopying>

@property (nonatomic) int contentType;
@property (nonatomic) NSData *content;

@property (nonatomic) NSMutableArray *tags;

-(id)initWithContent:(NSData*)momentContent withType:(int)theContentType andTags:(NSMutableArray *)theTags;

- (void)encodeWithCoder:(NSCoder *)coder;
- (id)initWithCoder:(NSCoder *)decoder;

@end
