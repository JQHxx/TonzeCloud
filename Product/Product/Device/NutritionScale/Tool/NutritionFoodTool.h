//
//  NutritionFoodTool.h
//  Product
//
//  Created by Wzy on 1/9/17.
//  Copyright © 2017年 TianJi. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "TJYFoodListModel.h"

@interface NutritionFoodTool : NSObject

singleton_interface(NutritionFoodTool)

@property (nonatomic,strong)NSMutableArray *selectFoodArray;   //已选食物数组

/*
 *@bref 添加食物
 */
-(void)insertFood:(TJYFoodListModel *)food;

/*
 *@bref 更新食物
 */
-(void)updateFood:(TJYFoodListModel *)food;

/*
 *@bref 删除食物
 */
-(void)deleteFood:(TJYFoodListModel *)food;

/*
 *@bref 删除所有事物
 */
-(void)removeAllFood;

@end
