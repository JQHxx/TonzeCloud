//
//  DeviceHelper.h
//  Product
//
//  Created by Xlink on 15/12/30.
//  Copyright © 2015年 TianJi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeviceEntity.h"
#import "DeviceModel.h"

@class MeasurementsModel;

@interface DeviceHelper : NSObject

/**
 *  获取设备类型  返回int
 */
+(int)getDeviceTypeWithMac:(NSString *)mac;


+(DeviceType)getDeviceTypeWithProductID:(NSString *)productID;

/**
 *  获取设备类型  返回String
 */
+(NSString *)getDeviceTypeStrWithMac:(NSString *)mac;

/**
 *  获取设备名称
 */
+(NSString *)getDeviceName:(DeviceEntity *)device;

///通过云端的用户历史记录MeasurementsModel获取蓝牙设备的名称，名称为空则通过设备类型返回默认名称
+(NSString *)getBLEDeviceName:(MeasurementsModel *)measurement;

///获取产品默认的名字
+ (NSString *)productDefaultName:(NSString *)productID;
+ (NSString *)productHelpDefaultName:(NSString *)productID ;
/**
 *  获取推送类型
 */
+(NSString *)getDevicePustNotiWithType:(int)type;
+(NSString *)cookFoodgetDevicePustNotiWithType:(int)type;
/**
 *  获取更新数据dic 暂不用
 */
+(NSDictionary *)getDeviceDictionary:(NSDictionary *)dic;


/**
 *  根据model获取dic
 *
 *  @param model model
 *
 *  @return dic
 */
+(NSDictionary *)getDeviceDictionaryFromModel:(DeviceModel *)model;

/**
 *  根据mac获取设备列表  用，隔开
 */
+(NSArray *)getDeviceListArray:(NSString*)ArrayStr;

/**
 *  保存设备到本地
 */
+(void)saveDeviceToLocal:(DeviceEntity *)device;


/**
 *  保存设备列表到本地 ,list里面为设备字典
 *
 *  @param list 设备字典
 */
+(void)saveDeviceListToLocal:(NSMutableArray *)list;

/**
 *  根据mac获取本地设备
 */
+(DeviceEntity *)getDeviceFromLocalWithMacAddr:(NSString *)macAddr;

/**
 *  获取本地设备
 */
+(NSArray *)getAllDeviceFromLocal;

/**
 *  保存设备类型到本地
 */
+(void)putFeedbackDeviceToLocal:(NSString *)macAddress Data:(NSData*)data;


/**
 *  根据返回信息设置model state 字典
 */
+(NSMutableDictionary *)getStateDicWithDevice:(DeviceEntity *)device Data:(NSData *)data;


/**
 *  根据阶段命令判断阶段名称
 */

+(NSString *)getCloudCookerProgressStrWithProgress:(NSString *)progress;


+(NSString *)getElectricCookerProgressStrWithProgress:(NSString *)progress;

+(NSString *)getWaterCookerProgressStrWithProgress:(NSString *)progress;

+(NSString *)getWaterCooker16AIGProgressStrWithProgress:(NSString *)progress;

+(NSString *)getCloudKettleProgressStrWithProgress:(NSString *)progress;

+(NSString *)getCookFoodProgressStrWithProgress:(NSString *)progress;
/**
 *  根据mac删除本地设备
 */
+(void)deleteDeviceFromLocal:(NSString*)mac;

/**
 *  根据从服务器上获取的列表转化成可用的dic数组
 *
 *  @param list 列表
 *
 *  @return dic arr
 */
+(NSMutableArray *)getDeviceDicList:(NSArray *)list;

/**
 *  根据deviceID获取设备类型
 *
 *  @param deviceID deviceID
 *
 *  @return 设备类型
 */
+(NSString *)getDeviceTypeFromDeviceID:(NSNumber *)deviceID;

+ (void)removeRemindsOfMac:(NSString *)mac;

//设置一段文本的位置的字体大小、偏移水平基线的位置 （number大于0偏上）
+ (void)setTextOnRange:(NSRange)range onLabel:(UILabel *)label toFont:(UIFont *)font andBaselineOffset:(NSNumber *)number;


@end
