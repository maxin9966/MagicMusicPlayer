//
//  UncaughtExceptionHandler.m
//
//  Created by ma on 14-6-3.
//  Copyright (c) 2014年 ma. All rights reserved.
//

#import "UncaughtExceptionHandler.h"
#include <libkern/OSAtomic.h>
#include <execinfo.h>

NSString * const UncaughtExceptionHandlerSignalExceptionName = @"UncaughtExceptionHandlerSignalExceptionName";
NSString * const UncaughtExceptionHandlerSignalKey = @"UncaughtExceptionHandlerSignalKey";
NSString * const UncaughtExceptionHandlerAddressesKey = @"UncaughtExceptionHandlerAddressesKey";

volatile int32_t UncaughtExceptionCount = 0;
const int32_t UncaughtExceptionMaximum = 10;

const NSInteger UncaughtExceptionHandlerSkipAddressCount = 4;
const NSInteger UncaughtExceptionHandlerReportAddressCount = 5;

@implementation UncaughtExceptionHandler

+ (NSArray *)backtrace
{
	 void* callstack[128];
	 int frames = backtrace(callstack, 128);
	 char **strs = backtrace_symbols(callstack, frames);
	 
	 int i;
	 NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
	 for (
	 	i = UncaughtExceptionHandlerSkipAddressCount;
	 	i < UncaughtExceptionHandlerSkipAddressCount +
			UncaughtExceptionHandlerReportAddressCount;
		i++)
	 {
	 	[backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
	 }
	 free(strs);
	 
	 return backtrace;
}

- (void)alertView:(UIAlertView *)anAlertView clickedButtonAtIndex:(NSInteger)anIndex
{
	if (anIndex == 0)
	{
		dismissed = YES;
	}
}

- (void)showTips
{
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    for(UIWindow *window in [UIApplication sharedApplication].windows){
        [window endEditing:YES];
    }
    [[MyCommon normalLevelWindow] showTips:@"程序检测到异常状况，即将退出。" duration:4.0 copletionBlock:^{
        [self exit];
    }];
    //某些情况下无法显示UI
    [self performSelector:@selector(exit) withObject:self afterDelay:5.0];
}

- (void)validateAndSaveCriticalApplicationData
{
    
}

- (void)exit
{
    dismissed = YES;
}

- (void)showReason:(NSException *)exception
{
    NSArray *ncallStackSymbolArray = [exception callStackSymbols];
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    NSString *crashLogString = [NSString stringWithFormat:@"name:%@\nreason:\n%@\ncallStackSymbols:\n%@",name,reason,[ncallStackSymbolArray componentsJoinedByString:@"/n"]];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"CRASH日志" message:crashLogString delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)handleException:(NSException *)exception
{
	[self validateAndSaveCriticalApplicationData];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        [self uploadCrashLog:exception];
//    });
    
#ifndef __OPTIMIZE__
    [self showReason:exception];
#else
    [self showTips];
#endif
	
	CFRunLoopRef runLoop = CFRunLoopGetCurrent();
	CFArrayRef allModes = CFRunLoopCopyAllModes(runLoop);
	
	while (!dismissed){
		for (NSString *mode in (__bridge NSArray *)allModes){
			CFRunLoopRunInMode((__bridge CFStringRef)mode, 0.005, false);
		}
	}
	
	CFRelease(allModes);

	NSSetUncaughtExceptionHandler(NULL);
	signal(SIGABRT, SIG_DFL);
	signal(SIGILL, SIG_DFL);
	signal(SIGSEGV, SIG_DFL);
	signal(SIGFPE, SIG_DFL);
	signal(SIGBUS, SIG_DFL);
	signal(SIGPIPE, SIG_DFL);
	
	if ([[exception name] isEqual:UncaughtExceptionHandlerSignalExceptionName])
	{
		kill(getpid(), [[[exception userInfo] objectForKey:UncaughtExceptionHandlerSignalKey] intValue]);
	}
	else
	{
		[exception raise];
	}
}

//上传crash日志
//- (void)uploadCrashLog:(NSException *)exception
//{
//    NSArray *ncallStackSymbolArray = [exception callStackSymbols];
//    NSString *reason = [exception reason];
//    NSString *name = [exception name];
//    
//    NSString *crashLogString = [NSString stringWithFormat:@"reason:\n%@\ncallStackSymbols:\n%@",reason,[ncallStackSymbolArray componentsJoinedByString:@"/n"]];
//    NSLog(@"________Crash %@",crashLogString);
//    
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
//    NSString *dateText = [dateFormatter stringFromDate:[NSDate date]];
//    
//    NSMutableDictionary *paramDic = [[NSMutableDictionary alloc] init];
//    [paramDic setObject:[PBRegularExpression deviceString] forKey:@"hw"];
//    NSString *verSion = VERSION;
//    [paramDic setObject:verSion forKey:@"ver"];
//    [paramDic setObject:[[UIDevice currentDevice] systemVersion] forKey:@"os_ver"];
//    [paramDic setObject:name forKey:@"e_n"];
//    [paramDic setObject:crashLogString forKey:@"ex"];
//    [paramDic setObject:dateText forKey:@"rt"];
//    
//    NSMutableDictionary *resultsDictionary =  [Request postWithJson:paramDic Method:@"crash/report"];
//    
//    NSNumber *resultStr = (NSNumber *)[resultsDictionary valueForKey:@"result"];
//    if (resultStr && [[resultStr stringValue] isEqualToString:@"0"]){
//        NSLog(@"完成");
//    }
//}

@end

void HandleException(NSException *exception)
{
	int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
	if (exceptionCount > UncaughtExceptionMaximum)
	{
		return;
	}
	
	NSArray *callStack = [UncaughtExceptionHandler backtrace];
	NSMutableDictionary *userInfo =
		[NSMutableDictionary dictionaryWithDictionary:[exception userInfo]];
	[userInfo
		setObject:callStack
		forKey:UncaughtExceptionHandlerAddressesKey];
	
	[[[UncaughtExceptionHandler alloc] init]
		performSelectorOnMainThread:@selector(handleException:)
		withObject:
			[NSException
				exceptionWithName:[exception name]
				reason:[exception reason]
				userInfo:userInfo]
		waitUntilDone:YES];
}

void SignalHandler(int signal)
{
	int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
	if (exceptionCount > UncaughtExceptionMaximum)
	{
		return;
	}
	
	NSMutableDictionary *userInfo =
		[NSMutableDictionary
			dictionaryWithObject:[NSNumber numberWithInt:signal]
			forKey:UncaughtExceptionHandlerSignalKey];

	NSArray *callStack = [UncaughtExceptionHandler backtrace];
	[userInfo
		setObject:callStack
		forKey:UncaughtExceptionHandlerAddressesKey];
	
	[[[UncaughtExceptionHandler alloc] init]
		performSelectorOnMainThread:@selector(handleException:)
		withObject:
			[NSException
				exceptionWithName:UncaughtExceptionHandlerSignalExceptionName
				reason:
					[NSString stringWithFormat:
						NSLocalizedString(@"Signal %d was raised.", nil),
						signal]
				userInfo:
					[NSDictionary
						dictionaryWithObject:[NSNumber numberWithInt:signal]
						forKey:UncaughtExceptionHandlerSignalKey]]
		waitUntilDone:YES];
}

void InstallUncaughtExceptionHandler(void)
{
	NSSetUncaughtExceptionHandler(&HandleException);
	signal(SIGABRT, SignalHandler);
	signal(SIGILL, SignalHandler);
	signal(SIGSEGV, SignalHandler);
	signal(SIGFPE, SignalHandler);
	signal(SIGBUS, SignalHandler);
	signal(SIGPIPE, SignalHandler);
}

