/*
 * MyM: Map Your Moments "A Digital Travelogue"
 *
 * Developed using iOS and AWS for CSC Special Topics: Cloud Computing, Spring 2013 by
 * Adam Cumiskey, Dave Hand, Tim Honeywell, Marcelo Mazzotti, Justin Wagner, and Steven Zilberberg
 *
 * Moment.m
 * Class for a moment
 *
 */

#import "Moment.h"

@implementation Moment
@synthesize title, user, content, date, coords, comments, ID;

/* Main constructor for the Moment class */
- (id)initWithTitle:(NSString *)theTitle andUser:(NSString *)theUser andContent:(Content *)theContent andDate:(NSDate *)theDate andCoords:(CLLocationCoordinate2D)theCoords andComments:(NSMutableArray *)theComments
{
    title    = theTitle;
    user     = theUser;
    content  = theContent;
    date     = theDate;
    coords   = theCoords;
    comments = theComments;
    ID = [NSString stringWithFormat:@"%f_%f_%@_%@_%f", coords.latitude, coords.longitude, title, user, date.timeIntervalSince1970];
    
    return self;
}

#pragma mark - NSCoding Protocol

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:title forKey:@"Title"];
    [coder encodeObject:user forKey:@"User"];
    [coder encodeObject:content forKey:@"Content"];
    [coder encodeObject:date forKey:@"Date"];

    double latitude  = coords.latitude;
    double longitude = coords.longitude;
    [coder encodeObject:[NSNumber numberWithDouble:latitude] forKey:@"Latitude"];
    [coder encodeObject:[NSNumber numberWithDouble:longitude] forKey:@"Longitude"];
    
    [coder encodeObject:comments forKey:@"Comments"];
    [coder encodeObject:ID forKey:@"ID"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    
    if(self)
    {
        title = [[decoder decodeObjectForKey:@"Title"] copy];
        user = [[decoder decodeObjectForKey:@"User"] copy];
        content = [[decoder decodeObjectForKey:@"Content"] copy];
        date = [[decoder decodeObjectForKey:@"Date"] copy];
        comments = [[decoder decodeObjectForKey:@"Comments"] copy];
        ID = [[decoder decodeObjectForKey:@"ID"] copy];
        
        NSNumber *latitude  = [[decoder decodeObjectForKey:@"Latitude"] copy];
        NSNumber *longitude = [[decoder decodeObjectForKey:@"Longitude"] copy];
        coords.latitude  = (CLLocationDegrees)[latitude doubleValue];
        coords.longitude = (CLLocationDegrees)[longitude doubleValue];
    }
    
    return self;
}

#pragma mark - NSCopying Protocol

- (id)copyWithZone:(NSZone *)zone
{
    id moment = [[[self class] allocWithZone:zone] initWithTitle:self.title
                                                         andUser:self.user
                                                      andContent:self.content
                                                         andDate:self.date
                                                       andCoords:self.coords
                                                     andComments:self.comments];
    return moment;
                 
}

@end
