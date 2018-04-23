//
//  BTHelper.m
//  Scale
//
//  Created by Xlink on 15/11/12.
//  Copyright © 2015年 YiLai. All rights reserved.
//

#import "BTHelper.h"
#import "AppDelegate.h"
#import "Transform.h"

@implementation BTHelper{
    AppDelegate *appDelegate;
}

- (void)initParam {
    t = [[TIBLECBKeyfob alloc]init];
    [t controlSetup:1];
    t.delegate = self;
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.tiBT = t;
}

-(void)startScanXDevice:(NSString*)DeviceName{
    
    if (t.peripherals)
        t.peripherals = nil;
    t.justScan=YES;
    t.DeviceName=DeviceName;
    [t findBLEPeripherals:0];
    
}


-(void)stopScanXDevice{
    [t.CM stopScan];
}

-(void)connectXDevice:(NSString*)DeviceName withUUID:(NSString *)uuid needConnect:(BOOL)needConnect{
    if (t.peripherals)
        t.peripherals = nil;
    t.justScan=NO;
    
    t.DeviceName=DeviceName;
    t.BindingUUID=uuid;
    t.NeedConnect=needConnect;
    [t findBLEPeripherals:0];
}

- (void)disconnectXDevice{
    if (t.activePeripheral) {
        [t.CM cancelPeripheralConnection:t.activePeripheral];
        t.activePeripheral = nil;
        if (t.peripherals) {
            [t.peripherals removeAllObjects];
            t.peripherals = nil;
        }
    }
}

-(void)sendXDeviceData:(NSData*)data WithServiceUUID:(int)service WithCharacteristicUUID:(int)charUUID{
    
    
    [t writeValue:service characteristicUUID:charUUID p:t.activePeripheral data:data];
}

-(void)sendXDeviceDataWithoutResponse:(NSData*)data WithServiceUUID:(int)service WithCharacteristicUUID:(int)charUUID{
    
    [t writeValueWithOutResponse:service characteristicUUID:charUUID p:t.activePeripheral data:data];
}

-(void)sendPersonInfoToScale{
        
    Byte txDataBytes[8];
    int indx = 0;
    //数据头、信息长度统一
    txDataBytes[indx++]=  0x02;
    txDataBytes[indx++] = 0xE2;
    txDataBytes[indx++] = 0x04;
    txDataBytes[indx++] = [NSUserDefaultInfos getValueforKey:USER_ID].intValue;
    txDataBytes[indx++] = [NSUserDefaultInfos getValueforKey:USER_HEIGHT].intValue;
    txDataBytes[indx++] = [NSUserDefaultInfos getValueforKey:USER_AGE].intValue;
    txDataBytes[indx++] = [[NSUserDefaultInfos getValueforKey:USER_SEX]isEqualToString:@"男"]?0x01:0x00;
    
    Byte checkNum = txDataBytes[0] ;
    for (int i=1; i<indx; i++) {
        checkNum = checkNum + txDataBytes[i];
    }
    txDataBytes[indx++]=checkNum;//校验
    txDataBytes[indx++]=0xAA;
    
    NSData *txData = [NSData dataWithBytes:&txDataBytes length:indx];
    
    
    [t writeValueWithOutResponse:Service_Data characteristicUUID:Characteristic_Data p:t.activePeripheral data:txData];
}

#pragma mark  BT Delegate

-(void)startScanWithMsg:(NSDictionary *)dic{
    if (self.delegate &&[self.delegate respondsToSelector:@selector(startScanWithMsg:)]) {
        [self.delegate startScanWithMsg:[Transform DataToJsonString:dic]];
    }
}

- (void)receiveHistoryData:(NSData *)data withUUID:(NSString*)uuid{

    //根据协议计算体重
//    NSString* Str=[NSString stringWithFormat:@"%@",data];
    //加密
    NSString*Str=[Transform dataToBase64:data];
    
    NSLog(@"%@",data);

    /////////////////////直接返回秤数据，不解析///////////////////////////////
    NSDictionary *allDic=[[NSDictionary alloc]initWithObjectsAndKeys:uuid,@"deviceUUID",Str,@"data", nil];
    if (self.delegate &&[self.delegate respondsToSelector:@selector(receiveHistoryData:)]) {
        [self.delegate receiveHistoryData:allDic];
    }
    
    /////////////////////直接返回秤数据，不解析///////////////////////////////
}

-(void)scanOverTime{
 NSLog(@"停止搜索");
}

-(void)DeviceStateChange:(int)state{
    self.DeviceState=state ;
    
    if (self.delegate &&[self.delegate respondsToSelector:@selector(DeviceStateChange:)]) {
        NSDictionary *dic=[[NSDictionary alloc]initWithObjectsAndKeys:appDelegate.tiBT.BindingUUID,@"deviceUUID",[NSString stringWithFormat:@"%i",state],@"state", nil];
        [self.delegate DeviceStateChange:[Transform DataToJsonString:dic]];
    }
}

-(void)didDiscoverDeivce:(NSDictionary *)deviceDic{
    if (self.delegate &&[self.delegate respondsToSelector:@selector(didDiscoverDeivce:)]) {
        [self.delegate didDiscoverDeivce:deviceDic];
    }
    
    //为天际app
    if (appDelegate.scaleListVC) {
        [appDelegate.scaleListVC didDiscoverDeivce:deviceDic];
    }
     //为天际app

}

-(void)BTStateChange:(CBCentralManagerState)state{
    
  NSLog(@"蓝牙状态更新：%li",(long)state);
    
    if (self.delegate &&[self.delegate respondsToSelector:@selector(BTStateChange:)]) {
        NSDictionary *dic=[[NSDictionary alloc]initWithObjectsAndKeys:[NSString stringWithFormat:@"%s",[appDelegate.tiBT centralManagerStateToString:state]],@"state", nil];
        [self.delegate BTStateChange:[Transform DataToJsonString:dic]];
    }
    
}


@end
