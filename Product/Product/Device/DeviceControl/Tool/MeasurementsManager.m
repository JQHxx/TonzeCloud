//
//  MeasurementsManager.m
//  Product
//
//  Created by 梁家誌 on 16/8/25.
//  Copyright © 2016年 TianJi. All rights reserved.
//

///测量结果单例
#import "MeasurementsManager.h"
#import "DBManager.h"
#import "DeviceModel.h"
#import "AppDelegate.h"
#import "ThermometerModel.h"
#import "BPMeterModel.h"
#import "MeasurementsModel.h"
#import "NotificationHandler.h"
#import "HttpRequest.h"
#import "AutoLoginManager.h"

@interface MeasurementsManager (){
    AppDelegate *appDelegate;

}

@property (nonatomic,strong) NSMutableArray *cheakBLEAddressArray;

@end

@implementation MeasurementsManager

+ (instancetype)shareManager{
    @synchronized (self) {
        static MeasurementsManager *manager = nil;
        static dispatch_once_t tempOnce=0;
        
        dispatch_once(&tempOnce, ^{
            manager = [[MeasurementsManager alloc] init];
        });
        
        return manager;
    }
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _measurements = @[].mutableCopy;
        _cheakBLEAddressArray = @[].mutableCopy;
        appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    }
    return self;
}

///检查是否需要弹本地推送，并更新测量结果
- (void)checkAndUpdateWithDicts:(NSMutableArray *)dicts BLEAddress:(NSString *)bleAddress{

    NSLog(@"获取云端测量结果数量：%lu个",(unsigned long)dicts.count);
    //1.获取原来的测量结果
    NSMutableArray *olds = [self getMeasurementsWithBLEAddress:bleAddress];
    NSLog(@"缓存云端测量结果数量：%lu个",(unsigned long)olds.count);

    //2.解析得到新的测量结果
    NSMutableArray *news = [NSMutableArray array];
    for (NSDictionary *dict in dicts) {
        MeasurementsModel *model = [[MeasurementsModel alloc] initFromDict:dict];
        model.mac = bleAddress;
        [news addObject:model];
    }
    
    //跳过
    if (news.count <= olds.count) {
        [self startCheckBLEAddress:bleAddress];
        return;
    }
    
    //3.推送
    BOOL hasNew = NO;
    for (MeasurementsModel *model in news) {
        if (![olds containsObject:model]) {
            //4.存缓存
            [_measurements addObject:model];
            hasNew = YES;
//            break;
        }
    }
    if (hasNew && [_cheakBLEAddressArray containsObject:bleAddress]) {
        //排序，推送最新一条记录
        [news sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            MeasurementsModel *meas1 = (MeasurementsModel *)obj1;
            MeasurementsModel *meas2 = (MeasurementsModel *)obj2;
            return [meas1.date compare:meas2.date]==NSOrderedAscending;
        }];
        MeasurementsModel *model = news.firstObject;
        NSString *msg = @"";
        if (model.type == MeasurementType_Temp) {
            //体温计
            msg = [NSString stringWithFormat:@"测量者：%@\n测量时间：%@\n体温 %.1f℃\n%@",model.name,model.date,model.temp,model.describe];
            
            if (model.temp > 45)
                msg = [NSString stringWithFormat:@"测量者：%@\n测量时间：%@\n体温 45.0℃+\n%@",model.name,model.date,model.describe];
            if (model.temp < 25)
                msg = [NSString stringWithFormat:@"测量者：%@\n测量时间：%@\n体温 25.0℃-\n%@",model.name,model.date,model.describe];
            
        }else{
            //血压计
            msg = [NSString stringWithFormat:@"测量者：%@\n测量时间：%@\n高压 %ldmmHg\n低压 %ldmmHg\n心率 %ld次/分钟\n%@",model.name,model.date,(long)model.SBP,(long)model.DBP,(long)model.heartRate,model.describe];
        }
        [[NotificationHandler shareHendler] configNotification:msg];
    }
//    //4.存缓存
//    [_measurements removeObjectsInArray:olds];
//    [_measurements addObjectsFromArray:news];
    [self startCheckBLEAddress:bleAddress];
}

///添加一个新的测量结果并更新云端
- (void)addAndUpdateToCloudWithNewMeasurement:(MeasurementsModel *)measurement BLEAddress:(NSString *)bleAddress{
    NSString *tem = [NSString stringWithFormat:@"%.1f",measurement.temp];
    measurement.temp = [tem floatValue];
    if ([_cheakBLEAddressArray containsObject:bleAddress]) {
        if(measurement) [_measurements addObject:measurement];
        NSMutableArray *olds = [self getMeasurementsWithBLEAddress:bleAddress];
        NSLog(@"上传前云端测量结果数量：%lu个",(unsigned long)olds.count);
        NSMutableArray *newDict = [NSMutableArray array];
        for (MeasurementsModel *measurement in olds) {
            [newDict addObject:measurement.getDictionary];
        }
        NSLog(@"上传云端测量结果数量：%lu个",(unsigned long)newDict.count);

        [self saveMeasurementsToCloud:newDict bleAddress:bleAddress];
    }
}

