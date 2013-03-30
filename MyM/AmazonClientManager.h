//
//  AmazonClientManager.h
//  MyM
//
//  Created by Marcelo Mazzotti on 25/3/13.
//  Copyright (c) 2013 MyM Co. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AWSiOSSDK/DynamoDB/AmazonDynamoDBClient.h>
#import <AWSiOSSDK/SES/AmazonSESClient.h>

@interface AmazonClientManager : NSObject

+ (AmazonDynamoDBClient *)amazonDynamoDBClient;

+ (AmazonSESClient *)amazonSESClient;

@end
