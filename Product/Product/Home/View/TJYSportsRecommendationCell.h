//
//  TJYSportsRecommendationCell.h
//  Product
//
//  Created by zhuqinlu on 2017/4/15.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TJYRecommendMotionModel.h"

@interface TJYSportsRecommendationCell : UITableViewCell
/// 运动项目图片
@property (nonatomic ,strong) UIImageView *sportsTypImg;
/// 运动类型
@property (nonatomic ,strong) UILabel *sportsTypeNameLab;
/// 运动时间
@property (nonatomic ,strong) UILabel *sportsTimeLab;
/// 运动体能
@property (nonatomic ,strong) UILabel *sportsEnergyLab;
/// 运动强度
@property (nonatomic ,strong) UILabel *motionIntensityLab;

@property (nonatomic ,strong) UIView *len;

- (void)cellInitWithData:(TJYRecommendMotionModel *)model;

@end
