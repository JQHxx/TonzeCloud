//
//  TJYMenuDetailIntroductionView.m
//  Product
//
//  Created by zhuqinlu on 2017/5/17.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TJYMenuDetailIntroductionView.h"

@interface TJYMenuDetailIntroductionView ()

@end

@implementation TJYMenuDetailIntroductionView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        // 菜谱相关信息
        _menuNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20,20, 200, 20)];
        _menuNameLabel.font = [UIFont systemFontOfSize:18];
        _menuNameLabel.textColor = [UIColor colorWithHexString:@"0x313131"];
        [self addSubview:_menuNameLabel];
        
        // 菜谱图标
        _menuImg = [[UIImageView alloc] initWithFrame:CGRectMake(_menuNameLabel.right, _menuNameLabel.top, 35/2, 23/2)];
        _menuImg.image = [UIImage imageNamed:@"ic_lite_yun"];
        [self addSubview:_menuImg];
        /// 卡路里
        _energyLabel = InsertLabel(self, CGRectMake(0, _menuImg.bottom +10, kScreenWidth, 20), NSTextAlignmentCenter, @"", kFontSize(14), UIColorHex(0x999999), NO);

        UIImageView *eyeImg = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth/2-60, _energyLabel.bottom+10, 20, 20)];
        eyeImg.image = [UIImage imageNamed:@"ic_lite_yue"];
        [self addSubview:eyeImg];
        // 阅读量
        _readLabel = InsertLabel(self, CGRectMake(eyeImg.right, _energyLabel.bottom + 12, 60, 15), NSTextAlignmentLeft, @"", kFontSize(13), UIColorHex(0x999999), NO);
        
        UIImageView *seletedImg = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth/2+10, _energyLabel.bottom+10, 20, 20)];
        seletedImg.image = [UIImage imageNamed:@"ic_lite_zan"];
        [self addSubview:seletedImg];
        
        // 点击量
        _likeLabel = InsertLabel(self, CGRectMake(seletedImg.right, _energyLabel.bottom + 12, 60, 15), NSTextAlignmentLeft, @"", kFontSize(14), UIColorHex(0x999999), NO);
        // 线条
        InsertView(self, CGRectMake(15,100 - 0.5, kScreenWidth - 15, 0.5), kLineColor);
    }
    return self;
}
@end
