//
//  NSDate+Extension.h
//  JinAnSecurity
//
//  Created by AllenKwok on 15/10/17.
//  Copyright © 2015年 JinAn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Extension)
/**
 *  @return 当前时间
 */
+ (NSString *)currentDate;

/**
 *  从日期中获取小时
 *
 *  @param date 日期
 *
 *  @return 日期中的小时
 */
+ (NSString *)getHourFromDate:(NSDate *)date;


/**
 *  @return 当前时间
 */
+ (NSString *)currentTime;

/**
 *  从日期中获取分钟
 *
 *  @param date 日期
 *
 *  @return 日期中的分钟
 */
+ (NSString *)getMinuteFromDate:(NSDate *)date;

+ (NSString *)getSecondFromDate:(NSDate *)date;

//方法，输入参数是NSDate，输出结果是日。
+ (NSNumber *)getDayFromDate:(NSDate *)inputDate;

//方法，输入参数是NSDate，输出结果是月。
+ (NSNumber *)getMonthFromDate:(NSDate *)inputDate;

//方法，输入参数是NSDate，输出结果是年。
+ (NSNumber *)getYearFromDate:(NSDate *)inputDate;

/**
 *  @return 当前时间(精确到秒)
 */
+(NSString *)currentFullDate;

+ (NSDate *)getDateWithYear:(int )year andMonth:(int )month andDay:(int )day andHour:(int )hour andMinute:(int )minute andSecond:(int )second;




@end
