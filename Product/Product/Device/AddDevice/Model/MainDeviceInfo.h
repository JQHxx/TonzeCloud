//
//  MainDeviceInfo.h
//  JinAnSecurity
//
//  Created by AllenKwok on 15/10/20.
//  Copyright © 2015年 JinAn. All rights reserved.
//
//主机信息
#import <Foundation/Foundation.h>

#define kMainDevice @"kMainDevice"

@interface MainDeviceInfo :NSObject

/**
 *  扫描的产品ID
 */
@property (nonatomic,copy)NSString *productID;

/**
 *  扫描的设备Mac地址
 */
@property (nonatomic,copy)NSString *macAddr;

/**
 *  设备名称
 */
@property (nonatomic,copy)NSString *deviceName;

/**
 *  加入时间
 */
@property (nonatomic,copy)NSString *joinDate;

/**
 *  是否为当前主机
 */
@property (nonatomic,getter=isCurrentMainDevice)BOOL currentMainDevice;

/**
 *  json信息
 */
@property (nonatomic,copy)NSString *mainInfo;


@property (nonatomic,assign)DeviceType deviceType;


@end
