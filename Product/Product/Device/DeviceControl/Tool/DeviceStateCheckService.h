//
//  DeviceStateCheckService.h
//  Product
//
//  Created by WuJiezhong on 16/6/16.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeviceModel.h"

//DeviceEntity连接成功，一个DeviceModel创建一个DeviceStateCheckService，start，3次超时则stop并且通过CheckServiceHandler返回超时200，CheckServiceHandler重连

typedef void(^CheckServiceHandler)(DeviceModel *device, NSInteger state, NSError *error);


@interface DeviceStateCheckService : NSObject


@property (nonatomic, strong) DeviceModel *device;

@property (nonatomic, copy) CheckServiceHandler handler;


- (instancetype)initWithDevice:(DeviceModel *)device;

- (void)start;

- (void)stop;

@end
