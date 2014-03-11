//
//  APICall.m
//  CrittercismExampleApp
//
//  Created by Mac-1 on 30/12/13.
//  Copyright (c) 2013 Crittercism. All rights reserved.
//

#import "APICall.h"

@implementation APICall
@synthesize _responseData;


- (void)callTheAPIWithURL:(NSString*)url AndWithURLParameters :(NSDictionary *)parameters {
    
//    NSMutableURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
//           // Specify that it will be a POST request
//    request.HTTPMethod = @"POST";
//    [request setValue:parameters forKey:@"Parameters"];
//        // This is how we set header fields
//    [request setValue:@"application/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
//    
//        // Convert your data and set your request's HTTPBody property
//         NSString *stringData = @"some data";
//    NSData *requestBodyData = [stringData dataUsingEncoding:NSUTF8StringEncoding];
//    request.HTTPBody = requestBodyData;
//    
//        // Create url connection and fire request
//    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
//    if (conn) {
//        self._responseData = [[NSMutableData data] retain];
//        
//    } else {
//        
//            // Inform the user that the connection failed.
//        
//		UIAlertView *connectFailMessage = [[UIAlertView alloc] initWithTitle:@"NSURLConnection " message:@"Failed in viewDidLoad"  delegate: self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
//		[connectFailMessage show];
//		[connectFailMessage release];
//        
//    }
//
    NSData *postData = [self encodeDictionary:parameters];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setValue:[NSString stringWithFormat:@"%d", postData.length] forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    NSURLResponse *resp;
    NSError *error;
    NSData *data=[NSURLConnection sendSynchronousRequest:request returningResponse:&resp error:&error];
    NSString *str=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        // NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    

}

- (NSData*)encodeDictionary:(NSDictionary*)dictionary {
    NSMutableArray *parts = [[NSMutableArray alloc] init];
    for (NSString *key in dictionary) {
        NSString *encodedValue = [[dictionary objectForKey:key] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *encodedKey = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *part = [NSString stringWithFormat: @"%@=%@", encodedKey, encodedValue];
        [parts addObject:part];
    }
    NSString *encodedDictionary = [parts componentsJoinedByString:@"&"];
    return [encodedDictionary dataUsingEncoding:NSUTF8StringEncoding];
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
        // A response has been received, this is where we initialize the instance var you created
        // so that we can append data to it in the didReceiveData method
        // Furthermore, this method is called each time there is a redirect so reinitializing it
        // also serves to clear it
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
        // Append the new data to the instance variable you declared
    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
        // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
        // The request is complete and data has been received
        // You can parse the stuff in your instance variable now
    
   
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
        // The request has failed for some reason!
        // Check the error var
}
@end
