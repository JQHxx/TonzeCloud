//
//  TJYFoodClassificationView.h
//  Product
//
//  Created by zhuqinlu on 2017/4/19.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^btnSelectBlock)(NSInteger index);

@interface TJYFoodClassificationView : UIView

- (instancetype)initWithFrame:(CGRect)frame
                  effectArray:(NSArray *)effectArray
               btnSelectBlock:(btnSelectBlock)btnSelectBlock;

/// 功效id
@property (nonatomic, strong) NSMutableArray *effectId;
/// 底部滑动视图
@property (nonatomic ,strong)  UIScrollView *rootScrollView;


@end
