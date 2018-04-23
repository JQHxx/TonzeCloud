//
//  TJYFoodLibraryVC.h
//  Product
//
//  Created by zhuqinlu on 2017/4/14.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "BaseViewController.h"
#import "TJYFoodListModel.h"

typedef void (^FoodSelectBlock)(TJYFoodListModel * model);

@interface TJYFoodLibraryVC : BaseViewController

@property (nonatomic ,strong)NSString *orderbyStr;

/**
 *  标题食物
 */
@property (nonatomic ,strong)NSString * strTitle;

/**
 *  标识从营养秤那边跳入，选择就就返回食物
 */
@property (nonatomic, assign) BOOL isFromNutritionScale;

/**
 *  营养秤选择食物后，返回食物
 */
@property (nonatomic, copy) FoodSelectBlock selectBlock;

@end
