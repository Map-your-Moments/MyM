//
//  Content.m
//  MyM
//
//  Created by Adam on 3/6/13.
//  Copyright (c) 2013 MyM Co. All rights reserved.
//

#import "Content.h"

@implementation Content
@synthesize contentType, tags, icon, content;

/*Main constructor for the Content class */
-(id)initWithContentType:(int)theContentType andTags:(NSMutableArray *)theTags
{
    contentType = theContentType;
    tags        = theTags;
    
    if(contentType == kTAGMOMENTTEXT){
        //Set text content
    }
    else if(contentType == kTAGMOMENTPICTURE){
        //Set picture content
    }
    else if(contentType == kTAGMOMENTVIDEO){
        //Set video content
    }
    else if(contentType == kTAGMOMENTAUDIO){
        //Set audio
    }
    
    return self;
}

@end
