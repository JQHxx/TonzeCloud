//
//  UIImage+Extension.h
//  JinAnSecurity
//
//  Created by AllenKwok on 15/10/12.
//  Copyright © 2015年 JinAn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Extension)
/**
 *  根据颜色创建图片
 */
+(UIImage *)createImageWithColor:(UIColor*)color;

/**
 *  输入字符串生成二维码图片
 */
+ (UIImage *)createQRImageWithString:(NSString *)string rate:(CGFloat)rate;


@end
