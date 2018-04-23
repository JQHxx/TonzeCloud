//
//  UIColor+Extend.h
//  SRZCommonTool
//
//  Created by vision on 16/7/21.
//  Copyright © 2016年 SRZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Extend)

/**
 *  十六进制转颜色
 *
 *  @param color 颜色的十六进制数值
 *
 */
+ (UIColor *) colorWithHexString: (NSString *)color;


+ (UIColor*) colorWithHex:(NSInteger)hexValue alpha:(CGFloat)alphaValue ;


+(UIColor *)bgColor_Gray;

@end
