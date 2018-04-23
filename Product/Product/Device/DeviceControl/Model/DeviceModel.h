//
//  DeviceModel.h
//  Product
//
//  Created by Xlink on 15/12/3.
//  Copyright © 2015年 TianJi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class DeviceEntity;

enum{
    ELECTRIC_COOKER=0,      //电饭煲
    CLOUD_COOKER=1,         //云炖锅
    WATER_COOKER=2,         //隔水炖
    CLOUD_KETTLE=3,         //私享壶
    SCALE=4,                //秤
    COOKFOOD_KETTLE=5,      //炒菜锅
    THERMOMETER = 6,        //体温计
    WATER_COOKER_16AIG = 7, //隔水炖16AIG
    BPMETER = 8,            //血压计
    CABINETS =9,            //智能厨物柜
    NutritionScale =10,     //营养秤

}TYPE_DEVICE;

///设备类型
typedef NS_ENUM(NSInteger, DeviceType) {
    ///隔水炖
    DeviceTypeWaterCooker    = WATER_COOKER,
    ///隔水炖16AIG
    DeviceTypeWaterCooker16AIG    = WATER_COOKER_16AIG,
    ///电饭煲
    DeviceTypeElectricCooker = ELECTRIC_COOKER,
    ///云炖锅
    DeviceTypeCloudCooker    = CLOUD_COOKER,
    ///私享壶
    DeviceTypeCloudKettle    = CLOUD_KETTLE,
    ///炒菜锅
    DeviceCookFood         = COOKFOOD_KETTLE,
    ///电子秤
    DeviceTypeScale          = SCALE,
    ///血压计
    DeviceTypeBPMeter        = BPMETER,
    ///体温计
    DeviceTypeThermometer    = THERMOMETER,
    ///厨物柜
    DeviceTypeCaninets       = CABINETS,
    ///营养秤
    DeviceTypeNutritionScale = NutritionScale,
    ///未知设备
    DeviceTypeUnknow,
};


@interface DeviceModel : NSObject
/**
 *  菜谱名字
 */
@property (nonatomic,copy)NSString *FoodMenuName;
/**
 *  时间
 */
@property (nonatomic,copy)NSString *time;
/**
 *  已授权用户
 */

@property (nonatomic,retain)NSMutableArray *authUser;
/**
 *  设备类型
 */
@property (nonatomic)NSInteger deviceType;
/**
 *  设备名字
 */
@property (nonatomic,copy)NSString *deviceName;

/**
 *  设备ID
 */
@property (nonatomic ,assign)int deviceID;

@property (nonatomic, strong) NSString *accessKey;

/**
 *  是否在线
 */
@property (nonatomic)BOOL isOnline;

/**
 *  当前状态 ：空闲，精华煮。。。。
 */
@property (nonatomic) NSMutableDictionary *State;

/**
 *  私享壶花茶属性
 */
@property (nonatomic ,assign)BOOL isTea;


/**
 *  设备属性  （后加，只适用于私享壶,属性只有保温属性和煮水属性）
 */
@property (nonatomic) NSMutableDictionary *Attribute;

@property (nonatomic,copy)NSString *mac;  //秤的mac为UUID

@property (nonatomic, copy) NSString *BLEMacAddress;//设备的macAddress

@property (nonatomic,copy)NSString *productID;
@property (nonatomic,assign)NSInteger role;   //0-管理员，，，1-非管理员

///是否是管理员
@property (nonatomic, assign, readonly) BOOL isAdmin;

+(NSDictionary *)getModelDictionary:(DeviceModel *)model;

- (instancetype)initWithDictionary:(NSDictionary *)dict deviceType:(DeviceType)type;

- (UIImage *)tableViewIconImage;

///取消订阅设备
- (void)unsubscribeWithUserID:(NSNumber *)userID accessToken:(NSString *)token result:(void(^)(NSError *error))callback;

- (instancetype)initWithDeviceEntity:(DeviceEntity *)deviceEntity;

@end
