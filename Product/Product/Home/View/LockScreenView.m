
//
//  LockScreenView.m
//  Product
//
//  Created by zhuqinlu on 2017/6/1.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "LockScreenView.h"

@interface LockScreenView ()

@end

@implementation LockScreenView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor colorWithRed:10/255.0 green:10/255.0 blue:10/255.0 alpha:0.8];
        
        [self setLockScreenViewUI];
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES]; // 禁止锁屏
    }
    return self;
}
#pragma mark -- UI
- (void)setLockScreenViewUI{
    
    /*里程*/
    _sportsMileageLabel = InsertLabel(self, CGRectMake(10, 70 + 64 , kScreenWidth - 20, 75), NSTextAlignmentCenter, @"", kFontSize(75), [UIColor whiteColor], NO);
    
    /* 速度 */
    _movementSpeedLabel = InsertLabel(self, CGRectMake(0, _sportsMileageLabel.bottom + 35, kScreenWidth/3, 20), NSTextAlignmentCenter, @"--",kFontSize(15), [UIColor whiteColor], NO);
    InsertLabel(self, CGRectMake(0, _movementSpeedLabel.bottom + 10, kScreenWidth/3, 15), NSTextAlignmentCenter, @"分钟/公里", kFontSize(14), [UIColor whiteColor], NO);
    
    /* 竖线分割*/
    InsertView(self, CGRectMake(kScreenWidth/3,_movementSpeedLabel.top + 3, 0.5,35), [UIColor whiteColor]);
    
    /* 时间 */
    _sportsTimeLabel = InsertLabel(self,CGRectMake(kScreenWidth/3, _movementSpeedLabel.top, kScreenWidth/3, 20), NSTextAlignmentCenter, @"00:00:00",kFontSize(15), [UIColor whiteColor], NO);
    InsertLabel(self, CGRectMake(_sportsTimeLabel.left, _sportsTimeLabel.bottom + 10, kScreenWidth/3, 20), NSTextAlignmentCenter, @"用时", kFontSize(14), [UIColor whiteColor], NO);
    
    /* 竖线分割*/
    InsertView(self, CGRectMake(kScreenWidth/3 * 2,_movementSpeedLabel.top + 3, 0.5,35), [UIColor whiteColor]);
    
    /* 能量 */
    _sportsPhysicalLabel = InsertLabel(self, CGRectMake(_sportsTimeLabel.right, _movementSpeedLabel.top, kScreenWidth/3, 20), NSTextAlignmentCenter, @"0", kFontSize(15), [UIColor whiteColor], NO);
    
    InsertLabel(self, CGRectMake(_sportsPhysicalLabel.left, _sportsPhysicalLabel.bottom + 10, kScreenWidth/3, 20), NSTextAlignmentCenter, @"千卡", kFontSize(14), [UIColor whiteColor], NO);
    
    UIImageView *lockImg = InsertImageView(self,CGRectMake((kScreenWidth  - 72/2)/2, kScreenHeight - 130, 72/2, 72/2), [UIImage imageNamed:@"walk_ic_lock"]);
    
    InsertLabel(self, CGRectMake(0, lockImg.bottom + 15, kScreenWidth, 15), NSTextAlignmentCenter, @"向下滑动解锁",kFontSize(15), [UIColor whiteColor], NO);
    
    InsertImageView(self,CGRectMake((kScreenWidth  - 28)/2, kScreenHeight - 50, 28, 20), [UIImage imageNamed:@"walk_ic_lock_down"]);
    
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [self addGestureRecognizer:recognizer];
}

- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer{
    [self removeFromSuperview];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO]; // 允许锁屏
}

@end
