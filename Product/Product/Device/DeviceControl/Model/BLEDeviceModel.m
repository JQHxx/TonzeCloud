//
//  BLEDeviceModel.m
//  Product
//
//  Created by WuJiezhong on 16/6/1.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import "BLEDeviceModel.h"
#import "BTManager.h"

@interface BLEDeviceModel()

@property (nonatomic, assign) NSInteger obseverTag;

@end

@implementation BLEDeviceModel



- (void)setPeripheral:(CBPeripheral *)peripheral {
    _peripheral = peripheral;

    [BTManager removerObsever:_obseverTag];
    
    if (peripheral) {
        _obseverTag = [BTManager addObsever:peripheral
                         statusChangeHander:^(CBPeripheral * _Nullable peripheral, BTConnectStatus status, id  _Nullable object) {
                             [self peripheralStatusChangedHandler:peripheral status:status object:object];
                         }];
    }
}

- (void)peripheralDidConnected {
    NSLog(@"连接成功");
    //扫描服务
    [BTManager discoverServices:_peripheral];
}

- (void)peripheralConnectFailed:(NSError *)error {
    NSLog(@"连接失败：%@", error.localizedDescription);
    
}


- (void)peripheralDidDisconnect {
    NSLog(@"断开连接");
}

- (void)discoveredCharsHandler {
    NSLog(@"搜索特征码成功");
}

- (void)peripheralStatusChangedHandler:(CBPeripheral * _Nullable)peripheral status:(BTConnectStatus)status object:(id  _Nullable) object {
    
    switch (status) {
        case BTConnectStatusConnected:
            self.isConnected = YES;
            break;
        case BTConnectStatusDisconnected:
            self.isConnected = NO;
        default:
            break;
    }
    
    if (_connectStatusChangeHandler) {
        _connectStatusChangeHandler(peripheral, status, object);
    }
}


#pragma mark - getters & setters

- (void)setDeviceName:(NSString *)deviceName {
    super.deviceName = deviceName;
    if (self.mac) {
        NSString *key = [NSString stringWithFormat:@"%@name", self.mac];
        [NSUserDefaultInfos putKey:key andValue:deviceName];
    }
}

- (void)setUuid:(NSString *)uuid {
    _uuid = uuid;
    if (self.mac) {
        NSString *key = [NSString stringWithFormat:@"%@uuid", self.mac];
        [NSUserDefaultInfos putKey:key andValue:uuid];
    }
}

//- (void)setBLEMacAddress:(NSString *)BLEMacAddress{
//    _BLEMacAddress = BLEMacAddress;
//    if (self.mac) {
//        NSString *key = [NSString stringWithFormat:@"%@BLEMacAddress", self.mac];
//        [NSUserDefaultInfos putKey:key andValue:BLEMacAddress];
//    }
//}



- (NSString *)deviceName{
    if (!super.deviceName) {
        super.deviceName = [self nameFromLocal];
    }
    return super.deviceName;
}

- (NSString *)nameFromLocal {
    if (self.mac) {
        NSString *key = [NSString stringWithFormat:@"%@name", self.mac];
        return [NSUserDefaultInfos getValueforKey:key];
    }
    return nil;
}

- (NSString *)uuidFromLocal {
    if (self.mac) {
        NSString *key = [NSString stringWithFormat:@"%@uuid", self.mac];
        return [NSUserDefaultInfos getValueforKey:key];
    }
    return nil;
}

- (NSString *)BLEMacAddressFromLocal {
    if (self.mac) {
        NSString *key = [NSString stringWithFormat:@"%@BLEMacAddress", self.mac];
        return [NSUserDefaultInfos getValueforKey:key];
    }
    return nil;
}

//- (NSString *)tempAccesskeyFromLocal {
//    if (self.mac) {
//        NSString *key = [NSString stringWithFormat:@"%@tempAccesskey", self.mac];
//        return [NSUserDefaultInfos getValueforKey:key];
//    }
//    return nil;
//}

///清除本地保存的数据
- (void)clearDeviceLocalData {
    if (self.mac) {
        NSString *uuidKey = [NSString stringWithFormat:@"%@uuid", self.mac];
        NSString *nameKey = [NSString stringWithFormat:@"%@name", self.mac];
        NSString *BLEMacAddressKey = [NSString stringWithFormat:@"%@BLEMacAddress", self.mac];
//        NSString *tempAccesskeyKey = [NSString stringWithFormat:@"%@tempAccesskey", self.mac];
        [NSUserDefaultInfos putKey:uuidKey andValue:nil];
        [NSUserDefaultInfos putKey:nameKey andValue:nil];
        [NSUserDefaultInfos putKey:BLEMacAddressKey andValue:nil];
//        [NSUserDefaultInfos putKey:tempAccesskeyKey andValue:nil];
    }
}

@end
