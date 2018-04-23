//
//  DeviceStateCheckService.m
//  Product
//
//  Created by WuJiezhong on 16/6/16.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import "DeviceStateCheckService.h"
#import "ControllerHelper.h"
#import "NSError+Extension.h"
#import "AppDelegate.h"
#import "DeviceConnectStateCheckService.h"
#import "AutoLoginManager.h"

@interface DeviceStateCheckService(){

    AppDelegate *appDelegate;
}

@property (nonatomic, strong) NSTimer *checkerTimer;
@property (nonatomic, assign) NSUInteger keepAliveCount;

@end


@implementation DeviceStateCheckService

- (instancetype)initWithDevice:(DeviceModel *)device
{
    self = [super init];
    if (self) {
        self.device = device;
    }
    return self;
}


- (void)start {
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnSendPipeData:) name:kOnSendPipeData object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnSendPipeData:) name:kOnSendLocalPipeData object:nil];

    
    //每5秒获取一次进度
    if (!_checkerTimer) {
        _keepAliveCount = 0;
        _checkerTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(timerElapsed:) userInfo:nil repeats:YES];
        [_checkerTimer fire];  //马上执行，先获取一次状态
        
    }
}


- (void)stop {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_checkerTimer invalidate];
    _checkerTimer = nil;
}

- (void)timerElapsed:(NSTimer *)timer {
    if( ++_keepAliveCount > 4) { //大于4，认为离线
        [_checkerTimer invalidate];
        MyLog(@"keepAliveCount大于3，设备离线");
        NSError *error = [NSError errorWithDescription:@"设备离线" code:-1];
        self.handler(self.device, 200, error);//提示处理：设备状态查询15秒没有回包，定义state=200
        //重新拉取设备列表
        [[AutoLoginManager shareManager] getDeviceList];
        return;
    }
    [[ControllerHelper shareHelper] getDeviceState:self.device];
}

- (void)OnSendPipeData:(NSNotification *)notification {
    @synchronized (self) {
        NSDictionary *dict = notification.object;
        DeviceEntity *device = [dict objectForKey:@"device"];
        int result = [dict[@"result"] intValue];//0表示发送成功，200为超时
        if ([[device getMacAddressSimple] isEqualToString:_device.mac] && result == 0) {
            _keepAliveCount = 0;
            self.handler(_device, 112, nil);
        }else if ([[device getMacAddressSimple] isEqualToString:_device.mac] && (result == CODE_DEVICE_UNINIT || result == CODE_INVALID_KEY || result == CODE_UNAUTHORIZED || result == CODE_FUNC_DEVICE_NOT_ACTIVATION)){
            
            [[XLinkExportObject sharedObject] disconnectDevice:device withReason:0];
            //注意，在此发送重置广播
            //1.
            [[NSNotificationCenter defaultCenter] postNotificationName:KDelectDevice object:_device.deviceName];
            //2.
            [[DeviceConnectStateCheckService share] removeDevice:device];
            
            [self stop];
            
            //重新拉取设备列表
            [[AutoLoginManager shareManager] getDeviceList];
        }
    }
}




@end
