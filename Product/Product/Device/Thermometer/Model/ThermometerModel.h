//
//  ThermometerModel.h
//  Product
//
//  Created by WuJiezhong on 16/5/30.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import "DeviceModel.h"
#import "BLEDeviceModel.h"

///体温计
@interface ThermometerModel : BLEDeviceModel

///智能设置相关属性
///发烧的阈值下限
@property (assign, nonatomic) SInt16 downFever;//默认372
///发烧的阈值上限
@property (assign, nonatomic) SInt16 upFever;//默认380
///上报的温差
@property (assign, nonatomic) SInt16 temperatureDifference;//默认2，表示正负0.2
///上报的时间
@property (assign, nonatomic) SInt16 timeInterval;//默认300秒

@end
