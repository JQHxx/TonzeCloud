//
//  NSUserDefaultInfos.h
//  CycleNav
//
//  Created by gzgamut on 13-12-15.
//  Copyright (c) 2013年 gzgamut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"


#define UIColorFromRGB(rgbValue)    [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


#define SCREEN_WIDTH  [ UIScreen mainScreen ].bounds.size.width
#define SCREEN_HEIGHT [ UIScreen mainScreen ].bounds.size.height

#define USER_NAME @"USER_NAME"
#define USER_PHONE @"USER_PHONE"
#define USER_SEX @"USER_SEX"
#define USER_HEIGHT @"USER_HEIGHT"
#define USER_AGE @"USER_AGE"

///accountID 是通过接口返回的token经过base64解密获取到(天际用户系统)
#define USER_ID @"USER_ID"

///天际系统token
#define USER_TOKEN @"USER_TOKEN"
#define USER_DIC            @"USER_DIC"        //云智易平台登录信息


#define USER_LOGIN_ACCOUNT @"USER_LOGIN_ACCOUNT"
#define LAST_USER_LOGIN_ACCOUNT @"LAST_USER_LOGIN_ACCOUNT"  //最后一次登录的账号
#define USER_WITHOUT_PASSWORD @"USER_WITHOUT_PASSWORD"   //判断用户绑定时是否需要设置密码
#define  USER_KEY @"USER_KEY"

///xlink用户系统信息

#define USER_AVATAR_URL @"USER_AVATAR_URL"  //用户头像URL
#define WARRANTY_TOKEN @"WARRANTY_TOKEN"     //延保用的token
#define XL_KEY_USER_ID  @"user_id"
#define XL_KEY_TOKEN  @"access_token"
#define XL_USER_ID      [NSUserDefaultInfos getDicValueforKey:USER_DIC][@"user_id"]
#define XL_USER_TOKEN   [NSUserDefaultInfos getDicValueforKey:USER_DIC][@"access_token"]

#define DRINK_VALUE @"DRINK_VALUE"   //每日的喝水量
#define DEFAULT_CHLORINE @"DEFAULT_CHLORINE"   //默认除氯开关
#define DEFAULT_TEM @"DEFAULT_TEM"   //默认保温温度


#define XLINK_APP_ID @"XLINK_APP_ID"
#define XLINK_AUTH_KEY @"XLINK_AUTH_KEY"

#define CURRENT_BINDING_DEVICE @"CURRENT_BINDING_DEVICE"

typedef enum MyLanguage {
    MyLanguageChineseSimplified = 0,
    MyLanguageEnglish,
    MyLanguageChineseTraditional,
    MyLanguageFrench,
    MyLanguageItalian,
    MyLanguageRussian,
    MyLanguageSpanish,
    MyLanguagePortuguese,
    MyLanguageGerman
} MyLanguage;



@interface NSUserDefaultInfos : NSObject

+(void)putKey:(NSString *)key anddict:(NSObject *)value;

+(void)putKey:(NSString *)key andValue:(NSObject *)value;

+(void)putKey:(NSString *)key andImage:(UIImage * )image;

+(void)putInt:(NSString *)key andValue:(int)value;

+(UIImage *)getImageValueforKey:(NSString *)key;

+(int)getIntValueforKey:(NSString *)key;

+(NSString *)getValueforKey:(NSString *)key;

+(NSDictionary *)getDicValueforKey:(NSString *)key;

+(NSString *)getCurrentDate;

+(NSTimeInterval )getDateIntervalWithHour:(NSInteger )hour Min:(NSInteger )min;  //输入小时和分钟获取到当前时间的秒数，如在当前时间之前则计算到下一天的秒数，用于预约启动

+(NSString*)getDateStrWithDate:(NSDate*)date;

+(NSString*)getTimeSP;////////////获取时间戳

+(NSString *)getAgeFromBirthYear:(NSString *)year;   //根据出生年获取年龄

+(NSString *)getBirthYearFromAge:(NSString *)age;   //根据年龄获取出生年

+(NSString *)getMonthStrFromCurrentDate;    //获取当前月份的字符串

+(void)removeObjectForKey:(NSString *)key;


+(id )getValueforIdKey:(NSString *)key;



@end
