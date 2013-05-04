//
//  GravitarUtilityClass.h
//  MyM
//
//  Created by Adam on 5/3/13.
//  Copyright (c) 2013 MyM Co. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GravitarUtilityClass : NSObject

+ (UIImage *)gravitarImageForUser:(NSString *)user;

+ (NSURL*) getGravatarURL:(NSString*) emailAddress;
+ (NSData *) requestGravatar:(NSURL*) gravatarURL;

@end
