//
//  DeviceModel.m
//  Product
//
//  Created by Xlink on 15/12/3.
//  Copyright © 2015年 TianJi. All rights reserved.
//

#import "DeviceModel.h"
#import "HttpRequest.h"
#import "DeviceEntity.h"
#import "DeviceHelper.h"
#import "AutoLoginManager.h"

@implementation DeviceModel


#pragma mark - getter

- (BOOL)isEqual:(id)object{
    if (![object isKindOfClass:[DeviceModel class]]) {
        return NO;
    }
    
    DeviceModel *new = (DeviceModel *)object;
    
//    return [self.mac isEqualToString:new.mac]&&[self.productID isEqualToString:new.productID];
    return [self.mac isEqualToString:new.mac];
}

- (instancetype)initWithDeviceEntity:(DeviceEntity *)deviceEntity{
    self = [super init];
    if (self) {
        self.deviceName=[DeviceHelper getDeviceName:deviceEntity];
        self.isOnline=deviceEntity.isConnected;
        self.deviceType=[DeviceHelper getDeviceTypeWithMac:[deviceEntity getMacAddressSimple]];
        self.deviceID=[deviceEntity getDeviceID];
        self.mac=[deviceEntity getMacAddressSimple];
        self.State=deviceEntity.isConnected?[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"在线",@"state", nil]:[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"离线",@"state", nil];
        self.productID=deviceEntity.productID;
    }
    return self;
}

- (BOOL)isAdmin {
    return self.role==0;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict deviceType:(DeviceType)type {
    self = [super init];
    if (self) {
        self.deviceType = type;
        self.deviceID   = [dict[@"device_id"] intValue];
        self.productID  = dict[@"product_id"];
        self.mac        = dict[@"mac"];
        self.accessKey  = dict[@"access_key"];
        self.deviceName = dict[@"name"];
    }
    return self;
}

+(NSDictionary *)getModelDictionary:(DeviceModel *)model{
    NSDictionary *dic;
    NSLog(@"getModelDictionary:(DeviceModel *)model = %@ %@",model,model.deviceName);
    dic=[[NSDictionary alloc]initWithObjectsAndKeys:model.deviceName,@"name",model.mac,@"mac",[NSNumber numberWithInt:model.deviceID],@"deviceID",[NSNumber numberWithInteger:model.deviceType],@"deviceType",[NSNumber numberWithInt:model.isOnline],@"isOnline",model.role,@"role", nil];
    ///隔水炖16A和私享壶偏好特殊处理
    if (model.deviceType == DeviceTypeWaterCooker16AIG) {
        dic=[[NSDictionary alloc]initWithObjectsAndKeys:model.deviceName,@"name",model.mac,@"mac",[NSNumber numberWithInt:model.deviceID],@"deviceID",[NSNumber numberWithInt:4],@"deviceType",[NSNumber numberWithInt:model.isOnline],@"isOnline",model.role,@"role",[TonzeHelpTool sharedTonzeHelpTool].prefrenceType,@"preferenceType", nil];
    }
    
    if (model.deviceType==DeviceTypeCloudKettle&&model.isTea) {
        dic=[[NSDictionary alloc]initWithObjectsAndKeys:model.deviceName,@"name",model.mac,@"mac",[NSNumber numberWithInt:model.deviceID],@"deviceID",[NSNumber numberWithInt:3],@"deviceType",[NSNumber numberWithInt:model.isOnline],@"isOnline",model.role,@"role",[TonzeHelpTool sharedTonzeHelpTool].teaType,@"preferenceType", nil];
    }
    if (model.deviceType==DeviceTypeNutritionScale) {
        dic=[[NSDictionary alloc]initWithObjectsAndKeys:model.deviceName,@"name",[NSNumber numberWithInt:10],@"deviceType",nil];
    }
    if (model.deviceType==DeviceTypeScale) {
        dic=[[NSDictionary alloc]initWithObjectsAndKeys:model.deviceName,@"name",[NSNumber numberWithInt:4],@"deviceType",nil];
    }
    
    return dic;
}

- (UIImage *)tableViewIconImage {
    switch (self.deviceType) {
            ///隔水炖
        case DeviceTypeWaterCooker:
            return [UIImage imageNamed:@"隔水炖"];
            ///电饭煲
        case DeviceTypeElectricCooker:
            return [UIImage imageNamed:@"电饭煲"];
            ///云炖锅
        case DeviceTypeCloudCooker:
            return [UIImage imageNamed:@"云炖锅"];
            ///炒菜锅
        case DeviceCookFood:
            return [UIImage imageNamed:@"自动烹饪锅"];
            ///私享壶
        case DeviceTypeCloudKettle:
            return [UIImage imageNamed:@"云水壶"];
            ///电子秤
        case DeviceTypeScale:
            return [UIImage imageNamed:@"体脂称"];
            ///血压计
        case DeviceTypeBPMeter:
            return [UIImage imageNamed:@"血压计"];
            ///体温计
        case DeviceTypeThermometer:
            return [UIImage imageNamed:@"体温计"];
            ///隔水炖16A
        case DeviceTypeWaterCooker16AIG:
            return [UIImage imageNamed:@"add隔水炖16AIG"];
        case DeviceTypeCaninets:
            return [UIImage imageNamed:@"ic_storage"];
            ///未知设备
        case DeviceTypeNutritionScale:
            return [UIImage imageNamed:@"equ_tzy120"];
            ///未知设备
        default:
            return [UIImage imageNamed:@"未知设备"];
    }
}
- (void)unsubscribeWithUserID:(NSNumber *)userID accessToken:(NSString *)token result:(void(^)(NSError *error))callback {
    [HttpRequest unsubscribeDeviceWithUserID:userID withAccessToken:token withDeviceID:@(self.deviceID) didLoadData:^(id result, NSError *err) {
        callback(err);
    }];
}

- (void)setState:(NSMutableDictionary *)State{
//    NSLog(@"device mac = %@ state = %@",_mac,State);
    _State = State;
}

@end
