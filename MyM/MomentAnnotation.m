//
//  MomentAnnotation.m
//  MyM
//
//  Created by Adam on 4/21/13.
//  Copyright (c) 2013 MyM Co. All rights reserved.
//

#import "MomentAnnotation.h"
#import "MomentDetailViewController.h"

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
