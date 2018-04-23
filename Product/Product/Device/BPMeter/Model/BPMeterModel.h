//
//  BPMeterModel.h
//  Product
//
//  Created by WuJiezhong on 16/5/25.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import "BLEDeviceModel.h"

///血压计
@interface BPMeterModel : BLEDeviceModel

///厂商码
@property (nonatomic, assign) Byte manufacturerCode;

///收缩压，高压
@property (nonatomic, assign) UInt16 SBP;
///舒张压，低压
@property (nonatomic, assign) UInt16 DBP;
///心率
@property (nonatomic, assign) UInt16 heartRate;
///是否心率不齐
@property (nonatomic, assign) BOOL isHBUneven;
///用户1、2，yes为用户1，no为用户2
@property (nonatomic, assign) BOOL isUserOne;

@end
