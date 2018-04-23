//
//  ZQSelectButton.h
//  YY
//
//  Created by mahailin on 15/9/28.
//  Copyright © 2015年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  选中按钮
 */
@interface ZQSelectButton : UIButton

/**
 *  是否选中，是-yes，否-no
 */
@property (nonatomic, assign) BOOL selectState;

/**
 *  设置标题高度，默认为0.0，设置该值可以将button的图片、文字修改完图片在上、文字在下的格式
 */
@property (nonatomic, assign) CGFloat titleHeight;

/**
 *  普通状态下的文字颜色
 */
@property (nonatomic, strong) UIColor *normalTextColor;

/**
 *  选中状态下的文字颜色
 */
@property (nonatomic, strong) UIColor *selectedTextColor;

/**
 *  普通状态下的图片
 */
@property (nonatomic, strong) UIImage *normalImage;

/**
 *  选中状态下的图片
 */
@property (nonatomic, strong) UIImage *selectedImage;

/**
 *  普通状态下的背景图片
 */
@property (nonatomic, strong) UIImage *normalBackgroundImage;

/**
 *  选中状态下的背景图片
 */
@property (nonatomic, strong) UIImage *selectedBackgroundImage;

/**
 *  普通状态下的背景颜色
 */
@property (nonatomic, strong) UIColor *normalBackgroundColor;

/**
 *  选中状态下得背景颜色
 */
@property (nonatomic, strong) UIColor *selectedBackgroundColor;

@end
