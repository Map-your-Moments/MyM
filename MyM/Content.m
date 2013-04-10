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

@end
