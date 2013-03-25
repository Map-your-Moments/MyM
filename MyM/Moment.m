//
//  Moment.m
//  MyM
//
//  Created by Adam on 3/6/13.
//  Copyright (c) 2013 MyM Co. All rights reserved.
//

#import "Moment.h"

@implementation Moment
@synthesize title, user, content, date, coords, comments, tripID;

/* Main constructor for the Moment class */
-(id)initWithTitle:(NSString *)theTitle andUser:(User *)theUser andContent:(Content *)theContent andDate:(NSDate *)theDate andCoords:(CLLocationCoordinate2D)theCoords andComments:(NSMutableArray *)theComments andTripID:(NSString *)theTripID
{
    title    = theTitle;
    user     = theUser;
    content  = theContent;
    date     = theDate;
    coords   = theCoords;
    comments = theComments;
    tripID   = theTripID;
    
    return self;
}

@end
