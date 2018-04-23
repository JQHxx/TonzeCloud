//
//  TJYFoodRecommendCell.h
//  Product
//
//  Created by zhuqinlu on 2017/4/20.
//  Copyright © 2017年 TianJi. All rights reserved.
//  推荐菜谱

#import <UIKit/UIKit.h>
#import "TJYFoodRecommendModel.h"

@interface TJYFoodRecommendCell : UITableViewCell
/// 食物图
@property (nonatomic, strong) UIImageView *foodImg;
/// 菜谱
@property (nonatomic ,strong) UILabel *menuNameLable;
/// 重量
@property (nonatomic ,strong) UILabel *weightLabel;
/// 卡路里
@property (nonatomic ,strong) UILabel *caloriesLable;


- (void)initWithFoodListModel:(TJYFoodRecommendModel *)model;

@end
