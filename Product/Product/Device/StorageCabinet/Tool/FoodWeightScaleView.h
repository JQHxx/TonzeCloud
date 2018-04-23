//
//  FoodWeightScaleView.h
//  Product
//
//  Created by 肖栋 on 17/4/19.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FoodWeightScaleView;
@protocol FoodWeightScaleViewDelegate <NSObject>

- (void)foodWeightScaleView:(FoodWeightScaleView *)scale weight:(NSInteger )weight;

@end


@interface FoodWeightScaleView : UIView

@property (nonatomic,weak)id<FoodWeightScaleViewDelegate>foodWeightScaleDelegate;

-(instancetype)initWithFrame:(CGRect)frame weight:(NSInteger)weight;


-(void)foodWeightScaleViewShowInView:(UIView *)view;

@end
