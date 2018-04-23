//
//  TJYFoodRecommendMenuView.h
//  Product
//
//  Created by zhuqinlu on 2017/5/16.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TJYFoodRecommendMenuView;
@protocol TJYFoodRecommendMenuViewDelegate <NSObject>

-(void)foodMenuView:(TJYFoodRecommendMenuView *)menuView Index:(NSInteger)index;

@end
@interface TJYFoodRecommendMenuView : UIView

@property (nonatomic ,weak) id<TJYFoodRecommendMenuViewDelegate>delegate;

@property (nonatomic,strong)NSMutableArray *menusArray;
@property (nonatomic,strong)UIScrollView  *rootScrollView;


-(void)changeViewWithButton:(UIButton *)btn;


@end
