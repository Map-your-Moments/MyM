//
//  MomentAnnotation.h
//  MyM
//
//  Created by Adam on 4/21/13.
//  Copyright (c) 2013 MyM Co. All rights reserved.
//

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
