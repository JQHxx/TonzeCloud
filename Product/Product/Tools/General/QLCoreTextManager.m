//
//  QLCoreTextManager.m
//  Product
//
//  Created by zhuqinlu on 2017/5/25.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "QLCoreTextManager.h"

@implementation QLCoreTextManager

// 改变字体属性（颜色及大小）
+ (void)setAttributedValue:(NSMutableAttributedString *)attString text:(NSString *)aString font:(UIFont *)aFont color:(UIColor *)aColor
{
    if ((attString && 0 != attString.length) && (aString && 0 != aString.length))
    {
        NSString *oldString = [attString string];
        NSRange range = [oldString rangeOfString:aString];
        if (aColor)
        {
            // 颜色
            [attString addAttribute:NSForegroundColorAttributeName
                              value:aColor
                              range:range];
        }
        if (aFont)
        {
            // 字体
            [attString addAttribute:NSFontAttributeName
                              value:aFont
                              range:range];
        }
    }
}
@end
