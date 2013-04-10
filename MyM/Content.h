//
//  Content.h
//  MyM
//
//  Created by Adam on 3/6/13.
//  Copyright (c) 2013 MyM Co. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@interface Content : NSObject

@property (nonatomic) UIImage *picture;
@property (nonatomic) NSString *text;
@property (nonatomic) id sound;
@property (nonatomic) id video;
@property (nonatomic) int contentType;

@property (nonatomic) NSMutableArray *tags;

-(id)initWithContent:(id)momentContent withType:(int)theContentType andTags:(NSMutableArray *)theTags;

@end
