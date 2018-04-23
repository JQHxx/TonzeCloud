//
//  FoodClassCell.h
//  Product
//
//  Created by zhuqinlu on 2017/4/14.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TJYMenuListModel.h"

@interface TJYMenuCell : UICollectionViewCell
/// 分类的图片
@property (strong, nonatomic)  UIImageView *menuImage;
/// 菜谱名
@property (nonatomic ,strong)  UILabel *recipeNameLabel;
/// 菜谱简介
@property (nonatomic ,strong) UILabel *menuIntroductionLab;
/// 云菜谱标识
@property (nonatomic ,strong) UIImageView *cloudIcon;
/// 阅读量
@property (nonatomic ,strong) UILabel *readLabel;
/// 点击量
@property (nonatomic ,strong) UILabel *hitsLabel;
/// 赞图标
@property (nonatomic ,strong) UIImageView *thumbsUpImg;
/// 阅读图标
@property (nonatomic ,strong) UIImageView *readImg;

/// 瀑布流型布局
- (void)updataWaterfallsFlowFrame;

/// 横向型布局
- (void)UpdateLineFrame;

- (void)cellInitWithMenuListModel:(TJYMenuListModel *)menuListModel;

@end
