//
//  Content.m
//  MyM
//
//  Created by Adam on 3/6/13.
//  Copyright (c) 2013 MyM Co. All rights reserved.
//

#import "Content.h"

@implementation Content
@synthesize contentType;
@synthesize content;
@synthesize tags;
//@synthesize contentType, tags, picture, text, sound, video, content;

/*Main constructor for the Content class */
-(id)initWithContent:(NSData*)momentContent withType:(int)theContentType andTags:(NSMutableArray *)theTags
{
    //picture = nil;
    //text = nil;
    //sound = nil;
    //video = nil;
    
    content = momentContent;
    contentType = theContentType;
    tags        = theTags;
    
    
    /*if(contentType == kTAGMOMENTTEXT){
        //Set text content
        text = (NSString*)momentContent;
        content = text;
    }
    else if(contentType == kTAGMOMENTPICTURE){
        //Set picture content
        self.picture = (UIImage*)momentContent;
        content = picture;
    }
    else if(contentType == kTAGMOMENTVIDEO){
        //Set video content
        //self.video = (NSString*)momentContent;
        NSLog(@"Still need implemention");
    }
    else if(contentType == kTAGMOMENTAUDIO){
        //Set audio
        //self.sound = (NSString*)momentContent;
        NSLog(@"Still need implementation");
    }*/
    
    
    return self;
}

#pragma mark - NSCoding Protocol

- (void)encodeWithCoder:(NSCoder *)coder
{
    //[coder encodeObject:picture forKey:@"picture"];
    //[coder encodeObject:text forKey:@"text"];
    //[coder encodeObject:sound forKey:@"sound"];
    //[coder encodeObject:video forKey:@"video"];
    [coder encodeObject:content forKey:@"content"];
    [coder encodeObject:tags forKey:@"tags"];
    [coder encodeObject:[NSNumber numberWithInt:contentType] forKey:@"contentType"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    
    if(self == nil) {
        //picture = [[decoder decodeObjectForKey:@"picture"] copy];
        //text = [[decoder decodeObjectForKey:@"text"] copy];
        //sound = [[decoder decodeObjectForKey:@"sound"] copy];
        //video = [[decoder decodeObjectForKey:@"video"] copy];
        
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
