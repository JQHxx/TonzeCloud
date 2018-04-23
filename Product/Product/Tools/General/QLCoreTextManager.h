//
//  QLCoreTextManager.h
//  Product
//
//  Created by zhuqinlu on 2017/5/25.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

@interface QLCoreTextManager : NSObject

/// 改变字体属性（颜色及大小）
+ (void)setAttributedValue:(NSMutableAttributedString *)attString text:(NSString *)aString font:(UIFont *)aFont color:(UIColor *)aColor;

@end

/*
 使用coretext改变字体属性
 步骤1 导入框架CoreText.framework
 
 步骤2 导入头文件 #import <CoreText/CoreText.h>
 
 步骤3 将NSString转变成NSMutableAttributedString，根据要设置的字符串属性进行设置
 // 区域
 NSString *oldString = [attString string];
 NSRange range = [oldString rangeOfString:aString];
 // 颜色
 [attString addAttribute:NSForegroundColorAttributeName value:aColor range:range];
 // 字体
 [attString addAttribute:NSFontAttributeName value:aFont range:range];
 
 示例：
 NSString *totalStr =[NSString stringWithFormat:@"%ld分",(long)_index];
 NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:totalStr];
 [QLCoreTextManager setAttributedValue:attStr text:@"分" font:kFontSize(13) color:[UIColor whiteColor]];
 lab.attributedText = attStr;
 
 */

