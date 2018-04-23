//
//  DeviceConnectStateCheckService.h
//  Product
//
//  Created by WuJiezhong on 16/6/30.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeviceEntity.h"
@class DeviceModel;

@interface DeviceConnectStateCheckService : NSObject

@property (atomic, strong) NSMutableArray *devices;

@property (nonatomic, assign) BOOL isStart;

+ (instancetype)share;

- (void)start;

- (void)startIfNecessary;

- (void)addDevice:(DeviceEntity *)device;

- (void)removeDevice:(DeviceEntity *)device;

- (void)timerElapsed:(NSTimer *)timer;

- (void)stop;

- (DeviceEntity *)getDeviceFromeControllerHelper:(DeviceEntity *)device;

///从需要连接的WiFi设备列表中获取XLink设备模型
- (DeviceEntity *)getDeviceFromeDeviceModel:(DeviceModel *)device;

@end
