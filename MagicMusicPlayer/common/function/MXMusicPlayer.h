//
//  MusicPlayer.h
//  MagicMusicPlayer
//
//  Created by antsmen on 15-1-23.
//  Copyright (c) 2015年 antsmen. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 
 音乐播放器
 
 */

typedef NS_ENUM(NSInteger, MusicPlayerState) {
    MusicPlayerStateIdle = 0,           //闲置状态
    MusicPlayerStateDownloading = 1,    //正在下载
    MusicPlayerStatePlaying = 2,        //正在播放
    MusicPlayerStatePaused = 3,         //暂停状态
};

@protocol MusicPlayerDelegate <NSObject>
@optional

- (void)musicPlayerDelegateBeginDownload;           //开始下载
- (void)musicPlayerDelegateBeginPlay;               //开始播放
- (void)musicPlayerDelegatePlaying:(float)progress; //播放进度
- (void)musicPlayerDelegatePaused;                  //暂停了播放
- (void)musicPlayerDelegateStopped;                 //中止了播放
- (void)musicPlayerDelegateFinished;                //完成播放
- (void)musicPlayerDelegateErrorDidOccur;           //出错

@end

@interface MXMusicPlayer : NSObject

@property (nonatomic,assign) id<MusicPlayerDelegate>delegate;
@property (nonatomic,strong) NSURL *url;
@property (nonatomic,assign) MusicPlayerState state;
@property (nonatomic,assign) NSTimeInterval currentTime;
@property (nonatomic,assign,readonly) NSTimeInterval duration;

+ (MXMusicPlayer*)sharedInstance;

//播放音频 需要先设置url 支持本地音频和在线音频
- (void)play;

//暂停
- (void)pause;

//停止
- (void)stop;

//重置播放器
- (void)reset;

@end
