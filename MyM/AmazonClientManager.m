/*
 * MyM: Map Your Moments "A Digital Travelogue"
 *
 * Developed using iOS and AWS for CSC Special Topics: Cloud Computing, Spring 2013 by
 * Adam Cumiskey, Dave Hand, Tim Honeywell, Marcelo Mazzotti, Justin Wagner, and Steven Zilberberg
 *
 * AmazonClientManager.m
 * Utility class that allows us to easily make AWS calls from any class
 *
 */

#import "AmazonClientManager.h"

@implementation AmazonClientManager

static AmazonDynamoDBClient *amazonDynamoDBClient = nil;
static AmazonSESClient *amazonSESClient = nil;
static AmazonS3Client *amazonS3Client = nil;

+ (AmazonDynamoDBClient *)amazonDynamoDBClient
{
    if (!amazonDynamoDBClient) {
        amazonDynamoDBClient = [[AmazonDynamoDBClient alloc] initWithCredentials:[[AmazonCredentials alloc] initWithAccessKey:@"" withSecretKey:@""]];
    }
    
    return amazonDynamoDBClient;
}

+ (AmazonSESClient *)amazonSESClient
{
    if (!amazonSESClient) {
        amazonSESClient = [[AmazonSESClient alloc] initWithAccessKey:@"" withSecretKey:@""];
    }
    
    return amazonSESClient;
}

+ (AmazonS3Client *)amazonS3Client
{
    if (!amazonS3Client) {
        amazonS3Client = [[AmazonS3Client alloc] initWithCredentials:[[AmazonCredentials alloc]
                                                                initWithAccessKey:@""
                                                                    withSecretKey:@""]];
    }
    
    return amazonS3Client;
}

@end
