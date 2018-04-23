//
//  FoodScaleView.h
//  Product
//
//  Created by 肖栋 on 17/4/19.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StorageModel.h"

@class FoodScaleView;
@protocol FoodScaleViewDelegate <NSObject>

- (void)foodScaleViewTakeoutForFood:(StorageModel *)model;

@end

@interface FoodScaleView : UIView

@property (nonatomic,weak)id<FoodScaleViewDelegate>foodScaleDelegate;

-(instancetype)initWithFrame:(CGRect)frame WithModel:(StorageModel *)model;

-(void)foodScaleViewShowInView:(UIView *)view;
@end
