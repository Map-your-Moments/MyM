/*
 * MyM: Map Your Moments "A Digital Travelogue"
 *
 * Developed using iOS and AWS for CSC Special Topics: Cloud Computing, Spring 2013 by
 * Adam Cumiskey, Dave Hand, Tim Honeywell, Marcelo Mazzotti, Justin Wagner, and Steven Zilberberg
 *
 * MomentAnnotation.m
 * This file provides a custom MKAnnotation object which we can store moment data in
 *
 */

#import "MomentAnnotation.h"

@implementation MomentAnnotation
@synthesize moment, title, subtitle, coordinate;

- (id)initWithMoment:(Moment *)themoment title:(NSString *)thetitle subtitle:(NSString *)thesubtitle coordinate:(CLLocationCoordinate2D)thecoordinate
{
    moment = themoment;
    title = thetitle;
    subtitle = thesubtitle;
    coordinate = thecoordinate;
    
    return self;
}

@end
