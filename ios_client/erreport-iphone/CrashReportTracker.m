//
//  CrashReportTracker.m
//  CrittercismExampleApp
//
//  Created by Webonise on 06/01/14.
//  Copyright (c) 2014 Crittercism. All rights reserved.
//

#import "CrashReportTracker.h"

@implementation CrashReportTracker

#define API_KEY @"15c2482432995140253cf8b5d3fdaece"
#define URL @"http://beta.erreport.io/api/v1/error_reports"
#define IPHONE5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

-(NSString*)createPrivateDirectory{
    NSString *privateDirectory = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/CrashData/"]];
    BOOL isDir =NO;
    NSFileManager *fileManager= [[NSFileManager alloc]init];
    if(![fileManager fileExistsAtPath:privateDirectory isDirectory:&isDir] && isDir ==NO){
        [fileManager createDirectoryAtPath:privateDirectory withIntermediateDirectories:NO attributes:Nil error:nil];
        [[NSUserDefaults standardUserDefaults] setValue:@"True" forKey:@"privateDirectory"];
    }
    return privateDirectory;
}

-(BOOL)isPrivateDirectoryPresent{ //check if "CrashData" privateDirecory already present
    NSString *value=[[NSUserDefaults standardUserDefaults] valueForKey:@"privateDirectory"];
    if([value isEqualToString:@"True"]){
        return YES;
    }else{
        return NO;
    }
}

