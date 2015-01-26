//
//  PUFileDownloadOperation.m
//  Pickup
//
//  Created by MA on 14-9-26.
//  Copyright (c) 2014年 nsxiu. All rights reserved.
//

#import "PUFileDownloadOperation.h"

@implementation PUFileDownloadOperation
@synthesize httpOperation,isCancelled;

- (void)cancel
{
    isCancelled = YES;
    if(httpOperation){
        [httpOperation cancel];
    }
}

@end
