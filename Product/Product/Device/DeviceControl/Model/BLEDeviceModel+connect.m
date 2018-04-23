//
//  BLEDeviceModel+connect.m
//  Product
//
//  Created by 梁家誌 on 16/8/18.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import "BLEDeviceModel+connect.h"
#import "BTManager.h"
#import "Product-Swift.h"

@implementation BLEDeviceModel (connect)

- (void)connectBLEDeviceModel:(BLEDeviceModel *)model withType:(DeviceType)type callbackDevice:(getUUIDSuccessCallBack _Nullable)callback{
    if (model.uuid || model.uuidFromLocal) {
        //存在UUID
        if (model.uuidFromLocal) {
            model.uuid = model.uuidFromLocal;
        }
        if (model.peripheral) {
            if (callback) {
                callback(model.peripheral,model.uuid);
            }
        }else{
            [BTManager scanDevice:model success:^(BLEDeviceModel * _Nonnull device) {
                if (callback) {
                    callback(device.peripheral,model.uuid);
                }
            } fail:^(NSError * _Nonnull error) {
                NSLog(@"扫描失败：%@", error.localizedDescription);
            }];
        }
    }else{
        //不存在UUID
        [BTManager scanDevice:nil success:^(BLEDeviceModel *device) {
            if (device.deviceType != self.deviceType) {
                return;
            }
            NSLog(@"扫描到设备：%@", device.deviceName);
            if (device.BLEMacAddress) {
                if ([device.BLEMacAddress isEqualToString:model.BLEMacAddress]) {
                    NSLog(@"连接到设备mac=%@",model.BLEMacAddress);
//                    [BTManager stopScan];
//                    [BTManager connect:device.peripheral];
                    if (callback) {
                        callback(device.peripheral,device.uuid);
                    }
                }
            }else{
                [[BTManager sharedManager] getMacAddress:device.peripheral successBlcak:^(CBPeripheral * _Nullable peripheral, NSString * _Nullable macAddress) {
                    device.BLEMacAddress = macAddress;
                    device.peripheral = peripheral;
                    if ([device.BLEMacAddress isEqualToString:model.BLEMacAddress]) {
                        NSLog(@"连接到设备mac=%@",model.BLEMacAddress);
                        if (callback) {
                            callback(device.peripheral,device.uuid);
                        }
                    }else{
                        [BTManager disconnect:peripheral];
                    }
                }];
            }
        } fail:^(NSError *error) {
            NSLog(@"扫描失败：%@", error.localizedDescription);
        }];
    }
}


@end
