//
//  TJYCookIngredientModel.h
//  Product
//
//  Created by zhuqinlu on 2017/5/3.
//  Copyright © 2017年 TianJi. All rights reserved.
//  菜谱详情食材

#import <Foundation/Foundation.h>

@interface TJYCookIngredientModel : NSObject

/// 能量
@property (nonatomic, assign) NSInteger  ingredient_calories ;
/// 食材id
@property (nonatomic, assign) NSInteger  ingredient_id;
///食材名称
@property (nonatomic, copy) NSString  *ingredient_name ;
///食材含量
@property (nonatomic, assign) NSInteger  ingredient_weight ;

@end
