//
//  UIDevice+Extend.h
//  ThumbLocker
//
//  Created by Magic on 16/3/29.
//  Copyright © 2016年 VisionChina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDevice (Extend)


+(NSString *)getSoftwareVer;

+(NSString *)getPhoneModel;

+(NSString *)getLanguage;

+(NSString *)getCountry;

+(NSString *)getIDFA;

+(BOOL)isCharging;

+(float)screenLight;

+(double)getUpTime;

+(float)diskTotalSpace;

+(float)diskFreeSpace;

+ (NSString *)iphoneType;

+ (NSString *)getSystemName;

+ (NSString *)getSystemVersion;

+(NSString *)getIDFV;

+ (NSString *)generateUUID;

+(NSString *)getNetworkType;







@end
