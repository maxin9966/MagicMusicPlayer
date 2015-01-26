//
//  AFFileLoad.m
//  FansKit
//
//  Created by MA on 14/12/12.
//  Copyright (c) 2014年 antsmen. All rights reserved.
//

#import "AFFileLoad.h"

@implementation AFFileLoad

+ (instancetype)sharedInstance {
    static AFFileLoad* sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[AFFileLoad alloc] init];
        [sharedManager.operationQueue setMaxConcurrentOperationCount:4];
    });
    return sharedManager;
}

//下载
+ (AFHTTPRequestOperation *)downloadWithUrl:(NSURL*)url
                                   progress:(void (^)(CGFloat progress))progress
                                 completion:(void (^)(NSData *data,NSError *error))block
{
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation=[[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        block(responseObject,nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        block(nil,error);
    }];
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        float progressNo = ((float)totalBytesRead) / totalBytesExpectedToRead;
        if (progress) {
            progress(progressNo);
        }
    }];
    
    [[AFFileLoad sharedInstance].operationQueue addOperation:operation];
    return operation;
}

@end
