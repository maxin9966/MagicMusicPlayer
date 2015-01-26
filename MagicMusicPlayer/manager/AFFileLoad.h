//
//  AFFileLoad.h
//  FansKit
//
//  Created by MA on 14/12/12.
//  Copyright (c) 2014年 antsmen. All rights reserved.
//

/**
 
 文件上传下载
 
 */

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"

//downloader block
typedef void(^DownloaderProgressBlock)(CGFloat progress);
typedef void(^DownloaderCompletionBlock)(NSData *data,NSError *error);

@interface AFFileLoad : AFHTTPRequestOperationManager

//下载文件
+ (AFHTTPRequestOperation *)downloadWithUrl:(NSURL*)url
                                   progress:(void (^)(CGFloat progress))progress
                                 completion:(void (^)(NSData *data,NSError *error))block;

@end
