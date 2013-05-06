/*
 * MyM: Map Your Moments "A Digital Travelogue"
 *
 * Developed using iOS and AWS for CSC Special Topics: Cloud Computing, Spring 2013 by
 * Adam Cumiskey, Dave Hand, Tim Honeywell, Marcelo Mazzotti, Justin Wagner, and Steven Zilberberg
 *
 * AmazonClientManager.h
 * 
 *
 */

#import <Foundation/Foundation.h>
#import <AWSiOSSDK/DynamoDB/AmazonDynamoDBClient.h>
#import <AWSiOSSDK/SES/AmazonSESClient.h>
#import <AWSiOSSDK/S3/AmazonS3Client.h>

@interface AmazonClientManager : NSObject

+ (AmazonDynamoDBClient *)amazonDynamoDBClient;

+ (AmazonSESClient *)amazonSESClient;

+ (AmazonS3Client *)amazonS3Client;

@end
