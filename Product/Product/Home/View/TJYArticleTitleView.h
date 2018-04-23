//
//  TJYArticleTitleView.h
//  Product
//
//  Created by zhuqinlu on 2018/3/26.
//  Copyright © 2018年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TJYArticleTitleView;

@protocol TJYArticleMenuViewDelegate <NSObject>

-(void)articleTitleMenuView:(TJYArticleTitleView *)menuView actionWithIndex:(NSInteger)index;

@end

@interface TJYArticleTitleView : UIView

@property (nonatomic ,weak) id<TJYArticleMenuViewDelegate>delegate;

@property (nonatomic,strong)NSMutableArray *articleMenusArray;
@property (nonatomic,strong)UIScrollView  *rootScrollView;

-(instancetype)initWithFrame:(CGRect)frame;

-(void)changeFoodViewWithButton:(UIButton *)btn;

- (void)changeBtnLineWithButton:(UIButton *)btn;

@end
