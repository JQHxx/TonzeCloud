//
//  BTManager.m
//  Product
//
//  Created by WuJiezhong on 16/5/25.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import "BTManager.h"
#import "ThermometerModel.h"
#import "BPMeterModel.h"
#import "NSData+Extension.h"
#import "NSString+Extension.h"
#import "NSDate+Extension.h"
#import "AppDelegate.h"


#define TONZE_TWJ_NAME @"TONZE-TWJ"
#define TWJ_SERVICE_UUID @"FFF0"

#define BPM_NAME @"ClinkBlood"
#define BPM_SERVICE_UUID @"FC00"

///1.通知和返回
#define TWJ_CHAR_FEEDBACK        @"FFF1"
///2.验证
#define TWJ_CHAR_VERIFY          @"FFF2"
///3.历史数据
#define TWJ_CHAR_HISTORICAL_DATA @"FFF3"
///4.实时数据
#define TWJ_CHAR_LIVE_DATA       @"FFF4"
///5.配置
#define TWJ_CHAR_CONFIG          @"FFF5"

#define BPM_CHAR_FCA0       @"FCA0"
#define BPM_CHAR_NOTIFY     @"FCA1"
#define BPM_CHAR_FCA2       @"FCA2"

///写入配置数据超时时间
#define CONFIG_TIME_OUT 5
///配对超时时间
#define VERIFY_TIME_OUT 30

typedef NS_ENUM(NSInteger, TMPCharType) {
    TMPCharTypeFeedback = 0xFFF1,
    TMPCharTypeVerify   = 0xFFF2,
    TMPCharTypeHistData = 0xFFF3,
    TMPCharTypeLiveData = 0xFFF4,
    TMPCharTypeConfig   = 0xFFF5,
    
};


typedef void(^ScanSuccessBlock)(BLEDeviceModel *_Nonnull);
typedef void(^ScanFailBlock)(NSError *_Nonnull);

@interface BTManager()<CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, strong) CBCentralManager *centralManager;

@property (nonatomic, strong) dispatch_queue_t global_queue;

@property (nonatomic, copy) ScanSuccessBlock scanSuccessBlock;
@property (nonatomic, copy) ScanFailBlock scanFailBlock;
@property (nonatomic, copy) void(^btUpdateState)(CBCentralManagerState state);
@property (nonatomic, strong) BLEDeviceModel *deviceForScan;

///监听器的字典，key为监听器tag，value为Peripheral的UUID
@property (nonatomic, strong) NSMutableDictionary *obseverUUIDDict;

///状态通知的回调字典，key为监听器tag，value为ConnectStatusChangeHandler类型的block
@property (nonatomic, strong) NSMutableDictionary *statusChangedHandlerDict;

///key为callback的tag，value为callback
@property (nonatomic, strong) NSMutableDictionary *tagToCallbackDict;
///key为callback的tag，value为characteristic的UUID
@property (nonatomic, strong) NSMutableDictionary *tagToCharUUIDDict;
///key为callback的tag，value为peripheral的UUID
@property (nonatomic, strong) NSMutableDictionary *tagToPeriUUIDDict;
///key为callback的tag，value为通知数据的类型ID
@property (nonatomic, strong) NSMutableDictionary *tagToNotifyIDDict;

///key为peripheral的UUID，value为getMacAddressSuccessCallBack
@property (nonatomic, strong) NSMutableDictionary *uuidToGetMacAddressSuccessCallBackDict;
/////key为peripheral的UUID，value为GetTempAccesskeyCallback
//@property (nonatomic, strong) NSMutableDictionary *uuidToGetTempAccesskeyCallBackDict;

@end



/////////////////////////////////////////////////////////////////////////////////
@implementation BTManager

static BTManager *_sharedManager;
static NSInteger uuidTag = 1;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _global_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:_global_queue];
        
        _peripheralArray   = @[].mutableCopy;
        _obseverUUIDDict   = @{}.mutableCopy;
        _tagToCallbackDict = @{}.mutableCopy;
        _tagToPeriUUIDDict = @{}.mutableCopy;
        _tagToCharUUIDDict = @{}.mutableCopy;
        _tagToNotifyIDDict = @{}.mutableCopy;
        _statusChangedHandlerDict = @{}.mutableCopy;
        _uuidToGetMacAddressSuccessCallBackDict = @{}.mutableCopy;
//        _uuidToGetTempAccesskeyCallBackDict = @{}.mutableCopy;
    }
    return self;
}

+ (instancetype)sharedManager {
    if (!_sharedManager) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _sharedManager = [[BTManager alloc] init];
        });
    }
    
    return _sharedManager;
}

+ (NSInteger)addObsever:(CBPeripheral *_Nonnull)peripheral
     statusChangeHander:(ConnectStatusChangeHandler _Nullable)statusChanged {
    if (peripheral) {
        BTManager *bt = [BTManager sharedManager];
        bt.obseverUUIDDict[@(uuidTag)]          = peripheral.identifier.UUIDString;
        bt.statusChangedHandlerDict[@(uuidTag)] = statusChanged;
    }
    
    return uuidTag++;
}

+ (void)removerObsever:(NSInteger)tag {
    BTManager *bt = [BTManager sharedManager];
    [bt.obseverUUIDDict removeObjectForKey:@(tag)];
    [bt.statusChangedHandlerDict removeObjectForKey:@(tag)];
}

- (void)callHandlerFor:(CBPeripheral *)peripheral status:(BTConnectStatus)status object:(id)object {
    NSString *uuid = peripheral.identifier.UUIDString;
    
    for (id obseverObj in _obseverUUIDDict.allKeys) {
        
        //如果UUID为nil或UUID匹配，则调用handler
        if (!uuid || [_obseverUUIDDict[obseverObj] isEqualToString:uuid]) {
            //调用监听器
            ConnectStatusChangeHandler statusChangedHandler = _statusChangedHandlerDict[obseverObj];
            if (statusChangedHandler) {
                statusChangedHandler(peripheral, status, object);
            }
        }
    }
}

#pragma mark - public methods

+ (BOOL)isBLEEnable {
    return [BTManager sharedManager].centralManager.state == CBCentralManagerStatePoweredOn;
}

+ (void)scanDevice:(BLEDeviceModel *_Nullable)device
           success:(ScanSuccessBlock _Nullable) successBlock
              fail:(ScanFailBlock _Nullable) failBlock {
    
    BTManager *bt = [BTManager sharedManager];
    bt.scanSuccessBlock = successBlock;
    bt.scanFailBlock    = failBlock;
    bt.deviceForScan    = device;
    [bt.peripheralArray removeAllObjects];
    
    CBCentralManager *central = bt.centralManager;
    if (central.state == CBCentralManagerStateUnknown || central.state == CBCentralManagerStatePoweredOff) {    //蓝牙不可用
        __block typeof(bt) weakbt = bt;
        bt.btUpdateState = ^(CBCentralManagerState state) {
            if (central.state == CBCentralManagerStatePoweredOn) {
                NSLog(@"开始扫描...");
                [weakbt callHandlerFor:nil status:BTConnectStatusScanning object:nil];
                [central scanForPeripheralsWithServices:nil options:nil];
                weakbt.btUpdateState = nil;
            }
        };
    } else if (central.state == CBCentralManagerStatePoweredOn) {
        NSLog(@"开始扫描...");
        [bt callHandlerFor:nil status:BTConnectStatusScanning object:nil];
        [central scanForPeripheralsWithServices:nil options:nil];
    }
    
}

