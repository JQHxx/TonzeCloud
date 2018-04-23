//
//  NutritionDetailView.h
//  Product
//
//  Created by Wzy on 1/9/17.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TJYFoodDetailsModel.h"


@interface NutritionDetailView : UIView

/**
 *  显示页面
 */
-(void)nutritionDetailShowInView:(UIView *)view;

/**
 *  赋值
 */
-(void)renderNutritionDetail:(TJYFoodDetailsModel *)foodModel;

@end
