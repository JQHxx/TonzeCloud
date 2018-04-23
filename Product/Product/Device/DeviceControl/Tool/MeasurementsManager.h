//
//  MeasurementsManager.h
//  Product
//
//  Created by 梁家誌 on 16/8/25.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MeasurementsModel.h"

//@class MeasurementsModel;

@interface MeasurementsManager : NSObject

@property (strong, nonatomic) NSMutableArray *measurements;


+(instancetype)shareManager;

///检查是否需要弹本地推送，并更新测量结果
- (void)checkAndUpdateWithDicts:(NSMutableArray *)dicts BLEAddress:(NSString *)bleAddress;

///添加一个新的测量结果并更新云端
- (void)addAndUpdateToCloudWithNewMeasurement:(MeasurementsModel *)measurement BLEAddress:(NSString *)bleAddress;

///停止检测某个地址的设备测量结果的通知（删除该设备时使用）
- (void)stopCheckBLEAddress:(NSString *)bleAddress;

///停止检测所有蓝牙的设备测量结果的通知（退出登录时使用）
- (void)stopCheckAllBLEAddress;

///获取某个蓝牙设备地址的测量结果
- (NSMutableArray <MeasurementsModel *>*)getMeasurementsWithBLEAddress:(NSString *)bleAddress;


@end
