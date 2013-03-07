//
//  Content.h
//  MyM
//
//  Created by Adam on 3/6/13.
//  Copyright (c) 2013 MyM Co. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Content : NSObject

@property (nonatomic) NSString *contentType;
@property (nonatomic) NSMutableArray *tags;
@property (nonatomic) UIImage *icon;

-(id)initWithContentType:(NSString *)theContentType andTags:(NSMutableArray *)theTags andIcon:(UIImage *)theIcon;

@end