- (void)saveMeasurementsToCloud:(NSMutableArray *)meas bleAddress:(NSString *)bleAddress{
    [meas sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSDictionary *dict1 = (NSDictionary *)obj1;
        NSDictionary *dict2 = (NSDictionary *)obj2;
        return [dict1[@"date"] compare:dict2[@"date"]]==NSOrderedAscending;
    }];
    BLEDeviceModel *bleDevice;
    NSMutableArray *deviceModels = [NSMutableArray arrayWithArray:[AutoLoginManager shareManager].getDeviceModelArr];
    for (DeviceModel *model in deviceModels) {
        if ([model isMemberOfClass:[BPMeterModel class]] || [model isMemberOfClass:[ThermometerModel class]]) {
            if ([((BLEDeviceModel *)model).BLEMacAddress isEqualToString:bleAddress]) {
                bleDevice = (BLEDeviceModel *)model;
                break;
            }
        }
    }
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if(bleDevice.deviceName) dict[@"name"] = bleDevice.deviceName;
    if(bleDevice.BLEMacAddress) dict[@"mac"] = bleDevice.BLEMacAddress;
//    if(bleDevice.tempAccesskey) dict[@"check_code"] = bleDevice.tempAccesskey;
    //排序
    [meas sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSDictionary *meas1 = (NSDictionary *)obj1;
        NSDictionary *meas2 = (NSDictionary *)obj2;
        return [meas1[@"date"] compare:meas2[@"date"]]==NSOrderedAscending;
    }];
    dict[@"measurements"] = meas;
    NSLog(@"上传测量结果数量 %lu条",(unsigned long)meas.count);
    
    NSDictionary *userDic=[NSUserDefaultInfos getDicValueforKey:USER_DIC];
    
    [HttpRequest setDevicePropertyDictionary:dict withDeviceID:[NSNumber numberWithInt:bleDevice.deviceID] withProductID:bleDevice.productID withAccessToken:[userDic objectForKey:@"access_token"] didLoadData:^(id result, NSError *err) {
        if (err) {
            if (err.code==4031003) {
                [appDelegate updateAccessToken];
            }
            NSLog(@"测量结果上传 err %@",err);
        }else{
            NSLog(@"测量结果上传 成功");
        }
    }];
}

///开始检测某个地址的设备测量结果的通知（第一次拉取到该设备的扩展属性时使用）
- (void)startCheckBLEAddress:(NSString *)bleAddress{
    if (![_cheakBLEAddressArray containsObject:bleAddress]) {
        [_cheakBLEAddressArray addObject:bleAddress];
    }
}

///停止检测某个地址的设备测量结果的通知（删除该设备时使用）
- (void)stopCheckBLEAddress:(NSString *)bleAddress{
    NSMutableArray *olds = [self getMeasurementsWithBLEAddress:bleAddress];
    [_measurements removeObjectsInArray:olds];
    if ([_cheakBLEAddressArray containsObject:bleAddress]) {
        [_cheakBLEAddressArray removeObject:bleAddress];
    }
}

///停止检测所有蓝牙的设备测量结果的通知（退出登录时使用）
- (void)stopCheckAllBLEAddress{
    [_measurements removeAllObjects];
    [_cheakBLEAddressArray removeAllObjects];
}

- (NSMutableArray <MeasurementsModel *>*)getMeasurementsWithBLEAddress:(NSString *)bleAddress{
    NSMutableArray *olds = [NSMutableArray array];
    for (MeasurementsModel *model in _measurements) {
        if ([model.mac isEqualToString:bleAddress]) {
            [olds addObject:model];
        }
    }
    return olds;
}

- (NSMutableArray *)measurements{
//    [_measurements sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
//        MeasurementsModel *meas1 = (MeasurementsModel *)obj1;
//        MeasurementsModel *meas2 = (MeasurementsModel *)obj2;
//        return [meas1.date compare:meas2.date]==NSOrderedAscending;
//    }];
//    NSMutableArray *temps = [NSMutableArray array];
//    for (MeasurementsModel *model in _measurements) {
//        if (model.type == MeasurementType_Temp) {
//            [temps addObject:model];
//        }
//    }
//    [_measurements removeObjectsInArray:temps];
//    [_measurements addObjectsFromArray:temps];
    return _measurements;
}

@end
