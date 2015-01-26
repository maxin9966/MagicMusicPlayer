//
//  UIView+HUD.m
//  FansKit
//
//  Created by antsmen on 15-1-7.
//  Copyright (c) 2015年 antsmen. All rights reserved.
//

#import "UIView+HUD.h"
#import <objc/runtime.h>

static const void *hudLoadingTipsKey = &hudLoadingTipsKey;
static const void *hudTipsKey = &hudTipsKey;
static const void *hudDoneTipsKey = &hudDoneTipsKey;

@implementation UIView (HUD)

- (MBProgressHUD *)loadingView
{
    return objc_getAssociatedObject(self, hudLoadingTipsKey);
}

- (void)setLoadingView:(MBProgressHUD *)HUD
{
    objc_setAssociatedObject(self, hudLoadingTipsKey, HUD, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MBProgressHUD *)tipsView
{
    return objc_getAssociatedObject(self, hudTipsKey);
}

- (void)setTipsView:(MBProgressHUD *)HUD
{
    objc_setAssociatedObject(self, hudTipsKey, HUD, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MBProgressHUD *)doneTipsView
{
    return objc_getAssociatedObject(self, hudDoneTipsKey);
}

- (void)setDoneTipsView:(MBProgressHUD *)HUD
{
    objc_setAssociatedObject(self, hudDoneTipsKey, HUD, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - 普通提示
- (void)showTips:(NSString*)text
{
    [self showTips:text duration:1.f copletionBlock:nil];
}

- (void)showTips:(NSString*)text duration:(NSTimeInterval)interval copletionBlock:(MBProgressHUDCompletionBlock)completion
{
    MBProgressHUD *tipView = [self tipsView];
    if(!tipView){
        tipView = [[MBProgressHUD alloc] initWithView:self];
        [self addSubview:tipView];
        tipView.customView = [[UIImageView alloc] initWithImage:nil];
        tipView.mode = MBProgressHUDModeCustomView;
        [self setTipsView:tipView];
    }else{
        [tipView hide:NO];
    }
    tipView.labelText = text;
    [tipView show:YES completionBlock:completion];
    [tipView hide:YES afterDelay:interval];
}

#pragma mark - 操作完成
- (void)showDoneTips:(NSString*)text
{
    [self showDoneTips:text duration:1.f completionBlock:nil];
}

- (void)showDoneTips:(NSString*)text duration:(NSTimeInterval)interval completionBlock:(MBProgressHUDCompletionBlock)completion
{
    MBProgressHUD *tipView = [self doneTipsView];
    if(!tipView){
        tipView = [[MBProgressHUD alloc] initWithView:self];
        [self addSubview:tipView];
        tipView.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
        tipView.mode = MBProgressHUDModeCustomView;
        [self setDoneTipsView:tipView];
    }else{
        [tipView hide:NO];
    }
    tipView.labelText = text;
    [tipView show:YES completionBlock:completion];
    [tipView hide:YES afterDelay:interval];
}

#pragma mark - 正在加载
- (void)showLoadingTips:(NSString*)text
{
    MBProgressHUD *loadingView = [self loadingView];
    if(!loadingView){
        loadingView = [[MBProgressHUD alloc] initWithView:self];
        [self addSubview:loadingView];
        //loadingView.minShowTime = 0.2;
        [self setLoadingView:loadingView];
    }
    loadingView.labelText = text;
    [loadingView show:YES];
}

- (void)hideLoadingTips
{
    MBProgressHUD *loadingView = [self loadingView];
    if(loadingView){
        [loadingView hide:NO];
    }
}

#pragma mark - 
- (void)hideAllHUD
{
    [MBProgressHUD hideAllHUDsForView:self animated:NO];
}

@end
