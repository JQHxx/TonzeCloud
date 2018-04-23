//
//  DMManger.m
//  Newests
//
//  Created by AllenKwok on 15/9/8.
//  Copyright (c) 2015年 AllenKwok. All rights reserved.
//

#import "DBManager.h"
#import "DeviceModel.h"
#import "Product-Swift.h"

@interface DBManager ()
{
    FMDatabase *_database;
}
@end

@implementation DBManager

+(instancetype)shareManager{
    static DBManager *manger = nil;
    if (manger == nil) {
        manger = [[[self class] alloc]init];
    }
    return manger;
}

- (instancetype)init{
    if (self = [super init]) {
        [self initDatabase];
    }
    return self;
}

-(void)initDatabase{
    //1.获取数据库文件app.db的路径
    NSString *filePath = [self getFileFullPathWithFileName:@"app.db"];
   
    
    _database = [[FMDatabase alloc]initWithPath:filePath];
    if (_database.open) {
        NSLog(@"打开数据库成功");
        //创建表 不存在 则创建
        [self creatHistoryTable];
        [self creatNotiTable];
        [self creatBindingTable];
    }else{
        NSLog(@"打开数据库失败");
    }
}

#pragma mark - 获取文件的全路径

//获取文件在沙盒中的 Documents中的路径
- (NSString *)getFileFullPathWithFileName:(NSString *)fileName {
    NSString *docPath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents"];
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:docPath]) {
        //文件的全路径
        return [docPath stringByAppendingFormat:@"/%@",fileName];
    }else {
        //如果不存在可以创建一个新的
        NSLog(@"Documents不存在");
        return nil;
    }
}


#pragma mark - 历史记录

- (void)creatHistoryTable {
    
    NSString *sql = @"create table if not exists device(serial integer  Primary Key Autoincrement,deviceName Varchar(1024),authUser Varchar(1024),deviceType Varchar(1024),time Varchar(1024),deviceID Varchar(1024))";
        //创建表 如果不存在则创建新的表
    BOOL isSuccees = [_database executeUpdate:sql];
      if (!isSuccees) {
        NSLog(@"creat error:%@",_database.lastErrorMessage);
    }
  }


/** 添加历史记录*/
-(void)insertDevice:(DeviceModel *)model{
    
    NSArray *userArray=model.authUser.copy;
    NSString *userStr=@"";
    for (int i=0; i<userArray.count; i++) {
        if (i==0) {
            
            userStr=[userStr stringByAppendingString:[userArray objectAtIndex:i]];
            
        }else{
            userStr=[userStr stringByAppendingFormat:@"?%@",[userArray objectAtIndex:i]];
            
        }
        
    }
    
    
    if ([self isExistDevice:model]) {
        NSLog(@"this app has  recorded");
        NSString *sql = @"update device set deviceName=?,authUser=?,deviceType=?,time=? where deviceID =?";
        BOOL isSuccess = [_database executeUpdate:sql,model.deviceName,userStr,[NSString stringWithFormat:@"%li",(long)model.deviceType],model.time,model.deviceID];
        if (!isSuccess) {
            NSLog(@"update error:%@",_database.lastErrorMessage);
        }
        return;
    }
    NSString *sql = @"insert into device(deviceName,authUser,deviceType,time,deviceID) values (?,?,?,?,?)";
    BOOL isSuccess = [_database executeUpdate:sql,model.deviceName,userStr,[NSString stringWithFormat:@"%li",(long)model.deviceType],model.time,model.deviceID];
    if (!isSuccess) {
        NSLog(@"insert error:%@",_database.lastErrorMessage);
    }
}

//根据指定的类型 返回 这条记录在数据库中是否存在
- (BOOL)isExistDevice:(DeviceModel *)model{
    
    NSString *sql = @"select * from device where deviceID = ?";
    FMResultSet *rs = [_database executeQuery:sql,model.deviceID];
    if ([rs next]) {//查看是否存在 下条记录 如果存在 肯定 数据库中有记录
        return YES;
    }else{
        return NO;
    }
}

