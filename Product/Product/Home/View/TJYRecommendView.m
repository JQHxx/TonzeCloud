

//
//  TJYRecommendView.m
//  Product
//
//  Created by zhuqinlu on 2017/5/16.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "TJYRecommendView.h"
#import "TJYRecommendButton.h"

@interface TJYRecommendView ()
{
    UIImageView *_leftSubscriptImg;
    UIImageView *_rightSubscriptImg;
    TJYRecommendButton *recommendBtn;
    NSMutableArray *_recommendBtnArray;
}

@end

@implementation TJYRecommendView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.isShowfoodRecommend = YES;
        _recommendBtnArray = [NSMutableArray array];
        
        UILabel *intakeText = InsertLabel(self, CGRectMake(0, 50, (kScreenWidth - 170/2)/2, 20), NSTextAlignmentCenter, @"推荐摄入", kFontSize(12), UIColorHex(0x626262), NO);
        _intakeLabel = InsertLabel(self, CGRectMake(0, intakeText.bottom, intakeText.width, 15), NSTextAlignmentCenter, @"", kFontSize(15), UIColorHex(0x313131), NO);
        
        UILabel *consumptionText =InsertLabel(self, CGRectMake(kScreenWidth/2 + 170/4, intakeText.top, (kScreenWidth - 75)/2, 20), NSTextAlignmentCenter, @"推荐消耗", kFontSize(12), UIColorHex(0x626262), NO);
        _consumptionLabel =InsertLabel(self, CGRectMake(consumptionText.left, consumptionText.bottom, (kScreenWidth - 75)/2, 15), NSTextAlignmentCenter, @"", kFontSize(15), UIColorHex(0x313131), NO);
        
        [self addSubview:self.healthGoalsView];    /// 健康目标
        
        self.healthGoalsView.userInteractionEnabled = YES;
        UITapGestureRecognizer *healthGoalsTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick)];
        [self.healthGoalsView addGestureRecognizer:healthGoalsTap];
        
        NSArray *recommendTitleArr = @[@"食疗推荐",@"体疗推荐"];
        NSArray *recommendNormalImgArr = @[@"ic_h_foodtherapy_nor",@"ic_h_sporttherapy_nor"];
        NSArray *recommendSelectImgArr = @[@"ic_h_foodtherapy_sel",@"ic_h_sporttherapy_sel"];
        for (NSInteger i = 0; i < recommendTitleArr.count; i++) {
            recommendBtn= [[TJYRecommendButton alloc]init];
            recommendBtn.frame = CGRectMake(i * kScreenWidth/2, self.healthGoalsView.bottom, kScreenWidth/2, self.height - self.healthGoalsView.height - 25);
            recommendBtn.tag = 1000 + i;
            if (i == 0) {
                recommendBtn.selected = YES;
            }
            [recommendBtn setTitle:recommendTitleArr[i] forState:UIControlStateNormal];
            [recommendBtn setTitle:recommendTitleArr[i] forState:UIControlStateSelected];
            [recommendBtn setImage:[UIImage imageNamed:recommendNormalImgArr[i]] forState:UIControlStateNormal];
            [recommendBtn setImage:[UIImage imageNamed:recommendSelectImgArr[i]] forState:UIControlStateSelected];
            [self addSubview:recommendBtn];
            [recommendBtn addTarget:self action:@selector(recommendBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            [_recommendBtnArray addObject:recommendBtn];
        }
        ((UIButton *)[_recommendBtnArray objectAtIndex:0]).selected=YES;// 关键是这里，
        
        /// 三角形
        _leftSubscriptImg =[[UIImageView alloc]initWithFrame:CGRectMake(0, self.height - 25  , kScreenWidth/2, 36/2)];
        _leftSubscriptImg.image = [UIImage imageNamed:@"img_h_two_mark_sel"];
        [self addSubview:_leftSubscriptImg];
        
        _rightSubscriptImg =[[UIImageView alloc]initWithFrame:CGRectMake(kScreenWidth/2, self.height - 25  , kScreenWidth/2, 36/2)];
        _rightSubscriptImg.image = [UIImage imageNamed:@"img_h_two_mark_nor"];
        [self addSubview:_rightSubscriptImg];
    }
    return self;
}
- (void)recommendBtnClick:(UIButton *)sender{
    
    ((UIButton *)[_recommendBtnArray objectAtIndex:0]).selected=NO;
    if (sender != recommendBtn) {
        recommendBtn.selected = NO;
        recommendBtn = (TJYRecommendButton *)sender;
    }
    recommendBtn.selected = YES;
    
    if (sender.tag == 1000){
        _leftSubscriptImg.image = [UIImage imageNamed:@"img_h_two_mark_sel"];
        _rightSubscriptImg.image = [UIImage imageNamed:@"img_h_two_mark_nor"];
    }else if(sender.tag == 1001){
        _leftSubscriptImg.image = [UIImage imageNamed:@"img_h_two_mark_nor"];
        _rightSubscriptImg.image = [UIImage imageNamed:@"img_h_two_mark_sel"];
    }
    if (self.recommendBtnClickBlock) {
        self.recommendBtnClickBlock (sender.tag);
    }
}
- (void)tapClick{
    if (_healthGoalsTapBlock) {
        self.healthGoalsTapBlock(1);
    };
}
- (TJYHealthGoalsView *)healthGoalsView{
    if (!_healthGoalsView) {
        _healthGoalsView = [[TJYHealthGoalsView alloc]initWithFrame:CGRectMake((kScreenWidth- 170/2)/2, 30, 170/2, 170/2)];
    }
    return _healthGoalsView;
}

@end
