//
//  Moment.h
//  MyM
//
//  Created by Adam on 3/6/13.
//  Copyright (c) 2013 MyM Co. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "User.h"
#import "Content.h"

@interface Moment : NSObject

@property (nonatomic) NSString *title;
@property (nonatomic) User *user;
@property (nonatomic) Content *content;
@property (nonatomic) NSDate *date;
@property (nonatomic) CLLocationCoordinate2D coords;
@property (nonatomic) NSMutableArray *comments;
@property (nonatomic) NSString *tripID;

-(id)initWithTitle:(NSString *)theTitle andUser:(User *)theUser andContent:(Content *)theContent andDate:(NSDate *)theDate andCoords:(CLLocationCoordinate2D)theCoords andComments:(NSMutableArray *)theComments andTripID:(NSString *)theTripID;

@end
