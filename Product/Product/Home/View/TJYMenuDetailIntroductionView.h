//
//  TJYMenuDetailIntroductionView.h
//  Product
//
//  Created by zhuqinlu on 2017/5/17.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TJYMenuDetailIntroductionView : UIView
/// 菜谱名称
@property (nonatomic ,strong) UILabel *menuNameLabel;
/// 菜谱图片
@property (nonatomic ,strong) UIImageView *menuImg;

/// 阅读量
@property (nonatomic ,strong) UILabel *readLabel;
/// 点赞量
@property (nonatomic ,strong) UILabel *likeLabel;
/// 菜谱描述
@property (nonatomic ,strong) UILabel *abstractLabel;
/// 食物热量
@property (nonatomic ,strong) UILabel *energyLabel;


@end
