//
//  StorageDeviceHelper.h
//  Product
//
//  Created by vision on 17/6/13.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <Foundation/Foundation.h>


#define kStorageRuleId  @"59423c237e33a5e35f69039c"

typedef enum : NSUInteger {
    StorageDeviceSendTypeHumidity,       //设置储物区湿度
    StorageDeviceSendTypeTemperature,    //设置储物区温度
    StorageDeviceSendTypeOutRice,        //设置储米量
    StorageDeviceSendTypeGetHumidity,     //获取储物区湿度
    StorageDeviceSendTypeGetTemperature,  //获取储物区温度
    StorageDeviceSendTypeGetOutRice,      //获取出米量
    StorageDeviceSendTypeGetOfflineOutRice,      //获取离线出米记录
    StorageDeviceSendTypeDeleteOfflineOutRice,      //删除离线出米记录
} StorageDeviceSendType;

@interface StorageDeviceHelper : NSObject

singleton_interface(StorageDeviceHelper)


@property (nonatomic,assign)int       device_id;
@property (nonatomic,assign)BOOL      isStorageFoodRefresh;    //刷新储物区食材列表
@property (nonatomic,assign)BOOL      isStorageHomereFresh;

/**
 *  设置储物区湿度、温度和出米量
 *
 *  @param mac      设备mac地址
 *  @param sendType 发送指令类型
 *  @param value    设置值
 */
-(void)storageDeviceMac:(NSString *)mac SendDataForType:(StorageDeviceSendType)sendType withValue:(NSInteger)value;


-(NSString *)getCabinetStateWithType:(NSInteger)workType;

@end
