//
//  FoodAddTool.h
//  Product
//
//  Created by 肖栋 on 17/4/15.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FoodAddModel.h"

@interface FoodAddTool : NSObject

singleton_interface(FoodAddTool)

@property (nonatomic,strong)NSMutableArray *selectFoodArray;   //已选食物数组

/*
 *@bref 添加食物
 */
-(void)insertFood:(FoodAddModel *)food;

/*
 *@bref 更新食物
 */
-(void)updateFood:(FoodAddModel *)food;

/*
 *@bref 删除食物
 */
-(void)deleteFood:(FoodAddModel *)food;

/*
 *@bref 删除所有事物
 */
-(void)removeAllFood;

@end
