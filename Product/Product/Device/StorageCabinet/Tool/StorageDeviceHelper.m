//
//  StorageDeviceHelper.m
//  Product
//
//  Created by vision on 17/6/13.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "StorageDeviceHelper.h"

@implementation StorageDeviceHelper

singleton_implementation(StorageDeviceHelper)


-(void)setIsStorageFoodRefresh:(BOOL)isStorageFoodRefresh{
    _isStorageFoodRefresh=isStorageFoodRefresh;
    if (isStorageFoodRefresh) {
        self.isStorageHomereFresh=YES;
    }
    
}

-(void)storageDeviceMac:(NSString *)mac SendDataForType:(StorageDeviceSendType)sendType withValue:(NSInteger)value{
    DeviceEntity *device=[[ControllerHelper shareHelper] getNeedControllDevice:mac];
    NSString *commandStr=nil;
    if (sendType==StorageDeviceSendTypeHumidity) {  //设置储物区湿度
        commandStr=@"000000000013000002";
        NSString *humidityStr=[NSString stringWithFormat:@"%02lX",(long)value];
        commandStr=[commandStr stringByAppendingString:humidityStr];
    }else if (sendType==StorageDeviceSendTypeTemperature){  //设置储物区温度
        commandStr=@"000000000013000003";
        NSString *temperatureStr=[NSString stringWithFormat:@"%02lX",(long)value];
        commandStr=[commandStr stringByAppendingString:temperatureStr];
    }else if (sendType==StorageDeviceSendTypeOutRice){   //设置出米量
        commandStr=@"000000000013000004";
        NSString *outRiceStr=[NSString stringWithFormat:@"%02lX",(long)value];
        commandStr=[commandStr stringByAppendingString:outRiceStr];
    }else if (sendType==StorageDeviceSendTypeGetHumidity){
        commandStr=@"000000000011000002";
    }else if (sendType==StorageDeviceSendTypeGetTemperature){
        commandStr=@"000000000011000003";
    }else if (sendType==StorageDeviceSendTypeGetOutRice){
        commandStr=@"000000000011000004";
    }else if (sendType==StorageDeviceSendTypeGetOfflineOutRice){
        commandStr=@"000000000016000001";
    }else if (sendType==StorageDeviceSendTypeDeleteOfflineOutRice){
        commandStr=@"000000000017000001";
    }
    NSData *Data=[Transform nsstringToHex:commandStr];
    MyLog(@"智能厨物柜设置属性(%@)状态>>：%@", mac, [Data hexString]);
    //获取最新状态
    if (device.isWANOnline) {
        [[XLinkExportObject sharedObject] sendPipeData:device andPayload:Data];
    }else{
        [[XLinkExportObject sharedObject] sendLocalPipeData:device andPayload:Data];
    }
}

-(NSString *)getCabinetStateWithType:(NSInteger)workType{
    NSString *stateStr=nil;
    if (workType==1) {
        stateStr=@"工作中";
    }else if (workType==2){
        stateStr=@"理想状态";
    }else if (workType==3){
        stateStr=@"异常";
    }else if (workType==4){
        stateStr=@"杀菌中";
    }
    return stateStr;
}

@end
