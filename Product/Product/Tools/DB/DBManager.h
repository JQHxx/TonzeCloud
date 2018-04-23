//
//  DMManger.h
//  Newests
//
//  Created by AllenKwok on 15/9/8.
//  Copyright (c) 2015年 AllenKwok. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "DeviceModel.h"
#import "BLEDeviceModel.h"
#import "BPMeterModel.h"
#import "NotiModel.h"
#import "ThermometerModel.h"

#define MaxRecord 50

@class BPRecord;
@class BodyTempRecord;

///体温记录的计算方法
typedef NS_ENUM(NSInteger, BodyTempRecordFunc) {
    ///最大值
    BodyTempRecordFuncMax,
    ///最小值
    BodyTempRecordFuncMin,
    ///平均值
    BodyTempRecordFuncAvg,
};

@interface DBManager : NSObject

+(instancetype)shareManager;


-(void)insertDevice:(DeviceModel *)model;

- (NSMutableArray *)readAllDevice;

-(void)deleteDevice:(DeviceModel*)model;



-(void)insertNoti:(NotiModel *)model;

-(NSArray*)readAllNoti;

-(void)deleteNoti:(NotiModel *)model;

- (void)insertBindingDevice:(NSString*)Name UUID:(NSString*)uuid deviceType:(DeviceType)type Date:(NSString*)date;

- (NSArray *)readAllBindingDevice;


- (BOOL)deleteBindingDevice:(NSString *)uuid;


#pragma mark - 血压计记录

///插入血压记录
- (BOOL)insertBPRecord:(BPRecord *)record bpMeterDevice:(BPMeterModel *)model loginUserId:(NSInteger)loginUserId memberUserId:(NSInteger )memberUserId;

///读取血压记录
///@return:BPRecord数组
- (NSArray *)readBPRecords:(BPMeterModel *)model loginUserId:(NSInteger)loginUserId memberUserId:(NSInteger )memberUserId;


/**
 *  读取一个时间段的血压记录
 *
 *  @param model        血压计
 *  @param oneDay       开始时间
 *  @param otherDay     结束时间
 *  @param loginUserId  登陆的用户ID
 *  @param memberUserId 家庭成员ID
 *
 *  @return RecordEntry数组
 */
- (NSArray *)readBPRecords:(BPMeterModel *)model
               fromeOneDay:(NSDate *)oneDay
                toOtherDay:(NSDate *)otherDay
               loginUserId:(NSInteger)loginUserId
              memberUserId:(NSInteger )memberUserId ;

///删除血压记录
- (void )deleteBPRecord:(BPMeterModel *)model loginUserId:(NSInteger)loginUserId memberUserId:(NSInteger )memberUserId date:(NSDate *)date;

///删除设备的所有血压记录
- (BOOL )deleteAllBPRecords:(BPMeterModel *)model loginUserId:(NSInteger)loginUserId;

#pragma mark - 体温计记录

///插入体温记录
- (BOOL)insertBodyTemperature:(BodyTempRecord *)record tmpMeterDevice:(ThermometerModel *)device loginUserId:(NSInteger)loginUserId memberUserId:(NSInteger )memberUserId;

/**
 *  读取体温记录
 *
 *  @param model        血压计
 *  @param forOneDay    某天，设为nil则不限制
 *  @param dayWidth     时间宽度，单位为天，最小为1天
 *  @param loginUserId  登陆的用户ID
 *  @param memberUserId 家庭成员ID
 *
 *  @return BodyTempRecord数组
 */
- (NSArray *)readBodyTempRecords:(ThermometerModel *)model
                       forOneDay:(NSDate *)day
                        dayWidth:(NSInteger)dayWidth
                     loginUserId:(NSInteger)loginUserId
                    memberUserId:(NSInteger )memberUserId;

/**
 *  查询体温的计算值，如最大、最小、平均值
 *
 *  @param device       体温计设备
 *  @param forOneDay    某一天
 *  @param dayWidth     时间宽度，单位为天，最小为1天
 *  @param function     计算方法，
 *  @param loginUserId  登陆的用户ID
 *  @param memberUserId 家庭成员ID
 *
 *  @return 结果值
 */
- (double)queryBodyTemperature:(ThermometerModel *)device
                     forOneDay:(NSDate *)day
                      dayWidth:(NSInteger)dayWidth
                      function:(BodyTempRecordFunc)function
                   loginUserId:(NSInteger)loginUserId
                  memberUserId:(NSInteger )memberUserId;

///删除体温记录
- (void )deleteBodyTempRecord:(ThermometerModel *)model loginUserId:(NSInteger)loginUserId memberUserId:(NSInteger )memberUserId date:(NSDate *)date;

///删除设备的所有体温记录
- (BOOL )deleteAllBodyTempRecords:(ThermometerModel *)model loginUserId:(NSInteger)loginUserId;



@end
