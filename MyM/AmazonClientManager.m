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

+ (AmazonS3Client *)amazonS3Client
{
    if (!amazonS3Client) {
        amazonS3Client = [[AmazonS3Client alloc] initWithCredentials:[[AmazonCredentials alloc]
                                                                initWithAccessKey:@"AKIAIJ2XEGCE5J2EWSTQ"
                                                                    withSecretKey:@"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"]];
    }
    
    return amazonS3Client;
}

@end
