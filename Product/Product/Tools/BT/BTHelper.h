//
//  BTHelper.h
//  Scale
//
//  Created by Xlink on 15/11/12.
//  Copyright © 2015年 YiLai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TIBLECBKeyfob.h"

@protocol BTHelperDelegate <NSObject>
@optional

@required

-(void)startScanWithMsg:(NSString *)msg;
- (void)receiveHistoryData:(NSDictionary *)RecData;  //数据获取
-(void)BTStateChange:(NSString *)state;  //蓝牙状态改变

-(void)didDiscoverDeivce:(NSDictionary*)deviceDic;
-(void)DeviceStateChange:(NSString *)state;

@end


@interface BTHelper : NSObject<TIBLECBKeyfobDelegate>{
   TIBLECBKeyfob *t;
}

@property (nonatomic,weak) id <BTHelperDelegate> delegate;

@property int DeviceState;

- (void)initParam ;
-(void)startScanXDevice:(NSString*)DeviceName;
-(void)stopScanXDevice;
-(void)connectXDevice:(NSString*)DeviceName withUUID:(NSString *)uuid needConnect:(BOOL)needConnect;
-(void)disconnectXDevice;
-(void)sendXDeviceData:(NSData*)data WithServiceUUID:(int)service WithCharacteristicUUID:(int)charUUID;
-(void)sendXDeviceDataWithoutResponse:(NSData*)data WithServiceUUID:(int)service WithCharacteristicUUID:(int)charUUID;


-(void)sendPersonInfoToScale;

@end
