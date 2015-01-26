//
//  ViewController.m
//  MagicMusicPlayer
//
//  Created by antsmen on 15-1-22.
//  Copyright (c) 2015年 antsmen. All rights reserved.
//

#import "ViewController.h"
#import "MXMusicPlayer.h"

@interface ViewController ()
<MusicPlayerDelegate>
{
    
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //委托是一对一传递消息 你可能需要有多个界面同时观察播放器的状态 如果要解决这个问题 你可以尝试修改播放器 用通知解决这个问题（观察者模式）
    [MXMusicPlayer sharedInstance].delegate = self;
    [MXMusicPlayer sharedInstance].url = [NSURL URLWithString:@"http://ws.stream.qqmusic.qq.com/34892875.mp3?vkey=371D3B4D937A95278D1BBB0A9B623ABE3983BF79EDD141F318FC83D3DBD991FA&fromtag=52&guid=FA176673D45D7371C5DC68C40831BFC0"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)play:(id)sender
{
    [[MXMusicPlayer sharedInstance] play];
}

- (IBAction)pause:(id)sender
{
    [[MXMusicPlayer sharedInstance] pause];
}

- (IBAction)stop:(id)sender
{
    [[MXMusicPlayer sharedInstance] stop];
}

- (IBAction)clearAudioCache:(id)sender
{
    [[MyCommon audioManager] clear];
    [self.view showTips:@"缓存已经清空"];
}

#pragma mark - MusicPlayerDelegate
- (void)musicPlayerDelegateBeginDownload
{
    [self.view showLoadingTips:@"正在下载"];
}

- (void)musicPlayerDelegateBeginPlay
{
    [self.view hideLoadingTips];
}

- (void)musicPlayerDelegateErrorDidOccur
{
    [self.view hideLoadingTips];
    [self.view showTips:@"好像哪里出错了"];
}

@end