/** 查询历史记录*/
- (NSMutableArray *)readAllDevice{
    
    NSString *sql = @"select * from device ";
    FMResultSet * rs = [_database executeQuery:sql];
    
    NSMutableArray *arr = [NSMutableArray array];
    //遍历集合
    while ([rs next]) {
        
        DeviceModel *model = [[DeviceModel alloc]init];
        model.deviceName = [rs stringForColumn:@"deviceName"];
        NSString *userStr = [rs stringForColumn:@"authUser"];
        
        if ([userStr isEqualToString:@""]) {
            model.authUser=[[NSMutableArray alloc]init];
        }else{
            NSArray *funArr = [userStr componentsSeparatedByString:@"?"];
            model.authUser=[[NSMutableArray alloc]initWithArray:funArr];
        }

        model.deviceType = [rs stringForColumn:@"deviceType"].integerValue;
        model.deviceID = [[rs stringForColumn:@"deviceID"] intValue];
        model.time = [rs stringForColumn:@"time"];
        [arr addObject:model];
    }
    return arr;
}

/** 删除历史记录*/
- (void)deleteDevice:(DeviceModel *)model{
    
    NSString *sql = @"delete from device where deviceID=?";
    BOOL isSuccess = [_database executeUpdate:sql,model.deviceID];
    if (!isSuccess) {
        NSLog(@"delete error:%@",_database.lastErrorMessage);
    }
}

#pragma mark Noti
- (void)creatNotiTable {
    NSString *sql = @"create table if not exists notif(serial integer  Primary Key Autoincrement,userID Varchar(1024),notiTitle Varchar(1024),notiState Varchar(1024),deviceName Varchar(1024),time Varchar(1024),deviceID Varchar(1024),notiType Varchar(1024),deviceType Varchar(1024))";
    //创建表 如果不存在则创建新的表
    BOOL isSuccees = [_database executeUpdate:sql];
    if (!isSuccees) {
        NSLog(@"creatTable error:%@",_database.lastErrorMessage);
    }
}



/** 添加历史记录*/
-(void)insertNoti:(NotiModel *)model{
    //xlink的用户扩展属性的主账号的信息
    NSString *userID=[NSString stringWithFormat:@"%@",[[NSUserDefaultInfos getDicValueforKey:USER_DIC] valueForKey:@"user_id"]];
    NSString *sql = @"insert into notif(userID,notiTitle,notiState,deviceName,time,deviceID,notiType,deviceType) values (?,?,?,?,?,?,?,?)";
    BOOL isSuccess = [_database executeUpdate:sql,userID,model.notiTitle,model.notiState,model.deviceName,model.time,model.deviceID,model.notiType,model.deviceType];
    if (!isSuccess) {
        NSLog(@"insert error:%@",_database.lastErrorMessage);
    }
    
}

//根据指定的类型 返回 这条记录在数据库中是否存在
- (BOOL)isExistNoti:(NotiModel *)model{
    //xlink的用户扩展属性的主账号的信息
    NSString *userID=[NSString stringWithFormat:@"%@",[[NSUserDefaultInfos getDicValueforKey:USER_DIC] valueForKey:@"user_id"]];
    NSString *sql = @"select * from notif where deviceID = ? and userID = ?";
    FMResultSet *rs = [_database executeQuery:sql,model.deviceID,userID];
    if ([rs next]) {//查看是否存在 下条记录 如果存在 肯定 数据库中有记录
        return YES;
    }else{
        return NO;
    }
}

/** 查询历史记录*/
- (NSArray *)readAllNoti{
    //xlink的用户扩展属性的主账号的信息
    NSString *userID=[NSString stringWithFormat:@"%@",[[NSUserDefaultInfos getDicValueforKey:USER_DIC] valueForKey:@"user_id"]];
    NSString *sql = @"select * from notif where userID = ?";
    FMResultSet * rs = [_database executeQuery:sql,userID];
    
    NSMutableArray *arr = [NSMutableArray array];
    //遍历集合
    while ([rs next]) {
        
        NotiModel *model = [[NotiModel alloc]init];
        model.notiTitle = [rs stringForColumn:@"notiTitle"];
        model.notiState=[rs stringForColumn:@"notiState"];
        model.notiType=[rs stringForColumn:@"notiType"];
        model.deviceName = [rs stringForColumn:@"deviceName"];
        model.deviceID=[rs stringForColumn:@"deviceID"];
        model.time = [rs stringForColumn:@"time"];
        model.deviceType=[rs stringForColumn:@"deviceType"];
        [arr addObject:model];
    }
    return arr;
}