-(void)sendCrashReportToserver{
    NSString *filePath=[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/CrashData/"]];
    NSError * error;
    NSArray * directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:filePath error:&error];
    NSLog(@"%@",directoryContents);
    for(int i=0; i<[directoryContents count]; i++){
        NSString *filePth=[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/CrashData/%@",[directoryContents objectAtIndex:i]]];
        NSError *error = nil;
        //take data if it presents in the file
        NSString *contents=[NSString stringWithContentsOfFile:filePth encoding:NSUTF8StringEncoding error:&error];
        NSLog(@"%@",contents);
        
        NSData *data = [contents dataUsingEncoding:NSUTF8StringEncoding];
       [self postCrashReportWithPostData:data withFilePath:filePth];
    }
}

/*
 NSFileManager *fileManager = [NSFileManager defaultManager];
 NSString *filePath=[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/CrashData/"]];
 NSError *error;
 NSArray *allFiles=[fileManager contentsOfDirectoryAtPath:filePath error:&error];
 if(allFiles !=nil){
 for(NSString *path in allFiles){
 NSString *filePth=[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/CrashData/%@",path]];
 */


-(void)deleteFileWithPath:(NSString*)path{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    BOOL success= [fileManager removeItemAtPath:path error:&error];
    if(success){
        NSLog(@"older crash report files are deleted");
    }else{
        NSLog(@"Could not deleted file -:%@", [error localizedDescription]);
    }
}


-(void)deleteFiles{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath=[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/CrashData/"]];
    NSError *error;
    NSArray *allFiles=[fileManager contentsOfDirectoryAtPath:filePath error:&error];
    if(allFiles !=nil){
        for(NSString *path in allFiles){
            NSString *filePth=[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/CrashData/%@",path]];
            BOOL success= [fileManager removeItemAtPath:filePth error:&error];
            if(success){
                NSLog(@"older crash report files are deleted");
            }else{
                NSLog(@"Could not deleted file -:%@", [error localizedDescription]);
            }
        }
        
    }
    
    
}

//this will be called once crashed, send the report synchronously
-(BOOL)postCrashReportWithPostData:(NSData*)postData{
    BOOL isSuccess=false;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:[NSString stringWithFormat:@"%d", postData.length] forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    [request setTimeoutInterval:15];
    
    NSURLResponse *resp;
    NSError *error;
    NSData *data=[NSURLConnection sendSynchronousRequest:request returningResponse:&resp error:&error];
    NSDictionary *result=[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSString *str=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"this is the str response after hitting the server--->%@",str);
    NSLog(@"this is the response after hitting the server--->%@",result);
    NSLog(@"response %@",[result valueForKey:@"status"]);
    isSuccess =[[result valueForKey:@"status"] boolValue];
    return isSuccess;
}

//this will be called when app opens , asynchronously which doesn't effect on user experience
-(void)postCrashReportWithPostData:(NSData*)postData withFilePath:(NSString*)filePth{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:[NSString stringWithFormat:@"%d", postData.length] forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    [request setTimeoutInterval:15];
    //NSLog(@"Post data : %@",[[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding]);
    //NSLog(@"post data new  :%@",postData);
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                               
                               //NSLog(@"Data:--> %@ ",data);
                               if(!error){
                                   NSDictionary *result=[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                   NSLog(@"result: %@",result);
                                   if([[result valueForKey:@"status"] boolValue]){  // use filter here , if responce' success key is true
                                       [self deleteFileWithPath:filePth];
                                   }
                               }
                           }];
    
    
}


//call this mathod while handling catch block in "main" method it will take all 
-(void)crashException:(NSException*)exp{
    //Code to hit api after crash.
    if(![self isPrivateDirectoryPresent]){
        [self createPrivateDirectory];
    }
    NSDictionary *finalparameter=[self dataForCrashReportWithException:exp];
    NSError *err;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:finalparameter options:0 error:&err];
    if(![AppStatus isPing]){ //check net is offline
        [self writeIntoFileWithData:postData];
    }else{
        if([self postCrashReportWithPostData:postData]){ //post report dirctly to server if online
            NSLog(@"crash Report is uploaded to server");
        }else{ //meanwhile something went wrong while sending report , write into file
            [self writeIntoFileWithData:postData];
        }
    }
}

- (void)writeIntoFileWithData:(NSData*)postData{
    //convert into json string
    NSString *jsonString = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    NSLog(@"this is jsonstrig--->%@",jsonString);
    
    NSDateFormatter *df =[[NSDateFormatter alloc]init];
    [df setDateFormat:@"dd-MMM-yyyy-hh-mm-ss"];
    NSString *dateSuffix = [df stringFromDate:[NSDate date]];
    NSLog(@"timeStamp used for suffix: %@",dateSuffix);
    
    //write jsonString report into file
    NSString *fileName =[[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"] stringByAppendingString:[NSString stringWithFormat:@"_%@",dateSuffix]];
    NSString *filePath=[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/CrashData/%@.txt",fileName]];
    [jsonString writeToFile:filePath atomically:YES encoding:NSStringEncodingConversionAllowLossy error:nil];
}

- (NSDictionary*)dataForCrashReportWithException:(NSException*)exp{
    NSString *description  = [NSString stringWithFormat:@"%@",exp.description];
    NSLog(@"exception description :-->%@",description);
    NSString *reason = exp.reason;
    NSLog(@"parameter reason  :-->%@",reason);
    NSString *UDID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSLog(@"UDID od the Deveice :--> %@",UDID);
    NSString *osVersion = [[UIDevice currentDevice] systemVersion];
    NSLog(@"OS Version :-->%@",osVersion);
    NSString *devicemodel = [[UIDevice currentDevice] model];
    NSLog(@"Model of Device :-->%@",devicemodel);
    NSString *devicename = [[UIDevice currentDevice] name];
    NSLog(@"Device Name :-->%@",devicename);
    
    NSString *device;
    if(IPHONE5) {
        NSLog(@"iphone5");
        device = @"iphone 4 inch";
    } else {
        NSLog(@"iphone 4");
        device = @"iphone 3.5 inch";
    }
    
    NSString *dt=[NSDateFormatter localizedStringFromDate:[NSDate date]
                                                dateStyle:NSDateFormatterLongStyle
                                                timeStyle:NSDateFormatterLongStyle];
    NSLog(@"timeStamp: %@",dt);
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:dt forKey:@"timeStamp"];
    [parameters setObject:description forKey:@"error_description"];
    [parameters setObject:reason forKey:@"error_reason"];
    [parameters setObject:device forKey:@"device_type"];
    [parameters setObject:osVersion forKey:@"os_version"];
    NSDictionary *finalparameter = [[NSDictionary alloc] initWithObjectsAndKeys: parameters,@"error",API_KEY,@"api_key" ,nil];
    
    return finalparameter;
}

@end
