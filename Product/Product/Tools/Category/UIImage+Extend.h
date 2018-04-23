//
//  UIImage+Extend.h
//  SRZCommonTool
//
//  Created by vision on 16/7/21.
//  Copyright © 2016年 SRZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Extend)

/**
 *  自由拉伸图片
 *
 *  @param imgName 图片名称
 *
 *  @return
 */
+ (UIImage *)resizedImage:(NSString *)imgName;

/**
 *  自由拉伸图片
 *
 *  @param imgName 图片名称
 *  @param xPos    左边开始位置比例 值范围0-1
 *  @param yPos    上边开始位置比例 值范围0-1
 *
 *  @return 
 */
+ (UIImage *)resizedImage:(NSString *)imgName xPos:(CGFloat)xPos yPos:(CGFloat)yPos;

/**
 *  根据给定的大小设置图片
 *
 *  @param imgName   图片名称
 *  @param itemSize  图片大小
 *
 *  @return 
 */
+(UIImage *)drawImageWithName:(NSString *)imgName size:(CGSize)itemSize;


/**
 *  根据颜色和大小获取Image
 *
 *  @param color 颜色
 *  @param size  大小
 *
 *  @return
 */
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

/**
 *  自由改变Image的大小
 *
 *  @param size 目的大小
 *
 *  @return 修改后的Image
 */
- (UIImage *)cropImageWithSize:(CGSize)size;








@end