+ (void)stopScan {
    BTManager *bt = [BTManager sharedManager];
    [bt callHandlerFor:nil status:BTConnectStatusCancelScanning object:nil];
    [bt.centralManager stopScan];
}

+ (void)connect:(CBPeripheral *)peripheral {
    NSLog(@"连接 “%@”...", peripheral.name);
    [[BTManager sharedManager] callHandlerFor:peripheral status:BTConnectStatusConnecting object:nil];
    [[BTManager sharedManager].centralManager connectPeripheral:peripheral options:nil];
}

+ (void)disconnect:(CBPeripheral *)peripheral {
    NSLog(@"断开与“%@”的连接",peripheral.name);
    [[BTManager sharedManager].uuidToGetMacAddressSuccessCallBackDict removeObjectForKey:peripheral.identifier.UUIDString];
//    [[BTManager sharedManager].uuidToGetTempAccesskeyCallBackDict removeObjectForKey:peripheral.identifier.UUIDString];
    [[BTManager sharedManager].centralManager cancelPeripheralConnection:peripheral];
}

+ (void)discoverServices:(CBPeripheral *)peripheral {
    peripheral.delegate = [BTManager sharedManager];
    [peripheral discoverServices:nil];
}


#pragma mark - CBCentralManager delegate

///状态改变
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if (self.btUpdateState) {
        self.btUpdateState(central.state);
    }
    if (central.state == CBCentralManagerStatePoweredOn) {
        [[BTManager sharedManager] callHandlerFor:nil status:BTConnectStatusEnable object:nil];
    } else {
        [[BTManager sharedManager] callHandlerFor:nil status:BTConnectStatusDisable object:nil];
    }
}

///发现设备
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    
    NSLog(@"发现一个设备：%@\n", peripheral.name);
    NSLog(@"UUID:%@", peripheral.identifier.UUIDString);
//    NSLog(@"\n");//DE:BC:9A:56:34:12
                   //C6:05:04:03:5C:52
    //20:91:48:66:41:fc
    //20:91:48:66:41:FC
    
    NSString *uuid = peripheral.identifier.UUIDString;
    
    __weak typeof(self) weakSelf = self;
    
    if (_deviceForScan) {
        //处于连接设备阶段
        if (_deviceForScan.uuid) {
            //存在uuid
            if ([_deviceForScan.uuid isEqualToString:uuid]) { //正是要扫描的设备
                [self.peripheralArray addObject:peripheral];
                _deviceForScan.peripheral = peripheral;
                
                [self callHandlerFor:peripheral status:BTConnectStatusDiscoveredPeripheral object:nil];
                
                self.scanSuccessBlock(_deviceForScan);
                ///停止扫描
                [BTManager stopScan];
            }
        }else if (_deviceForScan.BLEMacAddress){
            if (([_deviceForScan.productID isEqualToString:CLINK_BPM_PRODUCT_ID] && [self isBPMeter:peripheral]) || ([_deviceForScan.productID isEqualToString:THERMOMETER_PRODUCT_ID] && [self isThermometer:peripheral])) {
                //不存在uuid，存在BLEMacAddress,获取当前设备的mac,再比较
                [self getMacAddress:peripheral successBlcak:^(CBPeripheral * _Nullable peripheral, NSString * _Nullable macAddress) {
                    if ([weakSelf.deviceForScan.BLEMacAddress isEqualToString:macAddress]) {
                        [weakSelf.peripheralArray addObject:peripheral];
                        weakSelf.deviceForScan.peripheral = peripheral;
                        weakSelf.deviceForScan.uuid = peripheral.identifier.UUIDString;
                        
                        [weakSelf callHandlerFor:peripheral status:BTConnectStatusDiscoveredPeripheral object:nil];
                        
                        weakSelf.scanSuccessBlock(_deviceForScan);
                        ///停止扫描
                        [BTManager stopScan];
                    }
                }];
            }
        }
        return;
    } else {
        //处于添加扫描阶段
        if ([peripheral.name isEqualToString:TONZE_TWJ_NAME]) {
            [self.peripheralArray addObject:peripheral];
            
            ThermometerModel *device = [[ThermometerModel alloc] init];
            device.peripheral = peripheral;
//            device.deviceName = peripheral.name;
            device.deviceName = @"蓝牙智能体温贴";
            device.uuid       = uuid;
            device.deviceType = DeviceTypeThermometer;
            
            [self callHandlerFor:peripheral status:BTConnectStatusDiscoveredPeripheral object:nil];
            
            self.scanSuccessBlock(device);
            
        } else if ([peripheral.name isEqualToString:BPM_NAME]) {
            [self.peripheralArray addObject:peripheral];
            
            BPMeterModel *device = [[BPMeterModel alloc] init];
            device.peripheral = peripheral;
//            device.deviceName = peripheral.name;
            device.deviceName = @"蓝牙智能血压计";
            device.uuid       = uuid;
            device.deviceType = DeviceTypeBPMeter;
            
            [self callHandlerFor:peripheral status:BTConnectStatusDiscoveredPeripheral object:nil];
            self.scanSuccessBlock(device);
        }
    }
}

- (void)scanPeripheral:(CBPeripheral *)peripheral withMac:(NSString *)macString{
    if (_deviceForScan) {
        if ([_deviceForScan.uuid isEqualToString:macString]) { //正是要扫描的设备
            [self.peripheralArray addObject:peripheral];
            _deviceForScan.peripheral = peripheral;
            
            [self callHandlerFor:peripheral status:BTConnectStatusDiscoveredPeripheral object:nil];
            
            self.scanSuccessBlock(_deviceForScan);
            ///停止扫描
            [BTManager stopScan];
        }
        return;
    } else {
        if ([peripheral.name isEqualToString:TONZE_TWJ_NAME]) {
            [self.peripheralArray addObject:peripheral];
            
            ThermometerModel *device = [[ThermometerModel alloc] init];
            device.peripheral = peripheral;
            device.deviceName = peripheral.name;
            device.uuid       = macString;
            device.deviceType = DeviceTypeThermometer;
            
            [self callHandlerFor:peripheral status:BTConnectStatusDiscoveredPeripheral object:nil];
            
            self.scanSuccessBlock(device);
            
        } else if ([peripheral.name isEqualToString:BPM_NAME]) {
            [self.peripheralArray addObject:peripheral];
            
            BPMeterModel *device = [[BPMeterModel alloc] init];
            device.peripheral = peripheral;
            device.deviceName = peripheral.name;
            device.uuid       = macString;
            device.deviceType = DeviceTypeBPMeter;
            
            [self callHandlerFor:peripheral status:BTConnectStatusDiscoveredPeripheral object:nil];
            self.scanSuccessBlock(device);
        }
    }
}

