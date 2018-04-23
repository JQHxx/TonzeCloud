//
//  QLSearchBar.h
//  TonzeCloud
//
//  Created by zhuqinlu on 2017/12/25.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QLSearchBar : UISearchBar

// 默认YES居中，通过设置NO，可居左
@property (nonatomic, assign, setter = setHasCentredPlaceholder:) BOOL hasCentredPlaceholder;

// searchField 左侧图片
@property (nonatomic, strong) UIImage *leftImage;

// placeholder颜色
@property (nonatomic, strong) UIColor *placeholderColor;


- (instancetype)initWithFrame:(CGRect)frame leftImage:(UIImage *)leftImage placeholderColor:(UIColor *)placeholderColor;


@end
