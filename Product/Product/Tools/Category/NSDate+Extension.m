//
//  NSDate+Extension.m
//  JinAnSecurity
//
//  Created by AllenKwok on 15/10/17.
//  Copyright © 2015年 JinAn. All rights reserved.
//

#import "NSDate+Extension.h"

@implementation NSDate (Extension)

+(NSString *)currentDate{
    NSDateFormatter *format = [[NSDateFormatter alloc]init];
    [format setDateFormat:@"yyyy年MM月dd日 HH:mm"];
    
    return [format stringFromDate:[NSDate date]];
}

+(NSString *)currentTime{
    NSDateFormatter *format = [[NSDateFormatter alloc]init];
    [format setDateFormat:@"HH:mm"];
    
    return [format stringFromDate:[NSDate date]];
}

+(NSString *)currentFullDate{
    NSDateFormatter *format = [[NSDateFormatter alloc]init];
    [format setDateFormat:@"yyyy年MM月dd日 HH:mm:ss"];
    
    return [format stringFromDate:[NSDate date]];
}

+ (NSString *)getHourFromDate:(NSDate *)date{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay |NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    
    NSDateComponents *comps  = [calendar components:unitFlags fromDate:date];
    
    long hour = [comps hour];
    
    return [NSString stringWithFormat:@"%02ld",hour];
}

+ (NSString *)getMinuteFromDate:(NSDate *)date{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay |NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    
    NSDateComponents *comps  = [calendar components:unitFlags fromDate:date];
    
    long mim = [comps minute];
    
    return [NSString stringWithFormat:@"%02ld",mim];
}

+ (NSString *)getSecondFromDate:(NSDate *)date{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay |NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    
    NSDateComponents *comps  = [calendar components:unitFlags fromDate:date];
    
    long second = [comps second];
    
    return [NSString stringWithFormat:@"%02ld",second];
}

//方法，输入参数是NSDate，输出结果是日。
+ (NSNumber *)getDayFromDate:(NSDate *)inputDate{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:inputDate];
    NSInteger day = [dateComponent day];
    return @(day);
}

//方法，输入参数是NSDate，输出结果是月。
+ (NSNumber *)getMonthFromDate:(NSDate *)inputDate{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:inputDate];
    NSInteger month = [dateComponent month];
    return @(month);
}

//方法，输入参数是NSDate，输出结果是年。
+ (NSNumber *)getYearFromDate:(NSDate *)inputDate{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:inputDate];
    NSInteger year = [dateComponent year];
    return @(year);
}

//方法，根据输入的时分秒，返回nsdate
+ (NSDate *)getDateWithYear:(int )year andMonth:(int )month andDay:(int )day andHour:(int )hour andMinute:(int )minute andSecond:(int )second
{
    NSString *dateStr = [NSString stringWithFormat:@"%04d-%02d-%02d %02d:%02d:%02d",year,month,day,hour,minute,second];
    //格式化
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *fromdate=[dateFormatter dateFromString:dateStr];
    
    NSLog(@"fromdate=%@",fromdate);
    
    
    
    //    NSDateComponents *comp = [[NSDateComponents alloc]init];
    //
    //    [comp setHour:hour];
    //
    //    [comp setMinute:minute];
    //
    //    [comp setSecond:second];
    //
    //    [comp setHour:year];
    //
    //    [comp setMinute:month];
    //
    //    [comp setSecond:day];
    //
    //    NSCalendar *myCal = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    //
    //    NSDate *reDate = [myCal dateFromComponents:comp];
    
    return fromdate;
}

@end