///连接了设备
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"已连接：“%@”", peripheral.name);
    [self callHandlerFor:peripheral status:BTConnectStatusConnected object:nil];
    
    ///扫描服务
    peripheral.delegate = [BTManager sharedManager];
    [peripheral discoverServices:nil];
    
    ///(获取BLE的mac)2.扫描服务UUID:180A
    if ([_uuidToGetMacAddressSuccessCallBackDict.allKeys containsObject:peripheral.identifier.UUIDString]) {
        NSLog(@"(获取BLE的mac)2.扫描服务UUID:180A");
        CBUUID *macServiceUUID = [CBUUID UUIDWithString:@"180A"];
        [peripheral discoverServices:@[macServiceUUID]];
    }

}

///连接失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"连接失败：%@", error.localizedDescription);
    [self callHandlerFor:peripheral status:BTConnectStatusConnectFailed object:error];
}

///断开了连接
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    if(error) {
        NSLog(@"连接断开：%@", error.localizedDescription);
    }
    [self callHandlerFor:peripheral status:BTConnectStatusDisconnected object:nil];
    
    ///给所有callback发送“连接已断开”的错误
    for (id tag in _tagToPeriUUIDDict.allKeys) {
        if ([_tagToPeriUUIDDict[tag] isEqualToString:peripheral.identifier.UUIDString]) {
            NotifyCallback callback = _tagToCallbackDict[tag];
            NSError *error = [NSError errorWithDescription:@"连接已断开" code:BTErrorCodeDisconnected];
            if (callback && !callback(nil, nil, error)) {  //返回NO说明要移除回调
                [self unregisterCallback:[tag integerValue]];
            }
        }
    }
    
    //断开
    [BTManager disconnect:peripheral];
}


#pragma mark - CGPeripheralDelegate


- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
//    NSLog(@"%s", __func__);
    
    [self callHandlerFor:peripheral status:BTConnectStatusDiscoverServices object:nil];
    
    for (CBService *service in peripheral.services) {
        NSLog(@"service UUID: %@", service.UUID.UUIDString);
        if([service.UUID.UUIDString isEqualToString:TWJ_SERVICE_UUID]) { //体温计的自定义服务
            [peripheral discoverCharacteristics:nil forService:service];
        } else if ([service.UUID.UUIDString isEqualToString:BPM_SERVICE_UUID]) { //血压计的自定义服务
            [peripheral discoverCharacteristics:nil forService:service];
        }
    }
    
    ///(获取BLE的mac)3.查询当前服务的特征Charcteristis
    if (peripheral.services.count) {
        if ([_uuidToGetMacAddressSuccessCallBackDict.allKeys containsObject:peripheral.identifier.UUIDString]) {
            NSLog(@"(获取BLE的mac)3.查询当前服务的特征Charcteristis");
            //发送180A返回的CBService
//            CBService *service = peripheral.services.firstObject;
//            //发送查询服务特征为2A23的特征
//            CBUUID *macCharcteristicUUID = [CBUUID UUIDWithString:@"2A23"];
//            [peripheral discoverCharacteristics:@[macCharcteristicUUID] forService:service];
            for (CBService *service in peripheral.services) {
                //发送查询服务特征为2A23的特征
                CBUUID *macCharcteristicUUID = [CBUUID UUIDWithString:@"2A23"];
                [peripheral discoverCharacteristics:@[macCharcteristicUUID] forService:service];
            }
        }
    }

}

