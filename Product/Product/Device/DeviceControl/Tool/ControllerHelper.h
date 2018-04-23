//
//  ControllerHelper.h
//  Product
//
//  Created by Xlink on 16/1/20.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeviceModel.h"
#import "DeviceEntity.h"

#define kOnStart                        @"kOnStart"
#define kOnGotDeviceByScan              @"kOnGotDeviceByScan"
#define kOnConnectDevice                @"kOnConnectDevice"
#define kOnHandShake                    @"kOnHandShake"
#define kOnRecvLocalPipeData            @"kOnRecvLocalPipeData"
#define kOnLogin                        @"kOnLogin"
#define kOnSubscription                 @"kOnSubscription"
#define kOnSendPipeData                 @"kOnSendPipeData"
#define kOnSendLocalPipeData            @"kOnSendLocalPipeData"
#define kOnRecvPipeData                 @"kOnRecvPipeData"
#define kOnRecvPipeSyncData             @"kOnRecvPipeSyncData"
#define kOnDataPointUpdata              @"kOnDataPointUpdata"
#define kOnDeviceStateChanged           @"kOnDeviceStateChanged"
#define kOnSetDeviceAccessKey           @"kOnSetDeviceAccessKey"
#define kOnGotSubkey                    @"kOnGotSubkey"
#define kOnAppStateChanged              @"kOnAppStateChanged"
#define kDeviceViewUpdateUI             @"kDeviceViewUpdateUI"

@interface ControllerHelper : NSObject

+(instancetype)shareHelper;

///设备连接成功，就添加到该数组
-(void)insertConnectArr:(DeviceEntity *)device;

///设备断开连接，就把设备从该数组删除
-(void)removeConnectArr:(DeviceEntity *)device;

-(int)getDeviceState:(DeviceModel *)model;

-(void)conncetDevice:(DeviceModel *)model;

-(void)controllDevice:(DeviceModel *)model;

/**
 *  设置属性
 *
 *  @param model 
 
 */
-(void)setDeviceAttribute:(DeviceModel *)model;

/**
 *  获取属性
 *
 *  @param model
 
 */
-(void)getDeviceAttribute:(DeviceModel *)model;


/**
 *  设置偏好
 *
 *  @param model
 
 */
-(void)setDevicePreference:(DeviceModel *)model;

/**
 *  获取偏好
 *
 *  @param model
 
 */
-(void)getCurrentPreference:(DeviceModel *)model;

-(void)getCurrentPreference:(DeviceModel *)model andString:(NSString *)preferenceString;

-(void)disconnectDevice:(DeviceModel *)model;

-(void)disconnectAllDevices;

-(DeviceEntity *)getNeedControllDevice:(NSString *)mac;

-(NSString *)getPreferenceName:(NSString *)name;

-(void)resteDevice:(DeviceModel *)model;

///已连接的设备数组
@property(nonatomic,strong)NSMutableArray *connectedArr;

@property(nonatomic,strong)NSTimer *overTimeTimer;

-(void)dismissProgressView;

@end
