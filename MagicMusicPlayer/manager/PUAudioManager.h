//
//  PUAudioManager.h
//  Pickup
//
//  Created by MA on 14-9-30.
//  Copyright (c) 2014年 nsxiu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PUFileDownloadOperation.h"
#import "AFFileLoad.h"

/**
 
 音频管理
 
 */

@interface PUAudioManager : NSObject

- (instancetype)initWithNamespace:(NSString*)ns;

//音频下载
- (PUFileDownloadOperation*)downloadAudioWithUrl:(NSURL*)url
                                        progress:(DownloaderProgressBlock)progressBlock
                                       completed:(DownloaderCompletionBlock)completedBlock;

//是否有缓存
- (BOOL)isExistWithUrl:(NSURL*)url;

//获取缓存
- (NSData*)getAudioWithUrl:(NSURL*)url;

//清除缓存
- (void)clear;

@end
