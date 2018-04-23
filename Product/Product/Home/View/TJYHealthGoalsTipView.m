//
//  TJYHealthGoalsTipView.m
//  Product
//
//  Created by zhuqinlu on 2017/5/24.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TJYHealthGoalsTipView.h"

@implementation TJYHealthGoalsTipView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        UIImageView *tipImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
        tipImg.userInteractionEnabled = YES;
        tipImg.image = [UIImage imageNamed:@"img_h_pop_bg"];
        [self addSubview:tipImg];
        
        UILabel *tipText = [[UILabel alloc]initWithFrame:CGRectMake(10, 10 , CGRectGetWidth(self.frame) - 40, 30)];
        tipText.font = kFontSize(12);
        tipText.numberOfLines = 0;
        tipText.textColor = [UIColor whiteColor];
        tipText.text = @"设定健康目标，我们将为您推荐精准的营养调理方案。";
        [tipImg addSubview:tipText];
        
        UIImageView *cancelImg = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - 25, (tipImg.height-25)/2, 20, 20)];
        cancelImg.image = [UIImage imageNamed:@"img_h_x"];
        [self addSubview:cancelImg];
        
        InsertButtonWithType(tipImg, CGRectMake(40, 0, tipImg.width - 40, tipImg.height), 1000, self, @selector(cancelClick), UIButtonTypeCustom);

    }
    return self;
}

#pragma mark -- Action 
// 隐藏
- (void)cancelClick{
    [NSUserDefaultInfos putInt:@"SetTarget" andValue:1];// 记录用户是否设置过健康目标
    [self removeFromSuperview];
}
@end
