//
//  TJYSearchFoodVC.h
//  Product
//
//  Created by zhuqinlu on 2017/4/14.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "BaseViewController.h"
#import "TJYFoodListModel.h"

typedef enum : NSUInteger {
    FoodSearchType=0,    // 食物搜索
    KnowledgeSearchType=1, // 文章搜索
    MenuSearchType=2,// 菜谱搜索
    FoodAddSearchType=3,  // 食物搜索
    FoodSelectSearchType=4  // 食物选择(营养秤选择食物)
} SearchType;

typedef void (^FoodSelectSearchBlock)(TJYFoodListModel * model);


@interface TJYSearchFoodVC : BaseViewController

@property (nonatomic,assign)SearchType searchType;

@property (nonatomic,assign)NSInteger type;

@property (nonatomic, copy )NSString   *keyword;

/**
 *  营养秤搜索选择食物后，返回食物
 */
@property (nonatomic, copy) FoodSelectSearchBlock selectBlock;

@end
