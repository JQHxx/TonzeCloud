//
//  CloudRecipesCell.h
//  Product
//
//  Created by zhuqinlu on 2017/6/15.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TJYMenuListModel.h"

@interface CloudRecipesCell : UITableViewCell
/// 菜谱图标
@property (nonatomic ,strong) UIImageView *menuImg;
/// 菜谱名称
@property (nonatomic ,strong) UILabel *menuNameLab;
/// 菜谱简介
@property (nonatomic ,strong) UILabel *menuInfoLab;

- (void)setMenuListWithModel:(TJYMenuListModel *)model;

@end
