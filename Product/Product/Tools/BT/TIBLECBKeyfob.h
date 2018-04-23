//
//  TIBLECBKeyfob.h
//  TI-BLE-Demo
//
//  Created by Ole Andreas Torvmark on 10/31/11.
//  Copyright (c) 2011 ST alliance AS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreBluetooth/CBService.h>
#import "TIBLECBKeyfobDefines.h"
#import <UIKit/UIKit.h>

@class AppDelegate;

#define CONNECT_ERROR_SECONDS 6  //连接允许的误差时间。即6秒内若连接断开则重连一次
#define CONNECT_STABLE_SECONDS 2 //连接上之后等待稳定的时间，稳定后再获取服务。因为第一次连接蓝牙时会不稳定

@protocol TIBLECBKeyfobDelegate <NSObject>
@optional
//- (void)connectSuccess;  //当蓝牙连接成功时发出提醒
//- (void)disconnect;      //当蓝牙断开连接时发出提醒
-(void)scanOverTime;///搜索超时

@required
-(void)startScanWithMsg:(NSDictionary *)dic;
- (void)receiveHistoryData:(NSData *)data withUUID:(NSString*)uuid;  //数据获取
-(void)BTStateChange:(CBCentralManagerState)state;  //蓝牙状态改变
-(void)didDiscoverDeivce:(NSDictionary*)deviceDic;  //扫描到设备，返回一个词典
-(void)DeviceStateChange:(int)state;  //状态改变   0:connecting    1:connected  2:disconnected 3:sanning 

@end


@interface TIBLECBKeyfob : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate> {
    NSTimer *scanTimer, *connectTimer;  //前者用于扫描设备；后者用于记录连接时间
    
    int connectSeconds;  //已连接秒数
    AppDelegate *appDelegate;
    
    int closestDeviceIndex;  //距离手机最近的设备下标（在peripherals中的下标）
}

@property BOOL reminderSet;
@property (nonatomic)BOOL scanning;  //是否正在扫描
@property (nonatomic)BOOL NeedConnect;  //需要连接上才能获取数据，有些设备不需要
@property (nonatomic)BOOL justScan;  //仅扫描

@property (nonatomic,assign) id <TIBLECBKeyfobDelegate> delegate;
@property (strong, nonatomic)  NSMutableArray *peripherals;
@property (strong, nonatomic) NSString *DeviceName;
@property (strong, nonatomic) NSString *BindingUUID;
@property (strong, nonatomic) CBCentralManager *CM; 
@property (strong, nonatomic) CBPeripheral *activePeripheral;
@property (strong, nonatomic) CBPeripheral *boundPeripheral;
@property (strong, nonatomic) UIButton *TIBLEConnectBtn;

-(void) initConnectButtonPointer:(UIButton *)b;

-(void) startScaleProxy:(CBPeripheral *)p;


-(void) writeValue:(int)serviceUUID characteristicUUID:(int)characteristicUUID  p:(CBPeripheral *)p data:(NSData *)data;
-(void) writeValueWithOutResponse:(int)serviceUUID characteristicUUID:(int)characteristicUUID p:(CBPeripheral *)p data:(NSData *)data;

-(int) controlSetup:(int) s;
-(int) findBLEPeripherals:(int) timeout;
-(void) scanTimer:(NSTimer *)timer;
-(void) connectPeripheral:(CBPeripheral *)peripheral;
-(UInt16) CBUUIDToInt:(CBUUID *) UUID;
- (const char *) centralManagerStateToString: (int)state;

-(void)sendPersonInfoToScale;

@end
