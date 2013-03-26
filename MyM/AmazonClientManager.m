//
//  AmazonClientManager.m
//  MyM
//
//  Created by Marcelo Mazzotti on 25/3/13.
//  Copyright (c) 2013 MyM Co. All rights reserved.
//

#import "AmazonClientManager.h"
@interface AmazonClientManager ()
+ (void)validateCredentials;
@end

@implementation AmazonClientManager

static AmazonDynamoDBClient *amazonDynamoDBClient = nil;


 +(AmazonDynamoDBClient *)amazonDynamoDBClient
{
    [self validateCredentials];
    
    return amazonDynamoDBClient;
}

+ (void)validateCredentials
{
    if (!amazonDynamoDBClient) {
        amazonDynamoDBClient = [[AmazonDynamoDBClient alloc] initWithCredentials:[[AmazonCredentials alloc] initWithAccessKey:@"AKIAJGZ2TYRH2WUAA2EQ" withSecretKey:@"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"]];
    }
}

@end
