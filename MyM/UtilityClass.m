/*
 * MyM: Map Your Moments "A Digital Travelogue"
 *
 * Developed using iOS and AWS for CSC Special Topics: Cloud Computing, Spring 2013 by
 * Adam Cumiskey, Dave Hand, Tim Honeywell, Marcelo Mazzotti, Justin Wagner, and Steven Zilberberg
 *
 * UtilityClass.m
 * Helper class which defines functions to send requests to the server and to resize images.
 */

#import "UtilityClass.h"
#import "NSString+MD5.h"

@implementation UtilityClass

//Sends a request to the specified address and returns a JSON String response
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

//Sends a request to the specified address and returns an array of JSON strings as a response
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

//Resizes a UIImage
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
