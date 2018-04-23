//
//  TJYFoodLibraryCell.h
//  Product
//
//  Created by zhuqinlu on 2017/4/15.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TJYFoodListModel.h"

@interface TJYFoodLibraryCell : UITableViewCell

/// 食物图片
@property (nonatomic ,strong) UIImageView *foodImg;
/// 食物名称
@property (nonatomic ,strong) UILabel *foodNameLab;
/// 能量比
@property (nonatomic ,strong) UILabel *foodEnergyLab;

@property (nonatomic, assign) BOOL isFromNutritionScale;

- (void)initWithFoodListModel:(TJYFoodListModel *)model orderbyStr:(NSString *)orderbyStr;

// searchText 用户搜索，不需要可不传
- (void)setdataWithFoodListModel:(TJYFoodListModel *)model searchText:(NSString *)searchText;

@end
