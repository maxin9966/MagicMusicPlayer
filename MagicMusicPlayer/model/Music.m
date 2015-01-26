//
//  Music.m
//  MagicMusicPlayer
//
//  Created by antsmen on 15-1-26.
//  Copyright (c) 2015年 antsmen. All rights reserved.
//

#import "Music.h"

@implementation Music

- (id)init
{
    if(self = [super init]){
        self._id = [MyCommon createUUID];
    }
    return self;
}

@end
