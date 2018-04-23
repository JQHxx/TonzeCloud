//
//  TJYRelatedRecipesCell.h
//  Product
//
//  Created by zhuqinlu on 2017/4/17.
//  Copyright © 2017年 TianJi. All rights reserved.
//   食材关联菜谱

#import <UIKit/UIKit.h>
#import "TJYMenuListModel.h"
#import "MenuCollectModel.h"

@interface TJYRelatedRecipesCell : UITableViewCell

/// 食物图片
@property (nonatomic ,strong) UIImageView *relatedImg;
/// 食物名称
@property (nonatomic ,strong) UILabel *relatedNameLab;
/// 云菜谱
@property (nonatomic ,strong) UIImageView *cloudIcon;
/// 菜谱简介
@property (nonatomic ,strong) UILabel *relatedInfo;
/// 点击量
@property (nonatomic ,strong) UILabel *hitsLab;
/// 阅读量
@property (nonatomic ,strong) UILabel *readNumberLab;

-(void)cellInitWithData:(TJYMenuListModel *)model searchText:(NSString *)searchText;

-(void)menuCellDisplayWithModel:(MenuCollectModel *)menuModel;

@end