/** 删除历史记录*/
- (void)deleteNoti:(NotiModel *)model{
    //xlink的用户扩展属性的主账号的信息
    NSString *userID=[NSString stringWithFormat:@"%@",[[NSUserDefaultInfos getDicValueforKey:USER_DIC] valueForKey:@"user_id"]];
    NSString *sql = @"delete from notif where deviceID=? and userID = ?";
    BOOL isSuccess = [_database executeUpdate:sql,model.deviceID,userID];
    if (!isSuccess) {
        NSLog(@"delete error:%@",_database.lastErrorMessage);
    }
}

#pragma mark BLE Bindings

- (NSString *)bindingTableName {
    NSDictionary *dic=[NSUserDefaultInfos getDicValueforKey:USER_DIC];
    NSString *userId = [dic objectForKey:@"user_id"];
    return [NSString stringWithFormat:@"BindingDevice_%@", userId];
}

-(void)creatBindingTable{
    
    NSString * sql1 = [NSString stringWithFormat:@"CREATE TABLE '%@' ('id' INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL, 'name' VARCHAR(30), 'uuid' VARCHAR(30), 'type' INT,'date' TEXT, Unique('id'))", [self bindingTableName]];
    //创建表 如果不存在则创建新的表
    BOOL isSuccees1=[_database executeUpdate:sql1];
    
    if (!isSuccees1) {
        NSLog(@"creat1 error:%@",_database.lastErrorMessage);
    }
    
    
}

//插入记录
- (void)insertBindingDevice:(NSString*)Name UUID:(NSString*)uuid deviceType:(DeviceType)type Date:(NSString*)date{
    
    if ([self isExistBindingDevice:uuid]) {
        return;
    }
    
    NSString *sql = [NSString stringWithFormat:@"insert into %@ (name,uuid,type,date) values(?,?,?,?)", [self bindingTableName]];
    BOOL isSuccess = [_database executeUpdate:sql,Name,uuid,@(type),date];
    if (!isSuccess) {
        NSLog(@"insert error:%@",_database.lastErrorMessage);
    }
}

//根据指定的类型 返回 这条记录在数据库中是否存在
- (BOOL)isExistBindingDevice:(NSString *)uuid{
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where uuid = ? ", [self bindingTableName]];
    FMResultSet *rs = [_database executeQuery:sql,uuid];
    if ([rs next]) {//查看是否存在 下条记录 如果存在 肯定 数据库中有记录
        return YES;
    }else{
        return NO;
    }
}

/** 查询历史记录*/
- (NSArray *)readAllBindingDevice{
    
    NSString *sql = [NSString stringWithFormat:@"select * from %@ ", [self bindingTableName]];
    FMResultSet * rs = [_database executeQuery:sql];
    
    NSMutableArray *arr = [NSMutableArray array];
    //遍历集合
    while ([rs next]) {
        
        NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];

        [dic setObject:[rs stringForColumn:@"name"] forKey:@"name"];
        [dic setObject:[rs stringForColumn:@"uuid"] forKey:@"uuid"];
        [dic setObject:[rs stringForColumn:@"type"] forKey:@"type"];
        [dic setObject:[rs stringForColumn:@"date"] forKey:@"date"];
        [arr addObject:dic];
    }
    return arr;
}

/** 删除历史记录*/
- (BOOL)deleteBindingDevice:(NSString *)uuid{
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where uuid=?", [self bindingTableName]];
    
    BOOL isSuccess = [_database executeUpdate:sql,uuid];
    if (!isSuccess) {
        NSLog(@"delete error:%@",_database.lastErrorMessage);
    }
    
    return isSuccess;
}


#pragma mark - BLE设备记录

