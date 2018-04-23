//
//  TJYFoodListModel.h
//  Product
//
//  Created by zhuqinlu on 2017/4/27.
//  Copyright © 2017年 TianJi. All rights reserved.
//    食物列表模型

#import <Foundation/Foundation.h>

@interface TJYFoodListModel : NSObject<NSCopying,NSMutableCopying>

/// 食物标识id
@property (nonatomic, assign)  NSInteger id;
/// 名称
@property (nonatomic, copy) NSString *name;
/// 能量
@property (nonatomic, assign) NSInteger energykcal;
/// 食物图片
@property (nonatomic, copy) NSString *image_url;

@property (nonatomic, assign)  NSInteger target_id;
/// 碳水化合物
@property (nonatomic, assign) NSInteger   carbohydrate;
/// 维生素c
@property (nonatomic, assign) NSInteger  vitaminC ;
/// 维生素e
@property (nonatomic, assign) NSInteger  vitaminE ;
/// 蛋白质
@property (nonatomic, assign) NSInteger  protein ;
/// 脂肪
@property (nonatomic, assign) NSInteger  fat ;
///膳食纤维
@property (nonatomic, assign) NSInteger  insolublefiber;
///维生素A
@property (nonatomic, assign) NSInteger  totalvitamin;
///胆固醇
@property (nonatomic, assign) NSInteger  cholesterol;

/**
 *  重量
 */
@property (nonatomic, assign) CGFloat weight;
/**
 *  总能量（根据重量动态计算）
 */
@property (nonatomic, assign) CGFloat totalkcal;


@end
