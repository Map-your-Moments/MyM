//
//  AmazonClientManager.m
//  MyM
//
//  Created by Marcelo Mazzotti on 25/3/13.
//  Copyright (c) 2013 MyM Co. All rights reserved.
//

#import "AmazonClientManager.h"

@implementation AmazonClientManager

static AmazonDynamoDBClient *amazonDynamoDBClient = nil;
static AmazonSESClient *amazonSESClient = nil;

+ (AmazonDynamoDBClient *)amazonDynamoDBClient
{
    if (!amazonDynamoDBClient) {
        amazonDynamoDBClient = [[AmazonDynamoDBClient alloc] initWithCredentials:[[AmazonCredentials alloc] initWithAccessKey:@"AKIAJGZ2TYRH2WUAA2EQ" withSecretKey:@"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"]];
    }
    
    return amazonDynamoDBClient;
}

+ (AmazonSESClient *)amazonSESClient
{
    if (!amazonSESClient) {
        amazonSESClient = [[AmazonSESClient alloc] initWithAccessKey:@"AKIAIVPDVY3IKVZWZOIA" withSecretKey:@"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"];
    }
    
    return amazonSESClient;
}

@end
