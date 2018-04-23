//
//  TJYIngredientCell.h
//  Product
//
//  Created by zhuqinlu on 2017/5/3.
//  Copyright © 2017年 TianJi. All rights reserved.
//  菜谱详情 -- 食材列表

#import <UIKit/UIKit.h>
#import "TJYCookIngredientModel.h"

@interface TJYIngredientCell : UITableViewCell

/// 食材名称
@property (nonatomic ,strong) UILabel *ingredientNameLab;
/// 食材含量
@property (nonatomic ,strong) UILabel *ingredientWeightLab;

- (void)cellInitWithData:(TJYCookIngredientModel *)model;

@end
