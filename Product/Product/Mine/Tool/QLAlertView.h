//
//  QLAlertView.h
//  Product
//
//  Created by zhuqinlu on 2018/1/23.
//  Copyright © 2018年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^AlertResult)(NSInteger index);

@interface QLAlertView : UIView

@property (nonatomic,copy) AlertResult resultIndex;


- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message sureBtn:(NSString *)sureTitle cancleBtn:(NSString *)cancleTitle;

- (void)showQLAlertView;


@end
