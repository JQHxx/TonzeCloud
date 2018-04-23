//
//  TJYNutrientContentCell.h
//  Product
//
//  Created by zhuqinlu on 2017/4/17.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TJYFoodDetailsModel.h"
@interface TJYNutrientContentCell : UITableViewCell

/// 成分类型
@property (nonatomic ,strong)  UILabel *ingredientTypeLabel;
/// 含量
@property (nonatomic ,strong)  UILabel *contentLabel;

@end
