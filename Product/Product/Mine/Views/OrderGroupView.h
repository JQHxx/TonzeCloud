//
//  OrderGroupView.h
//  Weekens
//
//  Created by fei on 15/4/16.
//  Copyright (c) 2015年 ___YKSKJ.COM___. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OrderGroupViewDelegate <NSObject>

-(void)orderGroupViewBtnActionWithIndex:(NSInteger)index;

@end

@interface OrderGroupView : UIView

@property (nonatomic ,weak)id<OrderGroupViewDelegate>delegate;
@property (nonatomic, strong)NSArray *orderNumArr;
@end
