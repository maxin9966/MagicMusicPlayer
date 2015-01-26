//
//  AFRequest.h
//  FansKit
//
//  Created by MA on 14/12/4.
//  Copyright (c) 2014年 antsmen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

/**
 
 HTTP请求
 
 */

@interface AFHttpRequest : AFHTTPRequestOperationManager

+ (AFHTTPRequestOperation *)getWithAPI:(NSString*)api
        parameters:(NSDictionary*)params
           success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)postWithAPI:(NSString*)api
         parameters:(NSDictionary*)params
            success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

@end
