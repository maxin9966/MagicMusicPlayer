//
//  Music.h
//  MagicMusicPlayer
//
//  Created by antsmen on 15-1-26.
//  Copyright (c) 2015年 antsmen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Music : NSObject

@property (nonatomic,strong) NSString *_id;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSURL *url;

@end
