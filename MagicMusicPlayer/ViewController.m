//
//  ViewController.m
//  MagicMusicPlayer
//
//  Created by antsmen on 15-1-22.
//  Copyright (c) 2015年 antsmen. All rights reserved.
//

#import "ViewController.h"
#import "MXMusicPlayer.h"
#import "Music.h"

@interface ViewController ()
<MusicPlayerDelegate,UITableViewDataSource,UITableViewDelegate>
{
    IBOutlet UITableView *tableView;
    IBOutlet UISlider *slider;
    IBOutlet UIButton *playAndPauseBtn;
    NSMutableArray *urlList;
    MXMusicPlayer *musicPlayer;
    
    BOOL isTouchDown;
    
    NSInteger nowIndex;
     
    NSMutableDictionary *failedDict;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    musicPlayer = [MXMusicPlayer sharedInstance];
    
    failedDict = [NSMutableDictionary dictionary];
    
    [slider addTarget:self action:@selector(sliderValueTouchDown) forControlEvents:UIControlEventTouchDown];
    [slider addTarget:self action:@selector(sliderValueTouchUp) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel];
    
    //委托是一对一传递消息 你可能需要有多个界面同时观察播放器的状态 如果要解决这个问题 你可以尝试修改播放器 用通知解决这个问题（观察者模式）
    musicPlayer.delegate = self;
    
    urlList = [NSMutableArray array];
    Music *m1 = [Music new];
    m1.name = @"爱我别走";
    m1.url = [NSURL URLWithString:@"http://ws.stream.qqmusic.qq.com/34892875.mp3?vkey=16A2B2E99643381433DFB6CC4939A392675D16F1C4D4B697CF32AFBFBF9E698A&fromtag=52&guid=09FE2D4F3516C27A954D7456EB7AD07F"];
    Music *m2 = [Music new];
    m2.name = @"魔幻季节";
    m2.url = [NSURL URLWithString:@"http://ws.stream.qqmusic.qq.com/30499508.mp3?vkey=53B4173DDC2A55BFBFE87DE39EE59012F4FC8B73F1DD59821F970DABDA920118&fromtag=52&guid=F2CDA15D6221AC14729F24E784B822DC"];
    Music *m3 = [Music new];
    m3.name = @"该死的温柔";
    m3.url = [NSURL URLWithString:@"http://ws.stream.qqmusic.qq.com/31403026.mp3?vkey=9F7BC4D8648A2D1B7217429688BD14554EAD65A1C448A6DB1C235B937ACAA1C5&fromtag=52&guid=E4487F7CAA06297ED6C8FAAE290049F1"];
    Music *m4 = [Music new];
    m4.name = @"如果这都不算爱";
    m4.url = [NSURL URLWithString:@"http://ws.stream.qqmusic.qq.com/30262255.mp3?vkey=38A9FA1A32B146BB5D72BA1D57FBD2A49A00BF23BB4E1BC2CE35FC60F4B18D4D&fromtag=52&guid=462A0E758603E4D02A003E67086520D6"];
    Music *m5 = [Music new];
    m5.name = @"绿光";
    m5.url = [NSURL URLWithString:@"http://ws.stream.qqmusic.qq.com/30658138.mp3?vkey=92A6CD49E847DEF4D1D949C6E239B429580311E0AA26AA1689A7C9583AFADC8B&fromtag=52&guid=27CB4746D133446680B546EEB92064C9"];
    Music *m6 = [Music new];
    m6.name = @"爱在西元前";
    m6.url = [NSURL URLWithString:@"http://ws.stream.qqmusic.qq.com/30858872.mp3?vkey=7F8462D16B22A4E98D5381D70F0C93A0AEC55973446C47754FFF8DC76D757A50&fromtag=52&guid=62BC262B889069737A2A2FCE6A1108C4"];
    
    [urlList addObject:m1];
    [urlList addObject:m2];
    [urlList addObject:m3];
    [urlList addObject:m4];
    [urlList addObject:m5];
    [urlList addObject:m6];

    //观察播放器状态变更
    [RACObserve(musicPlayer, state) subscribeNext:^(NSNumber *number) {
        switch ([number integerValue]) {
            case MusicPlayerStateIdle:
            case MusicPlayerStatePaused:
                playAndPauseBtn.selected = NO;
                break;
            case MusicPlayerStateDownloading:
            case MusicPlayerStatePlaying:
                playAndPauseBtn.selected = YES;
                break;
            default:
                break;
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//进度条
- (void)sliderValueTouchDown
{
    isTouchDown = YES;
}

- (void)sliderValueTouchUp
{
    isTouchDown = NO;
    musicPlayer.currentTime = slider.value;
}

- (void)play
{
    if(nowIndex<0 || nowIndex>=urlList.count){
        return;
    }
    Music *m = [urlList objectAtIndex:nowIndex];
    if(m){
        musicPlayer.url = m.url;
        [musicPlayer play];
        [tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:nowIndex inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    }
}

- (IBAction)playAndPause:(id)sender
{
    if(playAndPauseBtn.selected){
        [musicPlayer pause];
    }else{
        [self play];
    }
}

- (IBAction)previous:(id)sender
{
    nowIndex = nowIndex-1<0?urlList.count-1:nowIndex-1;
    [self play];
}

- (IBAction)next:(id)sender
{
    nowIndex = nowIndex+1>urlList.count-1?0:nowIndex+1;
    [self play];
}

- (IBAction)clearAudioCache:(id)sender
{
    [[MyCommon audioManager] clear];
    [self.view showTips:@"缓存已经清空"];
}

#pragma mark - MusicPlayerDelegate
- (void)musicPlayerDelegateBeginDownload
{
    //[self.view showLoadingTips:@"正在下载"];
}

- (void)musicPlayerDelegateBeginPlay
{
    //[self.view hideLoadingTips];
    slider.maximumValue = musicPlayer.duration;
    slider.value = musicPlayer.currentTime;
    //取消红色失败标记
    Music *m = [urlList objectAtIndex:nowIndex];
    if(m && [failedDict objectForKey:m._id]){
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:nowIndex inSection:0]];
        if(cell){
            cell.textLabel.textColor = [UIColor blackColor];
        }
        [failedDict removeObjectForKey:m._id];
    }
}

- (void)musicPlayerDelegateErrorDidOccur
{
    //[self.view hideLoadingTips];
    //播放失败 标记为红色
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:nowIndex inSection:0]];
    if(cell){
        cell.textLabel.textColor = [UIColor redColor];
    }
    Music *m = [urlList objectAtIndex:nowIndex];
    if(m){
        [failedDict setObject:m forKey:m._id];
    }
    //检测如果全部失败 则停止播放
    if(failedDict.count < urlList.count){
        //继续播放
        [self next:nil];
    }
}

- (void)musicPlayerDelegatePlaying:(float)progress
{
    if(!isTouchDown){
        slider.value = musicPlayer.currentTime;
    }
}

- (void)musicPlayerDelegateFinished
{
    slider.value = 0;
    [self next:nil];
}

- (void)musicPlayerDelegateStopped
{
    slider.value = 0;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    return urlList.count;
}

- (UITableViewCell*)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"MusicCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.backgroundColor = [UIColor clearColor];
    }
    Music *m = [urlList objectAtIndex:indexPath.row];
    if(m){
        cell.textLabel.text = m.name;
        if([failedDict objectForKey:m._id]){
            cell.textLabel.textColor = [UIColor redColor];
        }else{
            cell.textLabel.textColor = [UIColor blackColor];
        }
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(nowIndex!=indexPath.row){
        nowIndex = indexPath.row;
        [musicPlayer reset];
        [self play];
    }else{
        [self playAndPause:nil];
    }
}

#pragma mark - remoteControl
- (void)remoteControlReceivedWithEvent: (UIEvent *) receivedEvent {
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        
        switch (receivedEvent.subtype) {
                
            case UIEventSubtypeRemoteControlTogglePlayPause:
                [self playAndPause:nil];
                break;
                
            case UIEventSubtypeRemoteControlPreviousTrack:
                [self previous:nil];
                break;
                
            case UIEventSubtypeRemoteControlNextTrack:
                [self next:nil];
                break;
                
            case UIEventSubtypeRemoteControlPlay:
                [self playAndPause:nil];
                break;
                
            case UIEventSubtypeRemoteControlPause:
                [self playAndPause:nil];
                break;
                
            default:
                break;
        }
    }
}

@end
