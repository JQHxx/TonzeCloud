//
//  Shop_DBController.h
//  Order
//
//  Created by wzy on 28/3/17.
//  Copyright © 2017年 wzy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QLDBController.h"
#import "BLEDeviceModel.h"
#import "DeviceModel.h"

@interface BLEDevice_DBController : QLDBController

/**
 *  插入数据
 */
- (void)insertBLEDevice:(BLEDeviceModel *)model;

/**
 *  返回列表
 */
-(NSArray *)getAllBLEDevice;

/**
 *  获取Device
 *
 *  @return 返回Device
 */
-(BLEDeviceModel *)getBLEDevice:(NSString *)deviceName;

/**
 *  删除设备
 */
-(void)deleteBLEDevice:(NSString *)deviceName;

/**
 *  删除数据
 */
- (void)deleteBLEDevice;

@end
