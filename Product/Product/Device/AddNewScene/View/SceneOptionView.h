//
//  SceneOptionView.h
//  Product
//
//  Created by zhuqinlu on 2017/6/15.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SceneOptionBtnClickBlock)(NSInteger index);

@interface SceneOptionView : UIView

///
@property (nonatomic, copy) SceneOptionBtnClickBlock  btnClickBlock;
///展示输入内容的背景
@property (nonatomic,strong) UIView *showInputView;

@end
