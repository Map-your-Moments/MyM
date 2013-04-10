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

@property (nonatomic) id content;
@property (nonatomic) int contentType;

@property (nonatomic) NSMutableArray *tags;

-(id)initWithContentType:(int)theContentType andTags:(NSMutableArray *)theTags;

@end
