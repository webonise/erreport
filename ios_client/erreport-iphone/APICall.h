//
//  APICall.h
//  CrittercismExampleApp
//
//  Created by Mac-1 on 30/12/13.
//  Copyright (c) 2013 Crittercism. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APICall : NSObject <NSURLConnectionDelegate>

@property (nonatomic, retain) NSMutableData *_responseData;

- (void)callTheAPIWithURL:(NSString*)url AndWithURLParameters :(NSDictionary *)parameters;
- (NSData*)encodeDictionary:(NSDictionary*)dictionary;
@end
