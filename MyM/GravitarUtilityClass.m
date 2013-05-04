//
//  GravitarUtilityClass.m
//  MyM
//
//  Created by Adam on 5/3/13.
//  Copyright (c) 2013 MyM Co. All rights reserved.
//

#import "GravitarUtilityClass.h"
#import "NSString+MD5.h"
#import "FriendUtilityClass.h"


@implementation GravitarUtilityClass

+ (UIImage *)gravitarImageForUser:(NSString *)user
{
    NSString *email = [FriendUtilityClass getEmailFromUsername:user];
    NSURL *gravitarURL = [self getGravatarURL:email];
    NSData *gravitarData = [self requestGravatar:gravitarURL];
    return [UIImage imageWithData:gravitarData];
}

+ (NSURL*) getGravatarURL:(NSString*) emailAddress
{
	NSString *curatedEmail = [[emailAddress stringByTrimmingCharactersInSet:
							   [NSCharacterSet whitespaceCharacterSet]]
							  lowercaseString];
	
	NSString *gravatarEndPoint = [NSString stringWithFormat:@"http://www.gravatar.com/avatar/%@?s=80&d=https%%3A%%2F%%2Fs3.amazonaws.com%%2Fmym-csc470%%2FDefaultProfilePic@2x.png", [curatedEmail MD5]];
	
	return [NSURL URLWithString:gravatarEndPoint];
}

+ (NSData *) requestGravatar:(NSURL*) gravatarURL
{
	NSError *error;
	NSData* data = [[NSData alloc] initWithContentsOfURL:gravatarURL
												 options:NSDataReadingUncached error:&error];
    return data ? data : nil;
}

@end