//发现到特定蓝牙设备时调用
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
//    NSLog(@"%s", __func__);
    
    [self callHandlerFor:peripheral status:BTConnectStatusDiscoveredChars object:service];
    
    if([self isThermometer:peripheral]) { //体温计
        if([service.UUID.UUIDString isEqualToString:TWJ_SERVICE_UUID]) {   //自定义服务接口
            for (CBCharacteristic *characteristic in service.characteristics) {
                NSString *charUUID = characteristic.UUID.UUIDString;
                
                NSLog(@"TWJ Characteristic UUID: %@", charUUID);
                
                if ([charUUID isEqualToString:TWJ_CHAR_FEEDBACK]) {
                    //设置通知，数据通知会进入：didUpdateValueForCharacteristic方法
                    [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                    NSLog(@"激活接口FFF1的通知功能");
                } else if ([charUUID isEqualToString:TWJ_CHAR_VERIFY]) {
                    
                } else if ([charUUID isEqualToString:TWJ_CHAR_HISTORICAL_DATA]) {
//                    [peripheral setNotifyValue:YES forCharacteristic:characteristic];
//                    NSLog(@"激活接口FFF3的通知功能");
                } else if ([charUUID isEqualToString:TWJ_CHAR_LIVE_DATA]) {
                    
                } else if ([charUUID isEqualToString:TWJ_CHAR_CONFIG]) {
                    
                }
             }
            
        }
    } else if ([self isBPMeter:peripheral]) {//血压计
        if ([service.UUID.UUIDString isEqualToString:BPM_SERVICE_UUID]) {
            for (CBCharacteristic *characteristic in service.characteristics) {
                NSString *charUUID = characteristic.UUID.UUIDString;
                
                NSLog(@"BPM Characteristic UUID: %@", charUUID);
                if ([charUUID isEqualToString:BPM_CHAR_FCA0]) {
                    
                } else if ([charUUID isEqualToString:BPM_CHAR_NOTIFY]) {
                    //激活通知接口
                    [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                } else if ([charUUID isEqualToString:BPM_CHAR_FCA2]) {
                    [self bpmeterWriteInitData:peripheral];
                }
            }
        }
    }
    
    //(获取BLE的mac)4.根据服务特征值2A23找到对应的服务特征，读取服务特征的value
    if ([_uuidToGetMacAddressSuccessCallBackDict.allKeys containsObject:peripheral.identifier.UUIDString]) {
        NSLog(@"(获取BLE的mac)4.根据服务特征值2A23找到对应的服务特征，读取服务特征的value");
        CBUUID *macCharcteristicUUID = [CBUUID UUIDWithString:@"2A23"];
        for(CBCharacteristic *characteristic in service.characteristics){
            if([characteristic.UUID isEqual:macCharcteristicUUID]){
                [peripheral readValueForCharacteristic:characteristic];
                break;
            }
        }

    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"%s", __func__);
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error {
    NSLog(@"%s", __func__);
}


- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
   
//    NSLog(@"%s", __func__);
    NSLog(@"UUID:%@ \tisNotifying: %@", characteristic.UUID.UUIDString, characteristic.isNotifying ? @"YES":@"NO");
    if (error) {
        NSLog(@"Error: %@", error.localizedDescription);
    }
    
    [self callHandlerFor:peripheral status:BTConnectStatusUpdateNotification object:characteristic];
}

#pragma mark --接收到notify数据
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
//    NSLog(@"%s", __func__);
    if (!characteristic.value) {    //如果数据为空，则不做任何处理
        return;
    }
    
    NSString *dataString = [characteristic.value hexString];
    NSLog(@"BLE “%@” data recv(%@): %@", peripheral.name, characteristic.UUID.UUIDString, dataString);
    
    NSString *charUUID = characteristic.UUID.UUIDString;
    if ([self isThermometer:peripheral]) {  //判断是否是体温计
        
        if ([charUUID isEqualToString:TWJ_CHAR_FEEDBACK]) { //接口1，即数据返回接口
            [self thermometerFeedBack:peripheral characteristic:characteristic receiveData:characteristic.value];
        } else if ([charUUID isEqualToString:TWJ_CHAR_HISTORICAL_DATA]) {  //接口3，即历史数据通知
            [self thermometerHistoryData:peripheral characteristic:characteristic receiveData:characteristic.value];
        } else if ([charUUID isEqualToString:TWJ_CHAR_LIVE_DATA]) {  //接口4，即实时数据通知
            [self thermometerLiveData:peripheral characteristic:characteristic receiveData:characteristic.value];
        }
    }
    else if ([self isBPMeter:peripheral]) { //血压计
        if ([charUUID isEqualToString:BPM_CHAR_NOTIFY]) {
            [self bpmeterNotify:peripheral characteristic:characteristic];
        }
    }
    
    //(获取BLE的mac)5.获取到mac地址的数据，转化，回调
    if ([_uuidToGetMacAddressSuccessCallBackDict.allKeys containsObject:peripheral.identifier.UUIDString]) {
        NSLog(@"(获取BLE的mac)5.获取到mac地址的数据，转化，回调");
        NSString *value = [NSString stringWithFormat:@"%@",characteristic.value];//如：7c40660000489120
        NSMutableString *macString = [[NSMutableString alloc] init];
        [macString appendString:[[value substringWithRange:NSMakeRange(16, 2)] uppercaseString]];
        [macString appendString:@":"];
        [macString appendString:[[value substringWithRange:NSMakeRange(14, 2)] uppercaseString]];
        [macString appendString:@":"];
        [macString appendString:[[value substringWithRange:NSMakeRange(12, 2)] uppercaseString]];
        [macString appendString:@":"];
        [macString appendString:[[value substringWithRange:NSMakeRange(5, 2)] uppercaseString]];
        [macString appendString:@":"];
        [macString appendString:[[value substringWithRange:NSMakeRange(3, 2)] uppercaseString]];
        [macString appendString:@":"];
        [macString appendString:[[value substringWithRange:NSMakeRange(1, 2)] uppercaseString]];
        NSLog(@"获取到设备的macString:%@",macString);//如：C6:05:04:03:5C:52
        //断开设备与蓝牙的连接
        [_centralManager cancelPeripheralConnection:peripheral];
        //回调
        getMacAddressSuccessCallBack callback = _uuidToGetMacAddressSuccessCallBackDict[peripheral.identifier.UUIDString];
        if (callback) {
            callback(peripheral,macString);
        }
        //销毁
        [_uuidToGetMacAddressSuccessCallBackDict removeObjectForKey:peripheral.identifier.UUIDString];

    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    NSLog(@"%s", __func__);
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
//    NSLog(@"%s", __func__);
    
    if (error) {
        NSLog(@"didWriteValueForCharacteristic Error: %@ ", error.localizedDescription);
    }
    
//    NSLog(@"did write value: %@", [characteristic.value hexString]);
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
//    NSLog(@"%s", __func__);
}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error {
//    NSLog(@"%s", __func__);
    
}

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error {
//    NSLog(@"%s", __func__);
    
}


#pragma mark - 助攻方法---体温计

///判断peripheral是否是体温计
- (BOOL)isThermometer:(CBPeripheral *)peripheral {
    return [peripheral.name hasPrefix:TONZE_TWJ_NAME];
}

///用户输入配对码授权
- (void)tempStartVerifyByAccesskey:(NSString *_Nonnull)accesskey withPeripheral:(CBPeripheral *_Nonnull)peripheral{
    if (accesskey.length>=8) {
        NSString *sendData = [NSString stringWithFormat:@"21 07 06 05 04 03 02 01 %@ %@ %@ %@ 00 00 00", [accesskey substringWithRange:NSMakeRange(0, 2)], [accesskey substringWithRange:NSMakeRange(2, 2)], [accesskey substringWithRange:NSMakeRange(4, 2)], [accesskey substringWithRange:NSMakeRange(6, 2)]];
        //获取认证的Characteristic接口
        CBCharacteristic *verifyChar = [self thermometerCharacteristic:peripheral type:TMPCharTypeVerify];
        //发送密钥
        [self sendData:peripheral characteristic:verifyChar data:[NSData dataWithHexString:sendData] delayInMsec:0];
    }
}

/////设置手动授权回调
//- (void)setAccesskeyCallback:(getTempAccesskeyCallBack _Nullable)callback withPeripheral:(CBPeripheral * _Nonnull)peripheral{
//    _uuidToGetTempAccesskeyCallBackDict[peripheral.identifier.UUIDString] = callback;
//}

///温度计FFF1接口返回的数据，解析数据
- (void)thermometerFeedBack:(CBPeripheral *)peripheral characteristic:(CBCharacteristic *)characteristic receiveData:(NSData *)data {
    const Byte *bytes = data.bytes;
    switch (bytes[0]) {
        case 0x11:  //时钟同步
        {
            
            break;
        }
        case 0x20:  //配对密钥
        {
//            ///秘钥转字符串回调
//            if ([_uuidToGetTempAccesskeyCallBackDict.allKeys containsObject:peripheral.identifier.UUIDString]) {
//                NSLog(@"秘钥转字符串回调");
//                NSString *accessStr = [NSString stringWithFormat:@"%02X%02X%02X%02X", bytes[1], bytes[2], bytes[3], bytes[4]];
//                NSLog(@"获取到设备的accessStr:%@",accessStr);
//                //回调
//                getTempAccesskeyCallBack callback = _uuidToGetTempAccesskeyCallBackDict[peripheral.identifier.UUIDString];
//                if (callback) {
//                    callback(peripheral,accessStr);
//                }
//                //销毁
//                [_uuidToGetTempAccesskeyCallBackDict removeObjectForKey:peripheral.identifier.UUIDString];
//            }
//            
//            
//            NSString *sendData = [NSString stringWithFormat:@"21 07 06 05 04 03 02 01 %02X %02X %02X %02X 00 00 00", bytes[1], bytes[2], bytes[3], bytes[4]];
//            //获取认证的Characteristic接口
//            CBCharacteristic *verifyChar = [self thermometerCharacteristic:peripheral type:TMPCharTypeVerify];
//            //发送密钥
//            [self sendData:peripheral characteristic:verifyChar data:[NSData dataWithHexString:sendData] delayInMsec:0];
            break;
        }
        case 0x21: //身份验证状态报告
        {
            if (bytes[1] == 0x00) {
                NSLog(@"身份验证成功！");
//                [self callHandlerFor:peripheral status:BTConnectStatusVerifySuccess object:nil];
            } else {
                NSLog(@"身份验证失败：%02X", bytes[1]);
            }
            break;
        }
        case 0x03: //发烧的阈值数据返回
        {
            NSLog(@"发烧的阈值数据返回");

            
            
            break;
        }
        case 0x05: //获取温差和时间间隔返回
        {
            NSLog(@"获取温差和时间间隔数据返回");
            break;
        }
        case 0x24: //获取电池电量（电池电压百分比0-100）数据返回
        {
            NSLog(@"获取电池电量（电池电压百分比0-100）数据返回");
            break;
        }
        default:
            break;
    }
    
    NSString *charUUID = characteristic.UUID.UUIDString;
    Byte notifyID = 0;
    [data getBytes:&notifyID length:1];
    
    NSDictionary *userInfo = @{
                               @"data": data,
                               };
    
    [self callCallbackWithPeripheralID:peripheral.identifier.UUIDString
                                charID:charUUID
                              notifyID:notifyID
                                  data:data
                              userInfo:userInfo];
}

///温度计FFF3接口返回，历史数据通知
- (void)thermometerHistoryData:(CBPeripheral *)peripheral characteristic:(CBCharacteristic *)characteristic receiveData:(NSData *)data {
    
    
    NSString *charUUID = characteristic.UUID.UUIDString;
    NSDictionary *userInfo = @{
                               @"data": data,
                               };
    
    [self callCallbackWithPeripheralID:peripheral.identifier.UUIDString
                                charID:charUUID
                              notifyID:0xFF
                                  data:data
                              userInfo:userInfo];
}

///温度计FFF4接口返回，实时数据通知
- (void)thermometerLiveData:(CBPeripheral *)peripheral characteristic:(CBCharacteristic *)characteristic receiveData:(NSData *)data {
    
    
    NSString *charUUID = characteristic.UUID.UUIDString;
    NSDictionary *userInfo = @{
                               @"data": data,
                               };
    
    [self callCallbackWithPeripheralID:peripheral.identifier.UUIDString
                                charID:charUUID
                              notifyID:0xFF
                                  data:data
                              userInfo:userInfo];
}

- (CBCharacteristic *)thermometerCharacteristic:(CBPeripheral *)peripheral type:(TMPCharType)type {
    NSString *typeStr = [NSString stringWithFormat:@"%02lX%02X", type >> 8, type & 0xFF];
    
    for (CBService *service in peripheral.services) {
        if ([service.UUID.UUIDString isEqualToString:@"FFF0"]) {
            for (CBCharacteristic *characteristic in service.characteristics) {
                if ([characteristic.UUID.UUIDString isEqualToString:typeStr]) {
                    return characteristic;
                }
            }
        }
    }
    return nil;
}

///开始配对，调用此方法是，需提示用户按下体温计的电源键来完成配对
- (void)thermoStartVerify:(CBPeripheral *_Nonnull)peripheral callback:(NotifyCallback _Nullable)callback {
    NSLog(@"BLE 开始配对");
    
    CBCharacteristic *characteristic = [self thermometerCharacteristic:peripheral type:TMPCharTypeVerify];
    if (characteristic) {
        NSString *startVerify = @"200706050403020101010101000000";
        NSData *sendData      = [NSData dataWithHexString:startVerify];
        [self sendData:peripheral characteristic:characteristic data:sendData delayInMsec:0];
        
        if (callback) {
            NSInteger tag = [self registerCallbackForPeripheral:peripheral
                                                         charID:TWJ_CHAR_FEEDBACK
                                                       notifyID:0x21
                                                       callback:callback];
            
            [NSTimer scheduledTimerWithTimeInterval:VERIFY_TIME_OUT
                                             target:self
                                           selector:@selector(timerElapsed:)
                                           userInfo:@{@"tag": @(tag)}
                                            repeats:NO];
        }
    }
}

///同步时钟
- (void)thermoSyncClock:(CBPeripheral *_Nonnull)peripheral callback:(NotifyCallback _Nullable)callback {
    NSLog(@"BLE 同步时钟");
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *baseDate = [formatter dateFromString:@"2000-01-01 00:00:00"];
    NSInteger now = (NSInteger)[[NSDate date] timeIntervalSinceDate:baseDate];
    
    NSString *nowStr = [NSString hexStringWithInteger:now];
    nowStr = [NSString stringWithFormat:@"01%@", nowStr];
    NSData *sendData = [NSData dataWithHexString:nowStr];
    
    CBCharacteristic *characteristic = [self thermometerCharacteristic:peripheral type:TMPCharTypeConfig];
    
    [self sendData:peripheral characteristic:characteristic data:sendData delayInMsec:0];
    
    
    if (callback) {
        NSInteger tag = [self registerCallbackForPeripheral:peripheral
                                                     charID:TWJ_CHAR_FEEDBACK
                                                   notifyID:0x11
                                                   callback:callback];
        
        [NSTimer scheduledTimerWithTimeInterval:CONFIG_TIME_OUT
                                         target:self
                                       selector:@selector(timerElapsed:)
                                       userInfo:@{@"tag": @(tag)}
                                        repeats:NO];
    }
    
}

///获取温差和时间间隔
- (void)thermoSyncTemperatureDifferenceAndTimeInterval:(CBPeripheral *_Nonnull)peripheral callback:(NotifyCallback _Nullable)callback {
    NSLog(@"体温计 获取温差和时间间隔");

    NSString *nowStr = @"08 05 00 00 00";
    NSData *sendData = [NSData dataWithHexString:nowStr];
    
    CBCharacteristic *characteristic = [self thermometerCharacteristic:peripheral type:TMPCharTypeConfig];
    
    [self sendData:peripheral characteristic:characteristic data:sendData delayInMsec:0];
    
    
    if (callback) {
        NSInteger tag = [self registerCallbackForPeripheral:peripheral
                                                     charID:TWJ_CHAR_FEEDBACK
                                                   notifyID:0x05
                                                   callback:callback];
        
        [NSTimer scheduledTimerWithTimeInterval:CONFIG_TIME_OUT
                                         target:self
                                       selector:@selector(timerElapsed:)
                                       userInfo:@{@"tag": @(tag)}
                                        repeats:NO];
    }
    
}

///获取温度发烧的阈值
- (void)thermoSyncThresholdOfFever:(CBPeripheral *_Nonnull)peripheral callback:(NotifyCallback _Nullable)callback {
    NSLog(@"体温计 同步温度发烧的阈值");
    
    NSString *nowStr = @"08 03 00 00 00";
    NSData *sendData = [NSData dataWithHexString:nowStr];
    
    CBCharacteristic *characteristic = [self thermometerCharacteristic:peripheral type:TMPCharTypeConfig];
    
    [self sendData:peripheral characteristic:characteristic data:sendData delayInMsec:0];
    
    
    if (callback) {
        NSInteger tag = [self registerCallbackForPeripheral:peripheral
                                                     charID:TWJ_CHAR_FEEDBACK
                                                   notifyID:0x03
                                                   callback:callback];
        
        [NSTimer scheduledTimerWithTimeInterval:CONFIG_TIME_OUT
                                         target:self
                                       selector:@selector(timerElapsed:)
                                       userInfo:@{@"tag": @(tag)}
                                        repeats:NO];
    }
    
}

///获取电池电量（电池电压百分比0-100）
- (void)thermoSyncBatteryLevel:(CBPeripheral *_Nonnull)peripheral callback:(NotifyCallback _Nullable)callback{
    NSLog(@"体温计 获取电池电量（电池电压百分比0-100）");
    
    NSString *nowStr = @"08 24 00 00 00";
    NSData *sendData = [NSData dataWithHexString:nowStr];
    
    CBCharacteristic *characteristic = [self thermometerCharacteristic:peripheral type:TMPCharTypeConfig];
    
    [self sendData:peripheral characteristic:characteristic data:sendData delayInMsec:2.0];
    
    
    if (callback) {
        NSInteger tag = [self registerCallbackForPeripheral:peripheral
                                                     charID:TWJ_CHAR_FEEDBACK
                                                   notifyID:0x24
                                                   callback:callback];
        
        [NSTimer scheduledTimerWithTimeInterval:CONFIG_TIME_OUT+2.0
                                         target:self
                                       selector:@selector(timerElapsed:)
                                       userInfo:@{@"tag": @(tag)}
                                        repeats:NO];
    }
}

///设置体温计的发烧阈值
- (void)setthermoThresholdOfFever:(ThermometerModel *_Nonnull)TDDevice callback:(NotifyCallback _Nullable)callback {
    NSLog(@"体温计 设置体温计的发烧阈值");
    
    NSString *nowStr = [NSString stringWithFormat:@"03 %02X %02X %02X %02X",TDDevice.downFever&0b11111111,TDDevice.downFever>>8,TDDevice.upFever&0b11111111,TDDevice.upFever>>8];
    NSData *sendData = [NSData dataWithHexString:nowStr];
    
    CBCharacteristic *characteristic = [self thermometerCharacteristic:TDDevice.peripheral type:TMPCharTypeConfig];
    
    [self sendData:TDDevice.peripheral characteristic:characteristic data:sendData delayInMsec:0];
    
    
    if (callback) {
        NSInteger tag = [self registerCallbackForPeripheral:TDDevice.peripheral
                                                     charID:TWJ_CHAR_FEEDBACK
                                                   notifyID:0x03
                                                   callback:callback];
        
        [NSTimer scheduledTimerWithTimeInterval:CONFIG_TIME_OUT
                                         target:self
                                       selector:@selector(timerElapsed:)
                                       userInfo:@{@"tag": @(tag)}
                                        repeats:NO];
    }
}

///设置体温计的上报温差和上报时间差
- (void)setthermoTemperatureDifferenceAndThermoTimeInterval:(ThermometerModel *_Nonnull)TDDevice callback:(NotifyCallback _Nullable)callback {
    NSLog(@"体温计 设置体温计的上报温差和上报时间差");
    
//    NSString *nowStr = [NSString stringWithFormat:@"05 %04X %04X",TDDevice.temperatureDifference,TDDevice.timeInterval];
    NSString *nowStr = [NSString stringWithFormat:@"05 %02X %02X %02X %02X",TDDevice.temperatureDifference&0b11111111,TDDevice.temperatureDifference>>8,TDDevice.timeInterval&0b11111111,TDDevice.timeInterval>>8];
    NSData *sendData = [NSData dataWithHexString:nowStr];
    
    CBCharacteristic *characteristic = [self thermometerCharacteristic:TDDevice.peripheral type:TMPCharTypeConfig];
    
    [self sendData:TDDevice.peripheral characteristic:characteristic data:sendData delayInMsec:0];
    
    
    if (callback) {
        NSInteger tag = [self registerCallbackForPeripheral:TDDevice.peripheral
                                                     charID:TWJ_CHAR_FEEDBACK
                                                   notifyID:0x05
                                                   callback:callback];
        
        [NSTimer scheduledTimerWithTimeInterval:CONFIG_TIME_OUT
                                         target:self
                                       selector:@selector(timerElapsed:)
                                       userInfo:@{@"tag": @(tag)}
                                        repeats:NO];
    }
}

///激活/禁止实时数据通知功能
- (void)thermoEnableLiveDataNotify:(CBPeripheral *_Nonnull)peripheral enable:(BOOL)enable callback:(NotifyCallback _Nullable)callback {
    CBCharacteristic *liveDataChar = [self thermometerCharacteristic:peripheral type:TMPCharTypeLiveData];
    if (!liveDataChar.isNotifying) {    //没有订阅，则先激活订阅
        [peripheral setNotifyValue:enable forCharacteristic:liveDataChar];
        NSLog(@"激活接口FFF4的通知功能");
    }
}

- (void)thermoSubscribeLiverData:(CBPeripheral *_Nonnull)peripheral enable:(BOOL)enable callback:(NotifyCallback _Nullable)callback {
    
    NSString *sendStr = [NSString stringWithFormat:@"%02X %02X 00 00 00", 0x0B, enable ? 0x01:0x00];
    NSData *sendData = [NSData dataWithHexString:sendStr];
    CBCharacteristic *characteristic = [self thermometerCharacteristic:peripheral type:TMPCharTypeConfig];
    
    [self sendData:peripheral characteristic:characteristic data:sendData delayInMsec:0];
    
    if (callback) {
        [self registerCallbackForPeripheral:peripheral
                                     charID:TWJ_CHAR_LIVE_DATA
                                   notifyID:0xFF
                                   callback:callback];
    }
}

///激活/禁止历史数据同步功能
- (void)thermoEnableReceiveDeviceHistoryDataNotify:(CBPeripheral *_Nonnull)peripheral enable:(BOOL)enable callback:(NotifyCallback _Nullable)callback {
    
    CBCharacteristic *liveDataChar = [self thermometerCharacteristic:peripheral type:TMPCharTypeHistData];
    if (!liveDataChar.isNotifying) {    //没有订阅，则先激活订阅
        [peripheral setNotifyValue:enable forCharacteristic:liveDataChar];
        NSLog(@"激活接口FFF3的历史数据通知功能");
    }
}

///获取历史数据
- (void)thermoReceiveDeviceHistoryDataNotify:(CBPeripheral *_Nonnull)peripheral enable:(BOOL)enable callback:(NotifyCallback _Nullable)callback {
    NSLog(@"体温计 获取历史数据");
    
    NSString *nowStr = [NSString stringWithFormat:@"0A %02X 00 00 00",enable ? 0x01:0x00];
    NSData *sendData = [NSData dataWithHexString:nowStr];
    
    CBCharacteristic *characteristic = [self thermometerCharacteristic:peripheral type:TMPCharTypeConfig];
    
    [self sendData:peripheral characteristic:characteristic data:sendData delayInMsec:0];
    
    
    if (callback) {
        NSInteger tag = [self registerCallbackForPeripheral:peripheral
                                                     charID:TWJ_CHAR_HISTORICAL_DATA
                                                   notifyID:0x09
                                                   callback:callback];
        
        [NSTimer scheduledTimerWithTimeInterval:CONFIG_TIME_OUT
                                         target:self
                                       selector:@selector(timerElapsed:)
                                       userInfo:@{@"tag": @(tag)}
                                        repeats:NO];
    }
    
}

///确认收到历史数据
- (void)thermoReceiveDeviceHistoryDataConfirm:(CBPeripheral *_Nonnull)peripheral timestamp:(UInt32)timestamp callback:(NotifyCallback _Nullable)callback {
    NSLog(@"体温计 确认收到历史数据");
    NSString *str16 = [NSString stringWithFormat:@"%08X",(unsigned int)timestamp];
    NSString *nowStr = [NSString stringWithFormat:@"09 %@ %@ %@ %@",[str16 substringWithRange:NSMakeRange(6, 2)],[str16 substringWithRange:NSMakeRange(4, 2)],[str16 substringWithRange:NSMakeRange(2, 2)],[str16 substringWithRange:NSMakeRange(0, 2)]];
//    NSString *nowStr = [NSString stringWithFormat:@"09 %08X",timestamp];
    NSData *sendData = [NSData dataWithHexString:nowStr];
    
    CBCharacteristic *characteristic = [self thermometerCharacteristic:peripheral type:TMPCharTypeConfig];
    
    [self sendData:peripheral characteristic:characteristic data:sendData delayInMsec:0];
    
    
    if (callback) {
        NSInteger tag = [self registerCallbackForPeripheral:peripheral
                                                     charID:TWJ_CHAR_HISTORICAL_DATA
                                                   notifyID:0x09
                                                   callback:callback];
        
        [NSTimer scheduledTimerWithTimeInterval:CONFIG_TIME_OUT
                                         target:self
                                       selector:@selector(timerElapsed:)
                                       userInfo:@{@"tag": @(tag)}
                                        repeats:NO];
    }
    
}

#pragma mark - 助攻方法---血压计


- (BOOL)isBPMeter:(CBPeripheral *_Nonnull)peripheral {
    return [peripheral.name hasPrefix:BPM_NAME];
}

- (BOOL)bpmeterWriteConfigData:(CBPeripheral *)peripheral config:(NSString *)config charUUID:(NSString *)charUUID {
    CBCharacteristic *characteristic = [self bpmeterCharacteristic:peripheral charUUID:charUUID];
    if (characteristic) {
        //延时100ms发送
        NSData *sendData = [NSData dataWithHexString:config];
        [self sendData:peripheral characteristic:characteristic data:sendData delayInMsec:100];
        return YES;
    }
    return NO;
}

- (void)bpmeterWriteInitData:(CBPeripheral *)peripheral {
    NSString *config = @"F0 D2 A9 C6 0F 01 01 00 08 00 04 00 00 00 00";
    [self bpmeterWriteConfigData:peripheral config:config charUUID:BPM_CHAR_FCA2];
}

- (void)bpmeterStartVerify:(CBPeripheral *)peripheral callback:(NotifyCallback _Nullable)callback {
    CBCharacteristic *characteristic = [self bpmeterCharacteristic:peripheral charUUID:BPM_CHAR_FCA0];
    if (characteristic) {
        NSString *config = @"04 55 AA 03";
        NSData *sendData = [NSData dataWithHexString:config];
        //延时500ms发送
        [self sendData:peripheral characteristic:characteristic data:sendData delayInMsec:500];
    }
    if (callback) {
        NSInteger tag = [self registerCallbackForPeripheral:peripheral
                                                     charID:BPM_CHAR_NOTIFY
                                                   notifyID:0x55
                                                   callback:callback];
        
        [NSTimer scheduledTimerWithTimeInterval:3
                                         target:self
                                       selector:@selector(timerElapsed:)
                                       userInfo:@{@"tag": @(tag)}
                                        repeats:NO];
    }
}

///同步日期
- (void)bpmeterSyncDate:(CBPeripheral *_Nonnull)peripheral callback:(NotifyCallback _Nullable)callback {
    CBCharacteristic *characteristic = [self bpmeterCharacteristic:peripheral charUUID:BPM_CHAR_FCA0];
    if (characteristic) {
        NSDate *now = [NSDate date];
        NSString *config = [NSString stringWithFormat:@"07 A2 A8 %02X %02X %02X %02X",[[NSDate getYearFromDate:now] intValue] % 100 , [[NSDate getMonthFromDate:now] intValue] , [[NSDate getDayFromDate:now] intValue],(0x07+0xA2+0xA8+[[NSDate getYearFromDate:now] intValue] % 100 + [[NSDate getMonthFromDate:now] intValue] + [[NSDate getDayFromDate:now] intValue])&0xff];
        
        NSData *sendData = [NSData dataWithHexString:config];
        //延时100ms发送
        [self sendData:peripheral characteristic:characteristic data:sendData delayInMsec:0];
    }
    if (callback) {
        NSInteger tag = [self registerCallbackForPeripheral:peripheral
                                                     charID:BPM_CHAR_NOTIFY
                                                   notifyID:0xA8
                                                   callback:callback];
        
        [NSTimer scheduledTimerWithTimeInterval:3
                                         target:self
                                       selector:@selector(timerElapsed:)
                                       userInfo:@{@"tag": @(tag)}
                                        repeats:NO];
    }
}

///同步时间
- (void)bpmeterSyncTime:(CBPeripheral *_Nonnull)peripheral callback:(NotifyCallback _Nullable)callback {
    CBCharacteristic *characteristic = [self bpmeterCharacteristic:peripheral charUUID:BPM_CHAR_FCA0];
    if (characteristic) {
        NSDate *now = [NSDate date];
        NSString *configTime = [NSString stringWithFormat:@"07 A2 A9 %02X %02X %02X %02X",[[NSDate getHourFromDate:now] intValue] , [[NSDate getMinuteFromDate:now] intValue] , [[NSDate getSecondFromDate:now] intValue],(0x07+0xA2+0xA9+[[NSDate getHourFromDate:now] intValue] % 100 + [[NSDate getMinuteFromDate:now] intValue] + [[NSDate getSecondFromDate:now] intValue])&0xff];
        NSData *sendTimeData = [NSData dataWithHexString:configTime];
        //延时300ms发送
        [self sendData:peripheral characteristic:characteristic data:sendTimeData delayInMsec:0];
    }
    if (callback) {
        NSInteger tag = [self registerCallbackForPeripheral:peripheral
                                                     charID:BPM_CHAR_NOTIFY
                                                   notifyID:0xA9
                                                   callback:callback];
        
        [NSTimer scheduledTimerWithTimeInterval:3
                                         target:self
                                       selector:@selector(timerElapsed:)
                                       userInfo:@{@"tag": @(tag)}
                                        repeats:NO];
    }
}

///开始读取历史记录
- (void)bpmeterReceiveDeviceHistoryDataNotify:(CBPeripheral *_Nonnull)peripheral callback:(NotifyCallback _Nullable)callback {
    NSLog(@"血压计 获取历史数据");
    
    CBCharacteristic *characteristic = [self bpmeterCharacteristic:peripheral charUUID:BPM_CHAR_FCA0];
    if (characteristic) {
        NSString *str = @"04 a2 ac 52";
        NSData *sendTimeData = [NSData dataWithHexString:str];
        [self sendData:peripheral characteristic:characteristic data:sendTimeData delayInMsec:0];
    }
    if (callback) {
        NSInteger tag = [self registerCallbackForPeripheral:peripheral
                                                     charID:BPM_CHAR_NOTIFY
                                                   notifyID:0xAC
                                                   callback:callback];
        
        [NSTimer scheduledTimerWithTimeInterval:3
                                         target:self
                                       selector:@selector(timerElapsed:)
                                       userInfo:@{@"tag": @(tag)}
                                        repeats:NO];
    }
    
}

- (void)bpmeterSuscribeCommandValue:(CBPeripheral *_Nonnull)peripheral command:(Byte)command callback:(NotifyCallback _Nullable)callback {
    [self registerCallbackForPeripheral:peripheral
                                 charID:BPM_CHAR_NOTIFY
                               notifyID:command
                               callback:callback];
}


- (CBCharacteristic *)bpmeterCharacteristic:(CBPeripheral *)peripheral charUUID:(NSString *)uuid {
    for (CBService *service in peripheral.services) {
        if (![service.UUID.UUIDString isEqualToString:BPM_SERVICE_UUID]) {
            continue;
        }
        for (CBCharacteristic *characteristic in service.characteristics) {
            if ([characteristic.UUID.UUIDString isEqualToString:uuid]) {
                return characteristic;
            }
        }
    }
    return nil;
}

///接收到FCA1通道的通知
- (void)bpmeterNotify:(CBPeripheral *)peripheral characteristic:(CBCharacteristic *)characteristic {
    NSData *data = characteristic.value;
    
    if (data.length < 3) {
        return;
    }
    
    
    const Byte *bytes = data.bytes;
    Byte command = bytes[1];
    switch (command) {
        case 0xB0:
            
            break;
        case 0x55: //血压计回复厂商配置码
        {
            //写回配置码2给血压计
            Byte manufacturerCode = bytes[3];
            Byte chksum = 0x04 + manufacturerCode + 0xA0;
            chksum &= 0xFF;
            NSString *config = [NSString stringWithFormat:@"04 %02X A0 %02X", manufacturerCode, chksum];
            NSLog(@"send config:%@", config);
            [self bpmeterWriteConfigData:peripheral config:config charUUID:BPM_CHAR_FCA0];
            break;
        }
        case 0xAA:
        {
            //call回调
            [self callCallbackWithPeripheralID:peripheral.identifier.UUIDString
                                        charID:characteristic.UUID.UUIDString
                                      notifyID:bytes[2]
                                          data:data
                                      userInfo:@{}];
            return;
        }
        default:
            break;
    }
    
    
    //call回调
    [self callCallbackWithPeripheralID:peripheral.identifier.UUIDString
                                charID:characteristic.UUID.UUIDString
                              notifyID:command
                                  data:data
                              userInfo:@{}];
}

#pragma mark - Internal methods

/**
 *  注册一个回调
 *
 *  @param charUUID 回调绑定characteristic的UUID，如“FFF1”;
 *  @param notifyID 通知数据的类型ID，一般是通知数据的最开头1个字节
 *
 *  @return 回调的tag
 */
- (NSInteger)registerCallbackForPeripheral:(CBPeripheral *)peripheral charID:(NSString *)charUUID notifyID:(NSInteger)notifyID callback:(NotifyCallback _Nonnull)callback {
    static NSInteger tag = 1;
    
    ++tag;
    _tagToPeriUUIDDict[@(tag)] = peripheral.identifier.UUIDString;
    _tagToCharUUIDDict[@(tag)] = charUUID;
    _tagToNotifyIDDict[@(tag)] = @(notifyID);
    _tagToCallbackDict[@(tag)] = callback;
    
    return tag;
}

///移除回调
- (void)unregisterCallback:(NSInteger)tag {
    [_tagToPeriUUIDDict removeObjectForKey:@(tag)];
    [_tagToCallbackDict removeObjectForKey:@(tag)];
    [_tagToNotifyIDDict removeObjectForKey:@(tag)];
    [_tagToCallbackDict removeObjectForKey:@(tag)];
}

///定时器超时
- (void)timerElapsed:(NSTimer *)timer {
    NSDictionary *userInfo = timer.userInfo;
    NSNumber *tag = userInfo[@"tag"];
    
    NotifyCallback callback = _tagToCallbackDict[tag];
    if (callback) {
        NSError *error = [NSError errorWithDescription:@"超时" code:BTErrorCodeTimeout];
        callback(nil, nil, error);
    }
    //移除回调
    [self unregisterCallback:[tag integerValue]];
}

///调用回调
- (void)callCallbackWithPeripheralID:(NSString *)periUUID
                              charID:(NSString *)charUUID
                            notifyID:(NSInteger)notifyID
                                data:(NSData *_Nonnull)data
                            userInfo:(NSDictionary *_Nonnull)userInfo {
    
    for (id tag in _tagToCharUUIDDict.allKeys) {
        if ([_tagToCharUUIDDict[tag] isEqualToString:charUUID] &&
            [_tagToPeriUUIDDict[tag] isEqualToString:periUUID] ) {
            //如果是TWJ_CHAR_FEEDBACK，则需要验证notifyID
            if ([charUUID isEqualToString:TWJ_CHAR_FEEDBACK] && [_tagToNotifyIDDict[tag] integerValue] != notifyID) {
                continue;
            } else if ([charUUID isEqualToString:BPM_CHAR_NOTIFY] && [_tagToNotifyIDDict[tag] integerValue] != notifyID) {
                continue;
            }
            
            NotifyCallback callback = _tagToCallbackDict[tag];
            
            if (callback && !callback(data, userInfo, nil)) {  //返回NO说明要移除回调
                [self unregisterCallback:[tag integerValue]];
            }
        }
    }
}

- (void)sendData:(CBPeripheral *)peripheral characteristic:(CBCharacteristic *)characteristic data:(NSData *)data delayInMsec:(int64_t)delay {
    if (characteristic) {
        //延时发送
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_MSEC)), _global_queue, ^{
            NSLog(@"BLE “%@” data send(%@): %@", peripheral.name, characteristic.UUID.UUIDString, [data hexString]);
            [peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
        });
    }
}

