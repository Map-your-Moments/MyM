//
//  Content.m
//  MyM
//
//  Created by Adam on 3/6/13.
//  Copyright (c) 2013 MyM Co. All rights reserved.
//

#import "Content.h"

@implementation Content
@synthesize contentType, tags, icon;

/*Main constructor for the Content class */
-(id)initWithContentType:(NSString *)theContentType andTags:(NSMutableArray *)theTags andIcon:(UIImage *)theIcon
{
    contentType = theContentType;
    tags        = theTags;
    icon        = theIcon;
    
    return self;
}

@end
