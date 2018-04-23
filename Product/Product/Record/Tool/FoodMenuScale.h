//
//  FoodMenuScale.h
//  Product
//
//  Created by 肖栋 on 17/4/24.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FoodAddModel.h"

@class FoodMenuScale;
@protocol FoodMenuScaleViewDelegate <NSObject>
@optional
-(void)foodMenuScaleView:(FoodMenuScale *)scaleView didSelectFood:(FoodAddModel *)food;
-(void)foodMenuScaleView:(FoodMenuScale *)scaleView;
-(void)foodMenuNextScaleView:(FoodMenuScale *)scaleNextView didSelectFood:(FoodAddModel *)food;

@end
@interface FoodMenuScale : UIView
/**
 *  跳转之后还是显示测量视图
 */
@property (nonatomic, assign) BOOL isShow;
@property (nonatomic,weak)id<FoodMenuScaleViewDelegate>foodMenuScaleDelegate;

-(instancetype)initWithFrame:(CGRect)frame model:(FoodAddModel *)model type:(NSInteger)type;

-(void)scaleViewShowInView:(UIView *)view;

@end
