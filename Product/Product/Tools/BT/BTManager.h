//
//  BTManager.h
//  Product
//
//  Created by WuJiezhong on 16/5/25.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "DeviceModel.h"
#import "NSError+Extension.h"



@class BLEDeviceModel;
@class ThermometerModel;

///体温计连接状态
typedef NS_ENUM(NSInteger, BTConnectStatus) {
    ///蓝牙不可用, handler的peripheral参数为nil
    BTConnectStatusDisable,
    ///蓝牙可用, handler的peripheral参数为nil
    BTConnectStatusEnable,
    ///扫描中, handler的peripheral参数为nil
    BTConnectStatusScanning,
    ///取消扫描, handler的peripheral参数为nil
    BTConnectStatusCancelScanning,
    ///发现目标Peripheral，
    BTConnectStatusDiscoveredPeripheral,
    ///连接中
    BTConnectStatusConnecting,
    ///取消连接
    BTConnectStatusCancelConnecting,
    ///连接失败，handler的object参数为NSError对象
    BTConnectStatusConnectFailed,
    ///连接成功
    BTConnectStatusConnected,
    ///连接断开
    BTConnectStatusDisconnected,
    ///发现Peripheral的服务
    BTConnectStatusDiscoverServices,
    ///发现Characteristic接口
    BTConnectStatusDiscoveredChars,
    ///Notify通道激活、关闭，handler的object参数为CBCharacteristic对象
    BTConnectStatusUpdateNotification,
};


///BT错误码
typedef NS_ENUM(NSInteger, BTErrorCode) {
    //超时
    BTErrorCodeTimeout = 100,
    //连接已断开
    BTErrorCodeDisconnected = 101,
};

///获取mac地址回调
typedef void(^getMacAddressSuccessCallBack)(CBPeripheral *_Nullable peripheral, NSString *_Nullable macAddress);

/////获取手动手授权码回调
//typedef void(^getTempAccesskeyCallBack)(CBPeripheral *_Nullable peripheral, NSString *_Nullable tempAccesskey);

typedef void(^ConnectStatusChangeHandler)(CBPeripheral *_Nullable peripheral, BTConnectStatus status, id _Nullable object);

/**
 *  通知回调
 *
 *  @param data     接收的数据
 *  @param userInfo 用户数据，不同的回调数据不同
 *  @param error    错误信息，当改参数为nil时表示没有错误，错误信息比如：超时等
 *
 *  @return 返回YES为继续监听，回调将会继续；返回NO时，该callback立即销毁，不再回调
 */
typedef BOOL(^NotifyCallback)(NSData *_Nullable data, NSDictionary *_Nullable userInfo, NSError *_Nullable error);



////////////////////////////////////////////////////////////////////////////////////
@interface BTManager : NSObject

@property (nonatomic, strong) NSMutableArray *_Nonnull peripheralArray;


+ (instancetype _Nonnull)sharedManager;

+ (BOOL)isBLEEnable;

/**
 *  扫描设备
 *
 *  @param device       设备，要求mac不为空
 *  @param successBlock 扫描到设备回调，回调带返回值，如果返回YES为继续扫描，NO为停止扫描
 *  @param failBlock    扫描失败的回调
 */
+ (void)scanDevice:(BLEDeviceModel *_Nullable)device
           success:(void(^_Nullable)(BLEDeviceModel *_Nonnull)) successBlock
              fail:(void(^_Nullable)(NSError *_Nonnull)) failBlock;

///停止扫描
+ (void)stopScan;

+ (void)connect:(CBPeripheral *_Nonnull)peripheral;

+ (void)disconnect:(CBPeripheral *_Nonnull)peripheral;

+ (void)discoverServices:(CBPeripheral *_Nonnull)peripheral;

+ (NSInteger)addObsever:(CBPeripheral *_Nonnull)peripheral
     statusChangeHander:(ConnectStatusChangeHandler _Nullable)statusChanged;

+ (void)removerObsever:(NSInteger)tag;

///获取BLE设备的mac
- (void)getMacAddress:(CBPeripheral *_Nonnull)mPeripheral successBlcak:(getMacAddressSuccessCallBack _Nullable)callback;

