//
//  TJYOrderbyView.h
//  Product
//
//  Created by zhuqinlu on 2017/5/22.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^orderbySelectBlock)(NSInteger index);

@interface TJYOrderbyView : UIView

- (instancetype)initWithFrame:(CGRect)frame orderbyArray:(NSArray *)orderby orderbySelectBlock:(orderbySelectBlock)orderbySelectBlock;

@property (nonatomic ,assign) NSInteger index;

@end