- (NSString *)bpmeterRecordsTableName:(NSInteger)loginUserId {
    return [NSString stringWithFormat:@"BPM_Record_%ld", (long)loginUserId];
}

-(BOOL)createBPMRecordsTable:(NSInteger)loginUserId {
    NSLog(@"创建血压记录表");
    
    NSString * sql1 = [NSString stringWithFormat:@"CREATE TABLE '%@' ('id' INTEGER PRIMARY KEY AUTOINCREMENT,'deviceUUID' VARCHAR(30), 'createDate' INT, 'memberId' INT, 'SBP' INT, 'DBP' INT, 'heartRate' INT, isHBUneven BOOL)", [self bpmeterRecordsTableName:loginUserId]];
    //创建表 如果不存在则创建新的表
    BOOL isSuccees=[_database executeUpdate:sql1];
    
    if (!isSuccees) {
        NSLog(@"createBPMRecordsTable error:%@",_database.lastErrorMessage);
    }
    return isSuccees;
}

-(BOOL)tableExists:(NSString *)tableName {
    NSString *sql = [NSString stringWithFormat:@"SELECT count(*) FROM sqlite_master WHERE type='table' AND name='%@';", tableName];
    FMResultSet *result = [_database executeQuery:sql];
    
    //遍历集合
    while ([result next]) {
        if ([result intForColumnIndex:0] > 0) {
            return YES;
        }
    }
    return NO;
}

///插入血压记录
- (BOOL)insertBPRecord:(BPRecord *)record
         bpMeterDevice:(BPMeterModel *)model
           loginUserId:(NSInteger)loginUserId
          memberUserId:(NSInteger )memberUserId {
    NSString *tableName = [self bpmeterRecordsTableName:loginUserId];
    if (![self tableExists:tableName]) {
        [self createBPMRecordsTable:loginUserId];
    }
    NSString *sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (deviceUUID,createDate,memberId,SBP,DBP,heartRate,isHBUneven) values(?,?,?,?,?,?,?)", tableName];
//    NSString *sql = [NSString stringWithFormat:@"REPLACE INTO %@ (deviceUUID,createDate,memberId,SBP,DBP,heartRate,isHBUneven) values(?,?,?,?,?,?,?)", tableName];
    BOOL isSuccess = [_database executeUpdate:sql,
                      model.BLEMacAddress,
                      @(record.date.timeIntervalSince1970),
                      @(record.userId),
                      @(record.SBP),
                      @(record.DBP),
                      @(record.heartRate),
                      @(record.isHBUneven)];
    if (!isSuccess) {
        NSLog(@"insert error:%@",_database.lastErrorMessage);
    }
    return isSuccess;
}

///读取血压记录
- (NSArray *)readBPRecords:(BPMeterModel *)model
               loginUserId:(NSInteger)loginUserId
              memberUserId:(NSInteger )memberUserId {
    
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where memberId=%ld", [self bpmeterRecordsTableName:loginUserId], (long)memberUserId];
    FMResultSet * rs = [_database executeQuery:sql];
    
    NSMutableArray *records = [NSMutableArray array];
    //遍历集合
    while ([rs next]) {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[rs intForColumn:@"createDate"]];
        BPRecord *record = [[BPRecord alloc] initWithDeviceUUID:[rs stringForColumn:@"deviceUUID"]
                                                           date:date
                                                            SBP:[rs intForColumn:@"SBP"]
                                                            DBP:[rs intForColumn:@"DBP"]
                                                      heartRate:[rs intForColumn:@"heartRate"]
                                                     isHBUneven:[rs boolForColumn:@"isHBUneven"]
                                                         userId:[rs intForColumn:@"memberId"]];
        [records addObject:record];
    }
    [records sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        BPRecord *record1 = (BPRecord *)obj1;
        BPRecord *record2 = (BPRecord *)obj2;
        return [record1.date compare:record2.date]==NSOrderedAscending;
    }];
    return records;
}


