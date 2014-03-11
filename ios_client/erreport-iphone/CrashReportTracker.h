//
//  CrashReportTracker.h
//  CrittercismExampleApp
//
//  Created by Webonise on 06/01/14.
//  Copyright (c) 2014 Crittercism. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CrashReportTracker : NSObject
-(void)crashException:(NSException*)exp;
-(void)sendCrashReportToserver;
-(BOOL)postCrashReportWithPostData:(NSData*)postData;
@end
