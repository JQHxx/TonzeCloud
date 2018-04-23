//
//  Shop_DBController.m
//  Order
//
//  Created by wzy on 28/3/17.
//  Copyright © 2017年 wzy. All rights reserved.
//

#import "BLEDevice_DBController.h"

@implementation BLEDevice_DBController

/**
 *  插入数据
 */
- (void)insertBLEDevice:(BLEDeviceModel *)model
{
    if (![self.dataStore isTableExists:self.tableName]) {
        [self.dataStore createTableWithName:self.tableName];
    }
    
    if(model)
    {
        NSDictionary * dic = [BLEDeviceModel getModelDictionary:model];

        [self.dataStore putObjectNative:dic withId:model.deviceName intoTable:self.tableName];
    }
}

/**
 *  返回列表
 */
-(NSArray *)getAllBLEDevice
{
    NSArray * array = [self.dataStore getAllItemsFromTable:self.tableName];
    
    NSMutableArray * arrayContent = [NSMutableArray array];
    for (NSDictionary * dic in array) {
        id json = dic[@"json"];
        if (json) {
            NSError * error;
            id result = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding]
                                                        options:(NSJSONReadingAllowFragments) error:&error];
            if (error) {
                return nil;
            }
            if ([result isKindOfClass:[NSDictionary class]])
            {
                BLEDeviceModel * model = [[BLEDeviceModel alloc] init];
                model.deviceName = result[@"name"];
                model.deviceType = [result[@"deviceType"] integerValue];
                [arrayContent addObject:model];

            }
        }
    }
    return arrayContent;
}


/**
 *  获取Device
 *
 *  @return 返回Device
 */
- (BLEDeviceModel *)getBLEDevice:(NSString *)deviceName;
{
    BLEDeviceModel * model = nil;
    NSDictionary * dic = [self.dataStore getObjectById:deviceName fromTable:self.tableName];
    
    if ([dic isKindOfClass:[NSDictionary class]])
    {
        model = [[BLEDeviceModel alloc] init];
        model.deviceType = [dic[@"deviceType"] integerValue];
        model.deviceName = dic[@"name"];
    }
    
    return model;
}

/**
 *  删除设备
 */
-(void)deleteBLEDevice:(NSString *)deviceName;
{
    [self.dataStore deleteObjectById:deviceName fromTable:self.tableName];
}


/**
 *  删除数据
 */
- (void)deleteBLEDevice
{
    [self.dataStore clearTable:self.tableName];
}


@end
