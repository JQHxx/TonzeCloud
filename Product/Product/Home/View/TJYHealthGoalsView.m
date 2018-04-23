
//
//  TJYHealthGoalsView.m
//  Product
//
//  Created by zhuqinlu on 2017/5/15.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TJYHealthGoalsView.h"

@implementation TJYHealthGoalsView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        UIImageView *bgImg = InsertImageView(self, CGRectMake(0, 0, self.width, self.height), [UIImage imageNamed:@"ic_h_objective"]);
        
        _healthTextLab= InsertLabel(bgImg, CGRectMake(0, bgImg.height/2 - 20, bgImg.width, 15), NSTextAlignmentCenter, @"健康目标", kFontSize(14), kSystemColor, NO);
        
        _addImg = InsertImageView(bgImg, CGRectMake((bgImg.width - 37/2)/2, bgImg.height/2 + 2, 37/2, 37/2), [UIImage imageNamed:@"ic_h_add"]);
        _addImg.hidden = YES;
        
        _healthTargetLab =InsertLabel(bgImg, CGRectMake(0, bgImg.height/2, bgImg.width, 15), NSTextAlignmentCenter, @"", kFontSize(14), UIColorHex(0x999999), NO);
    }
    return self;
}


@end
