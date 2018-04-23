//
//  iFreshSDK.h
//  iFreshSDK
//
//  Created by zhang on 16/9/9.
//  Copyright © 2016年 taolei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iFreshModel.h"

typedef enum : NSUInteger {
    
    UNIT_g = 0,
    UNIT_ml,
    UNIT_lb,
    UNIT_oz
    
} GN_UnitEnum;


typedef enum : NSUInteger {
    
    bleOpen  = 0,
    bleOff,
    bleConnect,
    bleBreak
    
} GN_BleStatus;

@protocol BleReturnValueDelegate <NSObject>
/**
 *  GlobalBLEmodel模型：value ble返还数值；
 *
 *  @param globalBLEmodel 全局蓝牙模型数据
 */
@optional
- (void)bleReturnValueModel:(iFreshModel*)globalBLEmodel;

/**
 * 称端切换单位触发的代理方法
 * GN_UnitEnum 单位枚举
 * unitChange   切换后的单位(获取当前称端单位，枚举类型)
 */
@optional
- (void)changeUnitWithBle:(GN_UnitEnum) unitChange;

/**
 * 蓝牙连接状态改变的代理方法
 * GN_BleStatus 蓝牙状态枚举
 * bleStatus   当前蓝牙状态
 */
@optional

- (void)bleStatusupdate:(GN_BleStatus)bleStatus; 

@end

@interface iFreshSDK : NSObject

/// 是否链接上蓝牙
@property (nonatomic, assign) BOOL isBle_Link;


/// 称单位枚举
@property (nonatomic, assign) GN_UnitEnum unitEnum;

/**
 *  shareManager 单例，所有的方法调用
 */
+ (instancetype)shareManager;

/**
 *  Start Scan，建议放在程序入口
 */
- (void)bleDoScan;

/*
 *  Stop Scan
 */
- (void)stopBleScan;

/**
 * DisConnect（断开连接并停止扫描，如需要重新启动扫描设备，请调用bleDoScan方法）
 */
- (void)closeBleAndDisconnect;

/**
 * 遵循协议的调用
 */
- (void)setbleReturnValueDelegate:(id<BleReturnValueDelegate>)delegate;

/**
 * insertTheUnit 插入单位
 *
 * @param unit 根据GN_UnitEnum枚举写入单位
 */
- (void)insertTheUnit:(GN_UnitEnum )unit;

/**
 *  Zero  归零写入
 */
- (void)zeroWriteBle;



@end
