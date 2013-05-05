/*
 * MyM: Map Your Moments "A Digital Travelogue"
 *
 * Developed using iOS and AWS for CSC Special Topics: Cloud Computing, Spring 2013 by
 * Adam Cumiskey, Dave Hand, Tim Honeywell, Marcelo Mazzotti, Justin Wagner, and Steven Zilberberg
 *
 * MomentAnnotation.h
 *
 */

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Moment.h"

@interface MomentAnnotation : NSObject <MKAnnotation>

@property (nonatomic, strong) Moment *moment;
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *subtitle;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

-(id)initWithMoment:(Moment *)moment title:(NSString *)title subtitle:(NSString *)subtitle coordinate:(CLLocationCoordinate2D)coordinate;

@end