#pragma mark - 体温计方法

///开始配对。调用此方法时，大概1s之后，需提示用户按下体温计的电源键来完成配对。callback将会在FFF1接口收到0x21之后调用
- (void)thermoStartVerify:(CBPeripheral *_Nonnull)peripheral callback:(NotifyCallback _Nullable)callback;

///用户输入配对码授权
- (void)tempStartVerifyByAccesskey:(NSString *_Nonnull)accesskey withPeripheral:(CBPeripheral *_Nonnull)peripheral;

/////设置手动授权回调
//- (void)setAccesskeyCallback:(getTempAccesskeyCallBack _Nullable)callback withPeripheral:(CBPeripheral *_Nonnull)peripheral;

///同步时钟
- (void)thermoSyncClock:(CBPeripheral *_Nonnull)peripheral callback:(NotifyCallback _Nullable)callback;

///激活/禁止实时数据通知功能
- (void)thermoEnableLiveDataNotify:(CBPeripheral *_Nonnull)peripheral enable:(BOOL)enable callback:(NotifyCallback _Nullable)callback;

/**
 *  接收/监听实时数据
 *
 *  @param peripheral <#peripheral description#>
 *  @param enable     使能
 *  @param callback   数据通知回调
 */
- (void)thermoSubscribeLiverData:(CBPeripheral *_Nonnull)peripheral enable:(BOOL)enable callback:(NotifyCallback _Nullable)callback;

///获取温度发烧的阈值
- (void)thermoSyncThresholdOfFever:(CBPeripheral *_Nonnull)peripheral callback:(NotifyCallback _Nullable)callback;

///获取温差和时间间隔
- (void)thermoSyncTemperatureDifferenceAndTimeInterval:(CBPeripheral *_Nonnull)peripheral callback:(NotifyCallback _Nullable)callback;

///获取电池电量（电池电压百分比0-100）
- (void)thermoSyncBatteryLevel:(CBPeripheral *_Nonnull)peripheral callback:(NotifyCallback _Nullable)callback;

///设置体温计的发烧阈值
- (void)setthermoThresholdOfFever:(ThermometerModel *_Nonnull)TDDevice callback:(NotifyCallback _Nullable)callback;

///设置体温计的上报温差和上报时间差
- (void)setthermoTemperatureDifferenceAndThermoTimeInterval:(ThermometerModel *_Nonnull)TDDevice callback:(NotifyCallback _Nullable)callback;

///激活/禁止历史数据同步功能
- (void)thermoEnableReceiveDeviceHistoryDataNotify:(CBPeripheral *_Nonnull)peripheral enable:(BOOL)enable callback:(NotifyCallback _Nullable)callback;

///获取历史数据
- (void)thermoReceiveDeviceHistoryDataNotify:(CBPeripheral *_Nonnull)peripheral enable:(BOOL)enable callback:(NotifyCallback _Nullable)callback;

///确认收到历史数据
- (void)thermoReceiveDeviceHistoryDataConfirm:(CBPeripheral *_Nonnull)peripheral timestamp:(UInt32)timestamp callback:(NotifyCallback _Nullable)callback;

#pragma mark - 血压计方法

///初始化血压计
- (void)bpmeterWriteInitData:(CBPeripheral *_Nonnull)peripheral;

///验证
- (void)bpmeterStartVerify:(CBPeripheral *_Nonnull)peripheral callback:(NotifyCallback _Nullable)callback;

///开始监听某个命令
- (void)bpmeterSuscribeCommandValue:(CBPeripheral *_Nonnull)peripheral command:(Byte)command callback:(NotifyCallback _Nullable)callback;

///同步日期，已经延时100ms
- (void)bpmeterSyncDate:(CBPeripheral *_Nonnull)peripheral callback:(NotifyCallback _Nullable)callback;

///同步时间，已经延时300ms
- (void)bpmeterSyncTime:(CBPeripheral *_Nonnull)peripheral callback:(NotifyCallback _Nullable)callback;

///开始读取历史记录
- (void)bpmeterReceiveDeviceHistoryDataNotify:(CBPeripheral *_Nonnull)peripheral callback:(NotifyCallback _Nullable)callback;

@end
