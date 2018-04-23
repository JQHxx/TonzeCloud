//
//  TJYFoodRecommendModel.h
//  Product
//
//  Created by zhuqinlu on 2017/5/2.
//  Copyright © 2017年 TianJi. All rights reserved.
//   首页食物推荐模型

#import <Foundation/Foundation.h>

@interface TJYFoodRecommendModel : NSObject
/// 分类名称
@property (nonatomic, copy) NSString *cat_name ;
/// 食物id
@property (nonatomic, assign) NSInteger food_id ;
/// 食物名称
@property (nonatomic, copy) NSString *food_name ;
/// 重量
@property (nonatomic, strong) NSNumber *weight ;
/// 类型
@property (nonatomic, assign) NSInteger type;
/// 能量
@property (nonatomic, assign) NSInteger energykcal;
/// 图片链接
@property (nonatomic, copy) NSString *image_url;



@end