/**
 *  读取一个时间段血压记录
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
              memberUserId:(NSInteger )memberUserId {
    
    NSString *sql;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd 00:00:00";
    NSString *strOfHour0 = [formatter stringFromDate:oneDay];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *dayOfHout0   = [formatter dateFromString:strOfHour0];
    int startSecOfTheDay  = (int)dayOfHout0.timeIntervalSince1970;//开始当天的零点
    
    formatter.dateFormat = @"yyyy-MM-dd 00:00:00";
    NSString *strOfNextHour0 = [formatter stringFromDate:otherDay];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *dayOfNextHout0   = [formatter dateFromString:strOfNextHour0];
    int startSecOfNextDay  = (int)dayOfNextHout0.timeIntervalSince1970;
    startSecOfNextDay += (60 * 60 * 24 * 1);//结束当天的零点加一天的秒数
    
    sql = [NSString stringWithFormat:@"select * from %@ where  deviceUUID='%@' AND createDate >= %d AND createDate < %d and memberId = %ld", [self bpmeterRecordsTableName:loginUserId], model.BLEMacAddress, startSecOfTheDay, startSecOfNextDay, (long)memberUserId];
    
    FMResultSet * rs = [_database executeQuery:sql];
    
    NSMutableArray *records = [NSMutableArray array];
    //遍历集合
    while ([rs next]) {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[rs intForColumn:@"createDate"]];
        BPRecord *record = [[BPRecord alloc] initWithDeviceUUID:[rs stringForColumn:@"deviceUUID"]
                                                           date:date
                                                            SBP:[rs intForColumn:@"SBP"]
                                                            DBP:[rs intForColumn:@"DBP"]
                                                      heartRate:[rs intForColumn:@"heartRate"]
                                                     isHBUneven:[rs boolForColumn:@"isHBUneven"]
                                                         userId:[rs intForColumn:@"memberId"]];
        [records addObject:record];
    }
    return records;
}

///删除血压记录
- (void )deleteBPRecord:(BPMeterModel *)model
            loginUserId:(NSInteger)loginUserId
           memberUserId:(NSInteger )memberUserId
                   date:(NSDate *)date {
    
}

- (BOOL )deleteAllBPRecords:(BPMeterModel *)model loginUserId:(NSInteger)loginUserId {
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ where deviceUUID='%@'", [self bpmeterRecordsTableName:loginUserId], model.BLEMacAddress];
    BOOL isSuccess = [_database executeUpdate:sql];
    if (!isSuccess) {
        NSLog(@"delect error:%@",_database.lastErrorMessage);
    }
    return isSuccess;
}

#pragma mark - 体温计

- (NSString *)thermometerRecordsTableName:(NSInteger)loginUserId {
    return [NSString stringWithFormat:@"Thermometer_Record_%ld", (long)loginUserId];
}

-(BOOL)createThermometerRecordsTable:(NSInteger)loginUserId {
    NSLog(@"创建体温记录表");
    //deviceUUID改为BLEMacAddress
    NSString * sql = [NSString stringWithFormat:@"CREATE TABLE '%@' ('id' INTEGER PRIMARY KEY AUTOINCREMENT,'deviceUUID' VARCHAR(30), 'createDate' INT, 'memberId' INT, 'temperature' FLOAT)", [self thermometerRecordsTableName:loginUserId]];
    //创建表 如果不存在则创建新的表
    BOOL isSuccees=[_database executeUpdate:sql];
    
    if (!isSuccees) {
        NSLog(@"createBPMRecordsTable error:%@",_database.lastErrorMessage);
    }
    return isSuccees;
}

///插入体温记录(loginUserId==0&&memberUserId==0时，为设备历史记录数据)
- (BOOL)insertBodyTemperature:(BodyTempRecord *)record
               tmpMeterDevice:(ThermometerModel *)device
                  loginUserId:(NSInteger)loginUserId
                 memberUserId:(NSInteger )memberUserId {
    
    NSString *tableName = [self thermometerRecordsTableName:loginUserId];
    if (![self tableExists:tableName]) {
        [self createThermometerRecordsTable:loginUserId];
    }
    NSString *sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (deviceUUID,createDate,memberId,temperature) values(?,?,?,?)", tableName];
    
    BOOL isSuccess = [_database executeUpdate:sql,
                      device.BLEMacAddress,
                      @(record.date.timeIntervalSince1970),
                      @(record.memberId),
                      @(record.temperature)];
    if (!isSuccess) {
        NSLog(@"insert error:%@",_database.lastErrorMessage);
    }
    return isSuccess;
}

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
                    memberUserId:(NSInteger )memberUserId {
    
    NSString *sql;
    int daysOffset = dayWidth < 1 ? 1:(int)dayWidth;
    
    if (day) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd 00:00:00";
        NSString *strOfHour0 = [formatter stringFromDate:day];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        NSDate *dayOfHour0   = [formatter dateFromString:strOfHour0];
        
        int startSecOfTheDay  = (int)dayOfHour0.timeIntervalSince1970;
        int startSecOfNextDay = startSecOfTheDay + (60 * 60 * 24 * daysOffset);  //加daysOffset天的秒数得到第daysOffset+1天的0点
        sql = [NSString stringWithFormat:@"select * from %@ where  deviceUUID='%@' AND createDate >= %d AND createDate < %d and memberId = %ld", [self thermometerRecordsTableName:loginUserId], model.BLEMacAddress, startSecOfTheDay, startSecOfNextDay, (long)memberUserId];
    } else {
        sql = [NSString stringWithFormat:@"select * from %@ where  deviceUUID='%@' AND memberId = %ld", [self thermometerRecordsTableName:loginUserId], model.BLEMacAddress, (long)memberUserId];
    }
    FMResultSet * rs = [_database executeQuery:sql];
    
    NSMutableArray *records = [NSMutableArray array];
    //遍历集合
    while ([rs next]) {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[rs intForColumn:@"createDate"]];
        BodyTempRecord *record = [[BodyTempRecord alloc] initWithDeviceUUID:[rs stringForColumn:@"deviceUUID"]
                                                                       date:date
                                                                temperature:[rs doubleForColumn:@"temperature"]
                                                                   memberId:[rs intForColumn:@"memberId"]];
        [records addObject:record];
    }
    return records;
}

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
                  memberUserId:(NSInteger)memberUserId {
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd 00:00:00";
    NSString *strOfHour0 = [formatter stringFromDate:day];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *dayOfHout0   = [formatter dateFromString:strOfHour0];
    
    int daysOffset = dayWidth < 1 ? 1:(int)dayWidth;
    int startSecOfTheDay  = (int)dayOfHout0.timeIntervalSince1970;
    int startSecOfNextDay = startSecOfTheDay + (60 * 60 * 24 * daysOffset);  //加daysOffset天的秒数得到第daysOffset+1天的0点
    
    NSString *tableName = [self thermometerRecordsTableName:loginUserId];
    NSString *uuid = device.BLEMacAddress;
    
    NSString *funcName;
    switch (function) {
        case BodyTempRecordFuncMax:
            funcName = @"MAX";
            break;
        case BodyTempRecordFuncMin:
            funcName = @"MIN";
            break;
        default:
            funcName = @"AVG";
    }

    NSString *sql = [NSString stringWithFormat:@"SELECT %@(temperature) from %@ WHERE deviceUUID='%@' and createDate >= %d AND createDate < %d and memberId = %ld", funcName, tableName, uuid, startSecOfTheDay, startSecOfNextDay, (long)memberUserId];
    
    FMResultSet * rs = [_database executeQuery:sql];
    while ([rs next]) {
        return [rs doubleForColumnIndex:0];
    }
    return 0;
}

///删除体温记录
- (void )deleteBodyTempRecord:(ThermometerModel *)model loginUserId:(NSInteger)loginUserId memberUserId:(NSInteger )memberUserId date:(NSDate *)date {
    
}

///删除设备的所有体温记录
- (BOOL )deleteAllBodyTempRecords:(ThermometerModel *)model loginUserId:(NSInteger)loginUserId {
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ where deviceUUID='%@'", [self thermometerRecordsTableName:loginUserId], model.BLEMacAddress];
    BOOL isSuccess = [_database executeUpdate:sql];
    if (!isSuccess) {
        NSLog(@"insert error:%@",_database.lastErrorMessage);
    }
    return isSuccess;
}



@end
