//
//  FoodSelecedView.h
//  Product
//
//  Created by Wzy on 1/9/17.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TJYFoodListModel.h"
#import "FoodAddModel.h"

typedef NS_ENUM(NSUInteger, FoodSelectToType) {
    FoodSelectToTypeDetail           = 0,
    FoodSelectToTypeEstimate         = 1
};

typedef void (^FoodDeleteBlock)(TJYFoodListModel * food,BOOL isDeleteAll);

typedef void (^FoodModifyBlock)(TJYFoodListModel * food);

typedef void (^ FoodSelectToBlock)(FoodSelectToType type,FoodAddModel * model);


@interface FoodSelecedView : UIView

@property (nonatomic,copy) FoodModifyBlock modifyBlock;

@property (nonatomic,copy) FoodSelectToBlock selectToBlock;


/**
 *  显示页面
 */
-(void)foodSelecedShowInView:(UIView *)view withArray:(NSMutableArray *)arrayData foodSelecedBlock:(FoodDeleteBlock)block;

@end
