//
//  NSString+Extension.h
//  Product
//
//  Created by WuJiezhong on 16/6/2.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extension)

/// 判断是否为空 或者有空格
+(BOOL)isEmpty:(NSString *)str;

///将整数转换成十六进制字符串（不加"0x"前缀），如10转成“0A”, 100转成“64”
+ (NSString *)hexStringWithInteger:(NSInteger)integer;


///忽略大小写对比字符串
- (BOOL)isEqualCaseInsensitive:(NSString *)aString;

/**
 *  动态确定文本的宽高
 *
 *  @param size 宽高限制，用于计算文本绘制时占据的矩形块。
 *  @param font 字体
 *
 *  @return 文本绘制所占据的矩形空间
 */
- (CGSize)boundingRectWithSize:(CGSize)size withTextFont:(UIFont *)font;

/**
 *  判断字符串是否数字
 *
 *  @param string 字符串
 *
 *  @return 是或否
 */
+(BOOL)isPureInt:(NSString *)string;

/**
 *  MD5加密
 *
 *  @return
 */
-(NSString *) MD5;

#pragma mark - 富文本操作

/**
 *  单纯改变一句话中的某些字的颜色（一种颜色）
 *
 *  @param color    需要改变成的颜色
 *  @param totalStr 总的字符串
 *  @param subArray 需要改变颜色的文字数组(要是有相同的 只取第一个)
 *
 *  @return 生成的富文本
 */
+ (NSMutableAttributedString *)ql_changeCorlorWithColor:(UIColor *)color TotalString:(NSString *)totalStr SubStringArray:(NSArray *)subArray;

#pragma mark - 获取某个子字符串在某个总字符串中位置数组
/**
 *  获取某个字符串中子字符串的位置数组
 *
 *  @param totalString 总的字符串
 *  @param subString   子字符串
 *
 *  @return 位置数组
 */
+ (NSMutableArray *)ql_getRangeWithTotalString:(NSString *)totalString SubString:(NSString *)subString;
/**
 *  改变一段文字某些字的颜色
 *
 *  @param rangeText 总的字符串
 *  @param noRangeInedex   不需要改变颜色的位置末尾数
 *  @param  changeColor  改变的字体颜色
 *  @return 位置数组
 */
+ (NSMutableAttributedString *)ql_changeRangeText:(NSString *)rangeText noRangeInedex:(NSInteger)noRangeInedex changeColor:(UIColor *)color;

/**
 *  简单计算textsize
 *
 *  @param width 传入特定的宽度
 *  @param font  字体
 */
- (CGSize)sizeWithLabelWidth:(CGFloat)width font:(UIFont *)font;

/**
 *
 *  判断用户数据是否改变，当进入首页用户完善发生改变首页数据刷新
 */
+ (BOOL)isNeedLoadData;
/**
 *
 *      将秒时间处理，计算秒得到的小时和分钟
 */
+ (NSString *)ql_getStepTimeWithTime:(NSInteger )time;
/**
 *
 *      将秒时间处理，计算秒得到的小时和分钟
 *
 *  @param  code  设备指令
 *  @param  type  设备类型
 */
+ (NSString *)ql_getDeviceCodeWithCode:(NSString *)code type:(NSInteger )type cookerTag:(NSInteger )cookerTag isPreference:(BOOL)isPreference;

/// 浮点型数据不四舍五入
+ (NSString *)notRounding:(NSString *)price afterPoint:(NSInteger )position;

+ (NSString *)ql_phoneNumberCodeText:(NSString *)text;

@end
