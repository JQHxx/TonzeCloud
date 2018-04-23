//
//  DeviceAliveChecker.h
//  Product
//
//  Created by WuJiezhong on 16/6/16.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeviceModel.h"

typedef BOOL(^ListenerStateChanged)(DeviceModel *device, NSInteger state, NSError *error);

@interface DeviceStateListener : NSObject

+ (instancetype)sharedListener;

//连接成功的设备都添加到了这个服务中，进行状态监测
- (NSNumber *)listenForDevice:(DeviceModel *)device stateChangeHandler:(ListenerStateChanged)handler;

- (void)removeDevice:(DeviceModel *)device;

- (void)removeListener:(NSNumber *)tag;

- (void)removeAllDeviceStateCheckService;

@end
