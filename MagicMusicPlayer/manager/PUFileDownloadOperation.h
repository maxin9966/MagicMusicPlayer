//
//  PUFileDownloadOperation.h
//  Pickup
//
//  Created by MA on 14-9-26.
//  Copyright (c) 2014年 nsxiu. All rights reserved.
//

#import "AFHTTPRequestOperation.h"

@interface PUFileDownloadOperation : NSObject

@property (nonatomic,strong) AFHTTPRequestOperation *httpOperation;

@property (nonatomic,assign) BOOL isCancelled;

- (void)cancel;

@end
