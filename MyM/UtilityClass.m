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
    //NSLog(@"Response:\n%@",[NSJSONSerialization JSONObjectWithData:POSTReply options:kNilOptions error:nil] );
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

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
