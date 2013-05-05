/*
 * MyM: Map Your Moments "A Digital Travelogue"
 *
 * Developed using iOS and AWS for CSC Special Topics: Cloud Computing, Spring 2013 by
 * Adam Cumiskey, Dave Hand, Tim Honeywell, Marcelo Mazzotti, Justin Wagner, and Steven Zilberberg
 *
 * Moment.h
 * File summary.
 *
 */

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "User.h"
#import "Content.h"

@interface Moment : NSObject <NSCoding, NSCopying>

@property (nonatomic) NSString *title;
@property (nonatomic) NSString *user;
@property (nonatomic) Content *content;
@property (nonatomic) NSDate *date;
@property (nonatomic) CLLocationCoordinate2D coords;
@property (nonatomic) NSMutableArray *comments;
@property (nonatomic) NSString *ID;
@property (nonatomic) NSArray *tags;

- (id)initWithTitle:(NSString *)theTitle andUser:(NSString *)theUser andContent:(Content *)theContent andDate:(NSDate *)theDate andCoords:(CLLocationCoordinate2D)theCoords andComments:(NSMutableArray *)theComments;

- (void)encodeWithCoder:(NSCoder *)coder;
- (id)initWithCoder:(NSCoder *)decoder;

@end
