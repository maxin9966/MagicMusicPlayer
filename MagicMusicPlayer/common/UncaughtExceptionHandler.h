//
//  UncaughtExceptionHandler.h
//
//  Created by ma on 14-6-3.
//  Copyright (c) 2014年 ma. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 
 crash日志
 
 */

#define kCrashLog @"CrashLog"

@interface UncaughtExceptionHandler : NSObject{
	BOOL dismissed;
}

@end
void HandleException(NSException *exception);
void SignalHandler(int signal);


void InstallUncaughtExceptionHandler(void);
