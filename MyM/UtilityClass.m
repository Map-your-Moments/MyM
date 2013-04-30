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

+ (NSArray *)GetFriendsJSON:(NSDictionary *)jsonDictionary toAddress:(NSString *)address
{
    NSData *postData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:kNilOptions error:nil];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:address]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSURLResponse *response;
    NSData *POSTReply = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
//    NSLog(@"Response:\n%@",[NSJSONSerialization JSONObjectWithData:POSTReply options:kNilOptions error:nil] );
    NSArray *jsonresponse = POSTReply ? [NSJSONSerialization JSONObjectWithData:POSTReply options:kNilOptions error:nil] : nil;
    
    return jsonresponse;
}

@end
