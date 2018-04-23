//
//  FoodMenuView.h
//  Product
//
//  Created by 肖栋 on 17/4/26.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FoodMenuView;
@protocol FoodMenuViewDelegate <NSObject>

-(void)foodMenuView:(FoodMenuView *)menuView actionWithIndex:(NSInteger)index;

@end
@interface FoodMenuView : UIView
@property (nonatomic ,weak) id<FoodMenuViewDelegate>delegate;

@property (nonatomic,strong)NSMutableArray *foodMenusArray;
@property (nonatomic,strong)UIScrollView  *rootScrollView;

-(instancetype)initWithFrame:(CGRect)frame;

-(void)changeFoodViewWithButton:(UIButton *)btn;

@end
