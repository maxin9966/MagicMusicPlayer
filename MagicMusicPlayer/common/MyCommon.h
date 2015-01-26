//
//  MyCommon.h
//  FansKit
//
//  Created by MA on 14/12/1.
//  Copyright (c) 2014年 antsmen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XLoader.h"
#import "UIView+HUD.h"
#import "PUAudioManager.h"

/**
 
 common
 
 */

//屏蔽NSLog
//#ifndef __OPTIMIZE__
//#define NSLog(...) NSLog(__VA_ARGS__)
//#else
//#define NSLog(...) {}
//#endif


/**
 宏定义
 */
//获取系统版本号
#define SystemVersion [[[UIDevice currentDevice] systemVersion] floatValue]
//屏幕宽高
#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define SCREEN_SCALE  [UIScreen mainScreen].scale
//RGBA
#define RGBA(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:a]
//角度
#define DEGREES_TO_RADIANS(degrees)((M_PI * degrees)/180)
//是否为iPhone5以上的长屏
#define isIphone5 ([[UIScreen mainScreen] bounds].size.height>480)
//项目版本号
#define VERSION [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]


@interface MyCommon : NSObject

//音频管理器
+ (PUAudioManager*)audioManager;

//save userDefault
+ (BOOL)saveDataToUserDefault:(id)data WithKey:(NSString *)key;

//get userDefault
+ (id)getDataFromUserDefaultWithKey:(NSString *)key;

//remove userDefault
+ (BOOL)removeDataFromUserDefaultWithKey:(NSString *)key;

//电话正则
+ (BOOL)isMobile:(NSString *)mobileNumber;

//邮箱匹配
+ (BOOL)isEmail:(NSString *)email;

//获取一个新的UUID
+ (NSString *)createUUID;

//获取纯色图片
+ (UIImage *)imageWithColor:(UIColor *)color;

//关闭键盘
+ (void)closeKeyboard;

//获取normal level window
+ (UIWindow*)normalLevelWindow;

//动画类型
+ (UIViewAnimationOptions)animationOptionsForCurve:(UIViewAnimationCurve)curve;

@end
