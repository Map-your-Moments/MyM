//
//  Content.m
//  MyM
//
//  Created by Adam on 3/6/13.
//  Copyright (c) 2013 MyM Co. All rights reserved.
//

#import "Content.h"

@implementation Content
@synthesize contentType, tags, picture, text, sound, video;

/*Main constructor for the Content class */
-(id)initWithContent:(id)momentContent withType:(int)theContentType andTags:(NSMutableArray *)theTags
{
    self.picture = nil;
    self.text = nil;
    self.sound = nil;
    self.video = nil;
    
    contentType = theContentType;
    tags        = theTags;
    
    if(contentType == kTAGMOMENTTEXT){
        //Set text content
        self.text = (NSString*)momentContent;
    }
    else if(contentType == kTAGMOMENTPICTURE){
        //Set picture content
        self.picture = (UIImage*)momentContent;
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
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:picture forKey:@"picture"];
    [coder encodeObject:text forKey:@"text"];
    [coder encodeObject:sound forKey:@"sound"];
    [coder encodeObject:video forKey:@"video"];
    [coder encodeObject:[NSNumber numberWithInt:contentType] forKey:@"contentType"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    
    if(self == nil) {
        picture = [[decoder decodeObjectForKey:@"picture"] copy];
        text = [[decoder decodeObjectForKey:@"text"] copy];
        sound = [[decoder decodeObjectForKey:@"sound"] copy];
        video = [[decoder decodeObjectForKey:@"video"] copy];
        
        NSNumber *CT = [[decoder decodeObjectForKey:@"contentType"] copy];
        contentType = [CT integerValue];
    }
    
    return self;
}

@end
