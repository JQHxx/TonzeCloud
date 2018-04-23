//
//  TJYRecommendView.h
//  Product
//
//  Created by zhuqinlu on 2017/5/16.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TJYHealthGoalsView.h"

@interface TJYRecommendView : UIView

@property (nonatomic ,copy) void (^recommendBtnClickBlock)(NSInteger index);

///
@property (nonatomic, copy) void (^healthGoalsTapBlock)(NSInteger tapIndex);
/// 推荐摄入总量
@property (nonatomic ,strong)  UILabel *intakeLabel;
/// 推荐消耗总能量
@property (nonatomic ,strong) UILabel *consumptionLabel;
/// 监看目标按钮
@property (nonatomic ,strong) TJYHealthGoalsView *healthGoalsView;
/// 是否为食疗推荐
@property (nonatomic ,assign) BOOL isShowfoodRecommend;


@end
