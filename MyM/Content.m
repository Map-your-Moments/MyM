/*
 * MyM: Map Your Moments "A Digital Travelogue"
 *
 * Developed using iOS and AWS for CSC Special Topics: Cloud Computing, Spring 2013 by
 * Adam Cumiskey, Dave Hand, Tim Honeywell, Marcelo Mazzotti, Justin Wagner, and Steven Zilberberg
 *
 * Content.m
 * Class for content
 *
 */

#import "Content.h"

@implementation Content
@synthesize contentType;
@synthesize content;
@synthesize tags;

/*Main constructor for the Content class */
-(id)initWithContent:(NSData*)momentContent withType:(int)theContentType andTags:(NSMutableArray *)theTags
{
    
    content = momentContent;
    contentType = theContentType;
    tags        = theTags;
    
    return self;
}

#pragma mark - NSCoding Protocol

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:content forKey:@"content"];
    [coder encodeObject:tags forKey:@"tags"];
    [coder encodeObject:[NSNumber numberWithInt:contentType] forKey:@"contentType"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    
    if(self) {
        content = [[decoder decodeObjectForKey:@"content"]copy];
        tags = [[decoder decodeObjectForKey:@"tags"]copy];
        
        NSNumber *CT = [[decoder decodeObjectForKey:@"contentType"] copy];
        contentType = [CT integerValue];
    }
    
    return self;
}

#pragma mark - NSCopying Protocol

- (id)copyWithZone:(NSZone *)zone
{
    id contentCopy = [[[self class] allocWithZone:zone] initWithContent:self.content
                                                           withType:self.contentType
                                                            andTags:self.tags];
    return contentCopy;
}

@end
