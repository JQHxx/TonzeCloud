//
//  DeviceConnectStateCheckService.m
//  Product
//
//  Created by WuJiezhong on 16/6/30.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import "DeviceConnectStateCheckService.h"
#import "XLinkExportObject.h"
#import "AppDelegate.h"

#import "AutoLoginManager.h"

@interface DeviceConnectStateCheckService()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSUInteger keepAliveCount;

@end


@implementation DeviceConnectStateCheckService

+ (instancetype)share{
    @synchronized (self) {
        static DeviceConnectStateCheckService *share = nil;
        static dispatch_once_t tempOnce=0;
        dispatch_once(&tempOnce, ^{
            share = [[DeviceConnectStateCheckService alloc]init];
        });
        return share;
    }
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _devices = @[].mutableCopy;
    }
    return self;
}

- (void)start {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!_timer) {
            _keepAliveCount = 0;
            _timer = [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(timerElapsed:) userInfo:nil repeats:YES];
            [_timer fire];  //马上执行，先获取一次状态
        }
        _isStart = YES;
    });
}

- (void)startIfNecessary {
    if (!_isStart) {
        [self start];
    }
}

- (void)stop {
    [_timer invalidate];
    _timer = nil;
    _isStart = NO;
    [_devices removeAllObjects];
}

- (void)addDevice:(DeviceEntity *)device {
    @synchronized (self) {
        if (device && ![_devices containsObject:device] && (![device.productID isEqualToString:THERMOMETER_PRODUCT_ID] && ![device.productID isEqualToString:CLINK_BPM_PRODUCT_ID])) {
            for (DeviceEntity *curDevice in _devices) {
                if ([curDevice.getMacAddressSimple isEqualToString:device.getMacAddressSimple]) {
                    return;
                }
            }
            [_devices addObject:device];
        }
    }
}

- (void)removeDevice:(DeviceEntity *)device {
    @synchronized (self) {
        if (device && [_devices containsObject:device]) {
            for (DeviceEntity *curDevice in _devices) {
                if ([curDevice.getMacAddressSimple isEqualToString:device.getMacAddressSimple]) {
                    [_devices removeObject:curDevice];
                    return;
                }
            }
        }
    }
}

///从连接成功的设备列表获取设备实体
- (DeviceEntity *)getDeviceFromeControllerHelper:(DeviceEntity *)device{
    @synchronized (self) {
        DeviceEntity *reDevice = nil;
        NSMutableArray *all = [ControllerHelper shareHelper].connectedArr;
        for (DeviceEntity *dev in all) {
            if ([device.getMacAddressSimple isEqualToString:dev.getMacAddressSimple]) {
                return dev;
                break;
            }
        }
        return reDevice;
    }
}

- (DeviceEntity *)getDeviceFromeDeviceModel:(DeviceModel *)device{
    @synchronized (self) {
        DeviceEntity *reDevice = nil;
        NSMutableArray *all = [ControllerHelper shareHelper].connectedArr;
        for (DeviceEntity *dev in all) {
            if ([device.mac isEqualToString:dev.getMacAddressSimple]) {
                return dev;
                break;
            }else if([device.productID isEqualToString:COOKFOOD_COOKER_PRODUCT_ID]){
                return dev;
                break;
            }
        }
        return reDevice;
    }
}

- (void)timerElapsed:(NSTimer *)timer {
    @synchronized (self) {
        if (_keepAliveCount % 2 == 0 && _keepAliveCount > 0) {
            //重新拉取设备列表
            [[AutoLoginManager shareManager] getDeviceList];
        }
        for (DeviceEntity *curDevice in _devices) {
            DeviceEntity *connectDevice = [[ControllerHelper shareHelper] getNeedControllDevice:curDevice.getMacAddressSimple];
            if (!connectDevice || (connectDevice && !connectDevice.isConnected && !connectDevice.isUserDisconnect)){ //如果没有连接，则重连
                [[XLinkExportObject sharedObject] initDevice:curDevice];
                curDevice.version=2;
                [[XLinkExportObject sharedObject] connectDevice:curDevice andAuthKey:curDevice.accessKey];
            }
        }
        ++_keepAliveCount;
    }
}

@end
