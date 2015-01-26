//
//  AFRequest.m
//  FansKit
//
//  Created by MA on 14/12/4.
//  Copyright (c) 2014年 antsmen. All rights reserved.
//

#import "AFHttpRequest.h"

#define ServerBaseURL @""

@implementation AFHttpRequest

+ (instancetype)sharedInstance {
    static AFHttpRequest* sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] initWithBaseURL:[NSURL URLWithString:ServerBaseURL]];
        [sharedManager.operationQueue setMaxConcurrentOperationCount:8];
    });
    return sharedManager;
}

+ (AFHTTPRequestOperation *)getWithAPI:(NSString*)api
        parameters:(NSDictionary*)params
           success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSLog(@"GET %@\n%@",api,params);
    AFHTTPRequestOperation *operation = [[self sharedInstance] GET:api parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"RESULT %@\n%@",api,responseObject);
        if(success){
            success(operation,responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure){
            failure(operation,error);
        }
    }];
    return operation;
}

+ (AFHTTPRequestOperation *)postWithAPI:(NSString*)api
         parameters:(NSDictionary*)params
            success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSLog(@"POST %@\n%@",api,params);
    AFHTTPRequestOperation *operation = [[self sharedInstance] POST:api parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"RESULT %@\n%@",api,responseObject);
        if(success){
            success(operation,responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure){
            failure(operation,error);
        }
    }];
    return operation;
}

@end
