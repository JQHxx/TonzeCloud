//
//  FoodClassCell.h
//  Product
//
//  Created by zhuqinlu on 2017/4/14.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TJYFoodClassCell : UICollectionViewCell
/// 分类的图片
@property (strong, nonatomic)  UIImageView *foodImage;
/// 分类名称
@property (strong, nonatomic)  UILabel *classLabel;

@end
