//
//  FriendUtilityClass.h
//  MyM
//
//  Created by Justin Wagner on 4/30/13.
//  Copyright (c) 2013 MyM Co. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FriendUtilityClass : NSObject

@property(nonatomic, copy) NSArray *friends;

+ (NSArray *)getFriends:(NSString *)token;

@end
