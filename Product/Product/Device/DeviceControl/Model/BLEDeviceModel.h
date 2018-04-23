//
//  BLEDeviceModel.h
//  Product
//
//  Created by WuJiezhong on 16/6/1.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import "DeviceModel.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "BTManager.h"


///BLE蓝牙设备
@interface BLEDeviceModel : DeviceModel

@property (nonatomic, copy) NSString *_Nullable uuid;//相同的BLE设备在不同的手机上面获取到的uuid也会不相同的,弃用,现在uuid存的是设备的macAddress
//@property (nonatomic, copy) NSString *_Nullable BLEMacAddress;//设备的macAddress

@property (nonatomic, strong) CBPeripheral *_Nullable peripheral;

///是否连接
@property (nonatomic, assign) BOOL isConnected;
///连接成功
@property (nonatomic, copy) ConnectStatusChangeHandler _Nullable connectStatusChangeHandler;

@property (nonatomic, readonly) NSString *_Nullable nameFromLocal;

@property (nonatomic, readonly) NSString *_Nullable uuidFromLocal;

@property (nonatomic, readonly) NSString *_Nullable BLEMacAddressFromLocal;
//@property (nonatomic, readonly) NSString *_Nullable tempAccesskeyFromLocal;


///清除本地保存的数据
- (void)clearDeviceLocalData;
@end
