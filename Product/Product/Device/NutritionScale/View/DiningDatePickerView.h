//
//  DiningDatePickerView.h
//  Product
//
//  Created by Wzy on 1/9/17.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^DiningDateBlock)(NSString * strDate);


@interface DiningDatePickerView : UIView

/**
 *  初始化
 */
-(instancetype)initWithFrame:(CGRect)frame value:(NSString *)dateValue title:(NSString *)title dateBlock:(DiningDateBlock)block;

/**
 *  显示页面
 */
-(void)datePickerViewShowInView:(UIView *)view;



@end
