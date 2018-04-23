
//
//  SceneOptionView.m
//  Product
//
//  Created by zhuqinlu on 2017/6/15.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "SceneOptionView.h"
#import "SceneOptionButton.h"

@interface SceneOptionView ()

@end

@implementation SceneOptionView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setSceneOptionView];
    }
    return self;
}
- (void)setSceneOptionView{
    
    self.showInputView= [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    self.showInputView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.showInputView];
    
    // 时间
    SceneOptionButton *timeIntervalBtn = [[SceneOptionButton alloc]initWithFrame:CGRectMake(0,0 ,kScreenWidth/2 , self.showInputView.height)];
    timeIntervalBtn.iconImg.image = [UIImage imageNamed:@"Scene_AddTiming_icon"];
    timeIntervalBtn.titileLab.text = @"添加时间间隔";
    timeIntervalBtn.tag = 1002;
    [timeIntervalBtn addTarget:self action:@selector(addClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.showInputView addSubview:timeIntervalBtn];
    // 设备
    SceneOptionButton *addDeviceBtn = [[SceneOptionButton alloc]initWithFrame:CGRectMake(kScreenWidth/2,0 ,kScreenWidth/2 , self.showInputView.height)];
    addDeviceBtn.iconImg.image = [UIImage imageNamed:@"Scene_equipment_icon"];
    addDeviceBtn.titileLab.text = @"添加设备";
    addDeviceBtn.tag = 1001;
    [addDeviceBtn addTarget:self action:@selector(addClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.showInputView addSubview:addDeviceBtn];
}
#pragma mark ======  Event response  =======
- (void)addClick:(UIButton *)button
{
    if ( self.btnClickBlock ) {
        self.btnClickBlock(button.tag);
    }
}
- (void)dismissViewAction{
    [self removeFromSuperview];
}


@end
