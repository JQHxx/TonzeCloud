//
//  MeasurementsModel.m
//  Product
//
//  Created by 梁家誌 on 16/8/24.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import "MeasurementsModel.h"
#import "Product-Swift.h"
#import "NSUserDefaultInfos.h"

@implementation MeasurementsModel

- (instancetype)initFromBPRecord:(BPRecord *)record{
    if (self = [super init]) {
        _mac = record.deviceUUID;
        _userId = [[[NSUserDefaultInfos getValueforKey:USER_DIC] valueForKey:@"user_id"] integerValue];
        _name = [NSUserDefaultInfos getValueforKey:USER_NAME];
        _SBP = record.SBP;
        _DBP = record.DBP;
        _heartRate = record.heartRate;
        _temp = 0;
        _type = MeasurementType_BPMeter;
        _describe = [BPMeterModelHelper BPvalueDescription:_DBP HPvalue:_SBP];
        NSDateFormatter *format = [[NSDateFormatter alloc]init];
        [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        _date = [format stringFromDate:record.date];
        _fromName = [NSString stringWithFormat:@"来自:%@",[DeviceHelper getBLEDeviceName:self]];
    }
    return self;
}

- (instancetype)initFromBodyTempRecord:(BodyTempRecord *)record{
    if (self = [super init]) {
        _mac = record.deviceUUID;
        _userId = [[[NSUserDefaultInfos getValueforKey:USER_DIC] valueForKey:@"user_id"] integerValue];
        _name = [NSUserDefaultInfos getValueforKey:USER_NAME];
        _temp = [[NSString stringWithFormat:@"%.1f",record.temperature] floatValue];
        _SBP = _DBP = _heartRate = 0;
        _type = MeasurementType_Temp;
        _describe = [ThermometerModel valueDescription:record.temperature];
        NSDateFormatter *format = [[NSDateFormatter alloc]init];
        [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        _date = [format stringFromDate:record.date];
        _fromName = [NSString stringWithFormat:@"来自:%@",[DeviceHelper getBLEDeviceName:self]];
    }
    return self;
}

- (instancetype)initFromDict:(NSDictionary *)dict{
    if (self = [super init]) {
        _SBP = _DBP = _heartRate = 0;
        _temp = 0;
        NSArray *allkeys = dict.allKeys;
        if ([allkeys containsObject:@"userId"]) {
            _userId = [dict[@"userId"] integerValue];
        }
        if ([allkeys containsObject:@"name"]) {
            _name = dict[@"name"];
        }
        if ([allkeys containsObject:@"SBP"]) {
            _SBP = [dict[@"SBP"] integerValue];
        }
        if ([allkeys containsObject:@"DBP"]) {
            _DBP = [dict[@"DBP"] integerValue];
        }
        if ([allkeys containsObject:@"heartRate"]) {
            _heartRate = [dict[@"heartRate"] integerValue];
        }
        if ([allkeys containsObject:@"temp"]) {
            _temp = [dict[@"temp"] floatValue];
        }
        if ([allkeys containsObject:@"date"]) {
            _date = dict[@"date"];
        }
        if (_SBP!=0 && _DBP!=0 && _heartRate!=0) {
            _type = MeasurementType_BPMeter;
            _describe = [BPMeterModelHelper BPvalueDescription:_DBP HPvalue:_SBP];
        }else{
            _type = MeasurementType_Temp;
            _describe = [ThermometerModel valueDescription:_temp];
        }
    }
    return self;
}

- (void)setTemp:(float)temp{
    _temp = [[NSString stringWithFormat:@"%.1f",temp] floatValue];
}

- (NSString *)fromName{
    if (_mac) {
        _fromName = [NSString stringWithFormat:@"来自:%@",[DeviceHelper getBLEDeviceName:self]];
    }
    return _fromName;
}

- (BOOL)isEqual:(id)object{
    if (![object isKindOfClass:[MeasurementsModel class]]) {
        return NO;
    }
    
    MeasurementsModel *new = (MeasurementsModel *)object;
    
    return [self.mac isEqualToString:new.mac] &&
    [self.name isEqualToString:new.name] &&
    [self.date isEqualToString:new.date] &&
    self.SBP == new.SBP &&
    self.DBP == new.DBP &&
    self.heartRate == new.heartRate &&
    [[NSString stringWithFormat:@"%.1f",self.temp] isEqualToString:[NSString stringWithFormat:@"%.1f",new.temp]];
}

- (NSDictionary *)getDictionary{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict[@"name"] = _name;
    dict[@"userId"] = [NSNumber numberWithInteger:_userId];
    dict[@"date"] = _date;
    dict[@"SBP"] = [NSNumber numberWithInteger:_SBP];
    dict[@"DBP"] = [NSNumber numberWithInteger:_DBP];
    dict[@"heartRate"] = [NSNumber numberWithInteger:_heartRate];
    dict[@"temp"] = [NSNumber numberWithFloat:_temp];
    dict[@"describe"] = self.describe;
    dict[@"fromName"] = self.fromName;
    return dict;
}

- (NSDictionary *)getJSDictionary{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict[@"name"] = _name;
    dict[@"userId"] = [NSNumber numberWithInteger:_userId];
    dict[@"date"] = _date;
    dict[@"SBP"] = [NSNumber numberWithInteger:_SBP];
    dict[@"DBP"] = [NSNumber numberWithInteger:_DBP];
    dict[@"heartRate"] = [NSNumber numberWithInteger:_heartRate];
    dict[@"temp"] = [NSNumber numberWithFloat:_temp];
    dict[@"describe"] = self.describe;
    dict[@"fromName"] = self.fromName;
    return dict;
}

@end
