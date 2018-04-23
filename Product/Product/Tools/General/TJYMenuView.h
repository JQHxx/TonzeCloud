//
//  TCMenuView.h
//  TonzeCloud
//
//  Created by vision on 17/2/15.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TJYMenuView;
@protocol TJYMenuViewDelegate <NSObject>

-(void)menuView:(TJYMenuView *)menuView actionWithIndex:(NSInteger)index;

@end

@interface TJYMenuView : UIView

@property (nonatomic ,weak) id<TJYMenuViewDelegate>delegate;

@property (nonatomic,strong)NSMutableArray *menusArray;

@property (nonatomic,strong)NSMutableArray *shopMenusArray;

@property (nonatomic,strong)UIScrollView  *rootScrollView;


-(void)changeViewWithButton:(UIButton *)btn;



@end