- (NSString *)checkSendDataCheckCode:(NSString *)string{
    NSString *new = @"";
    int tem = 0;
    for (int i = 0; i < string.length - 2; i++) {
        tem += [[string substringWithRange:NSMakeRange(i, 1)] intValue];
    }
    new = [NSString stringWithFormat:@"%@%02X",[string substringWithRange:NSMakeRange(0, string.length - 2)],tem & 0xff];
    return new;
}



#pragma mark - 获取mac地址相关 start
/*步骤：
 1.连接传入的Peripheral
 2.扫描服务UUID:180A
 3.查询当前服务的特征Charcteristis
 4.根据服务特征值2A23找到对应的服务特征，读取服务特征的value
 5.获取到mac地址的数据，转化，回调
 */
///获取BLE设备的mac
- (void)getMacAddress:(CBPeripheral *_Nonnull)mPeripheral successBlcak:(getMacAddressSuccessCallBack _Nullable)callback
{
    //(获取BLE的mac)1.连接传入的Peripheral
    NSLog(@"(获取BLE的mac)1.连接传入的Peripheral");
    //覆盖原连接任务
    _uuidToGetMacAddressSuccessCallBackDict[mPeripheral.identifier.UUIDString] = callback;
    
    [BTManager connect:mPeripheral];



}

#pragma mark - 获取mac地址相关 end

@end
