//
//  UtilityClass.m
//  MyM
//
//  Created by Marcelo Mazzotti on 18/4/13.
//  Copyright (c) 2013 MyM Co. All rights reserved.
//

#import "UtilityClass.h"
#import "NSString+MD5.h"

@implementation UtilityClass

+ (NSURL*) getGravatarURL:(NSString*) emailAddress
{
	NSString *curatedEmail = [[emailAddress stringByTrimmingCharactersInSet:
							   [NSCharacterSet whitespaceCharacterSet]]
							  lowercaseString];
	
	NSString *gravatarEndPoint = [NSString stringWithFormat:@"http://www.gravatar.com/avatar/%@?s=80", [curatedEmail MD5]];
	
	return [NSURL URLWithString:gravatarEndPoint];
}

+ (NSData *) requestGravatar:(NSURL*) gravatarURL
{
	NSError *error;
	NSData* data = [[NSData alloc] initWithContentsOfURL:gravatarURL
												 options:NSDataReadingUncached error:&error];
    return data ? data : nil;
}

+ (NSDictionary *)SendJSON:(NSDictionary *)jsonDictionary toAddress:(NSString *)address
{
    NSData *postData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:kNilOptions error:nil];
    //    NSData *postData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:address]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSURLResponse *response;
    NSData *POSTReply = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    NSDictionary *jsonresponse = POSTReply ? [NSJSONSerialization JSONObjectWithData:POSTReply options:kNilOptions error:nil] : nil;
    
    return jsonresponse;
}

+ (NSDictionary *)GetFriendsJSON:(NSOutputStream *)fileStream fromAddress:(NSString *)address
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:address]];
    [request setHTTPMethod:@"GET"];
    
    NSURLResponse *response;
    NSData *GETReply = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    NSLog(@"%@",[NSJSONSerialization JSONObjectWithData:GETReply options:kNilOptions error:nil] );
    NSDictionary *jsonresponse = GETReply ? [NSJSONSerialization JSONObjectWithData:GETReply options:kNilOptions error:nil] : nil;
    
//    NSInteger       dataLength;
//    const uint8_t * dataBytes;
//    NSInteger       bytesWritten;
//    NSInteger       bytesWrittenSoFar;
//    
//    dataLength = [GETReply length];
//    dataBytes  = [GETReply bytes];
//    
//    bytesWrittenSoFar = 0;
//    do {
//        bytesWritten = [fileStream write:&dataBytes[bytesWrittenSoFar] maxLength:dataLength - bytesWrittenSoFar];
//        assert(bytesWritten != 0);
//        if (bytesWritten == -1) {
//            NSLog(@"Friends List file write error.");
//            break;
//        } else {
//            bytesWrittenSoFar += bytesWritten;
//        }
//    } while (bytesWrittenSoFar != dataLength);
//    
    return jsonresponse;
    
}

@end
