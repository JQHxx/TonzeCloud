//
//  NSUserDefaultInfos.m
//  CycleNav
//
//  Created by gzgamut on 13-12-15.
//  Copyright (c) 2013年 gzgamut. All rights reserved.
//

#import "NSUserDefaultInfos.h"


@implementation NSUserDefaultInfos

+(void)putKey:(NSString *)key anddict:(NSObject *)value{

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:value forKey:key];
    [userDefaults synchronize];
}

+(void)putKey:(NSString *)key andValue:(NSObject *)value{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:value forKey:key];
    [defaults synchronize];
}
+(void)putKey:(NSString *)key andImage:(UIImage * )image{
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *imageData = UIImagePNGRepresentation(image);
    [defaults setObject:imageData forKey:key];
    [defaults synchronize];
}
+(void)putInt:(NSString *)key andValue:(int)value{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:value forKey:key];
    [defaults synchronize];
}

+(UIImage *)getImageValueforKey:(NSString *)key{
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *imageData=[defaults objectForKey:key];
    if (!imageData) {
        return nil;
    }
    UIImage *result = [UIImage imageWithData:imageData];
    if(!result){
        result = nil;
    }
    return result;
}

+(int)getIntValueforKey:(NSString *)key{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int result = (int)[defaults integerForKey:key];
    return result;
}

+(NSString *)getValueforKey:(NSString *)key{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *result = [defaults objectForKey:key];
    if(!result){
        result = nil;
    }
    return result;
}

+(NSDictionary *)getDicValueforKey:(NSString *)key{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *result = [defaults objectForKey:key];
    if(!result){
        result = nil;
    }
    return result;
}


+(NSString *)getCurrentDate{
    
    NSDateFormatter *df= [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
     df.timeZone = [NSTimeZone systemTimeZone];//系统所在时区
    return [df stringFromDate:[NSDate date]];
}

+(NSTimeInterval )getDateIntervalWithHour:(NSInteger )hour Min:(NSInteger )min{
    NSTimeInterval interval;
    
    //生成时间
    NSDateFormatter *df= [[NSDateFormatter alloc] init];
    df.timeZone = [NSTimeZone systemTimeZone];//系统所在时区
    [df setDateFormat:@"yyyy-MM-dd HH:mm:00"];
    
    NSString *dateStr=[self getCurrentDate];
    dateStr=[[dateStr substringToIndex:11] stringByAppendingString:[NSString stringWithFormat:@"%li:%li:00",(long)hour,(long)min]];
    
    
    NSDate *date=[df dateFromString:dateStr];
    interval=[date timeIntervalSinceDate:[NSDate date]];
    
    //避免一分钟差异
    if (interval>60) {
        interval+=60;
    }
    
    //避免一分钟立刻操作
    if (interval<60 && interval > 0) {
        interval+=60;
    }
    
    //如果比当前时间少则计算到明天
    if (interval<-60) {
        interval+=24*60*60+60;
    }

    
    return interval;
}

+(NSString*)getDateStrWithDate:(NSDate*)date{
    NSDateFormatter *df= [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [df stringFromDate:date];
}

+(NSString*)getTimeSP{
    return [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
}

+(NSString *)getAgeFromBirthYear:(NSString *)year{

    int currentYear=[[self getCurrentDate] substringToIndex:4].intValue;
    
    return [NSString stringWithFormat:@"%i",year.intValue==0?26:currentYear-year.intValue];
}

+(NSString *)getBirthYearFromAge:(NSString *)age{
   int currentYear=[[self getCurrentDate] substringToIndex:4].intValue;
   return [NSString stringWithFormat:@"%i",currentYear-age.intValue];
}

+(NSString *)getMonthStrFromCurrentDate{
    NSString *currentDate=[self getCurrentDate];
    
    int month=[[currentDate substringWithRange:NSMakeRange(5, 2)] intValue];
    
    NSString *monthStr=@"";
    
    
    switch (month) {
        case 1:
            monthStr=@"一月份";
            break;
        case 2:
            monthStr=@"二月份";
            break;
        case 3:
            monthStr=@"三月份";
            break;
        case 4:
            monthStr=@"四月份";
            break;
        case 5:
            monthStr=@"五月份";
            break;
        case 6:
            monthStr=@"六月份";
            break;
        case 7:
            monthStr=@"七月份";
            break;
        case 8:
            monthStr=@"八月份";
            break;
        case 9:
            monthStr=@"九月份";
            break;
        case 10:
            monthStr=@"十月份";
            break;
        case 11:
            monthStr=@"十一月份";
            break;
        case 12:
            monthStr=@"十二月份";
            break;
            
        default:
            break;
    }
    return monthStr;
    
}

+(void)removeObjectForKey:(NSString *)key{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:key];
}


+(id )getValueforIdKey:(NSString *)key{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    id result= [defaults objectForKey:key];
    if(!result){
        result = nil;
    }
    return result;
}



@end
