//
//  TJYHealthAssessmentCell.h
//  Product
//
//  Created by zhuqinlu on 2017/4/18.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TJYHealthAssessmentCell : UICollectionViewCell

/// 图标
@property (nonatomic ,strong) UIImageView *titleImg;
/// 评论标题
@property (nonatomic ,strong) UILabel *titleLabel;
/// 评论内容
@property (nonatomic ,strong) UILabel *contentLabel;

@end
