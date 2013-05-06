/*
 * MyM: Map Your Moments "A Digital Travelogue"
 *
 * Developed using iOS and AWS for CSC Special Topics: Cloud Computing, Spring 2013 by
 * Adam Cumiskey, Dave Hand, Tim Honeywell, Marcelo Mazzotti, Justin Wagner, and Steven Zilberberg
 *
 * MomentDataController.h
 * 
 *
 */

#import <Foundation/Foundation.h>

@class Moment;

@interface MomentDataController : NSObject

@property (nonatomic, retain) NSMutableArray *moments;

-(void)addMomentToMomentsWithMoment:(Moment *)moment;
-(void)removeMomentAtIndex:(NSUInteger)index;
-(void)removeAllMoments;

-(NSUInteger)countOfMoments;

-(Moment *)objectInMomentsAtIndex:(NSUInteger)index;


@end
