//
//  YTKKeyValueStore.h
//  Ape
//
//  Created by TangQiao on 12-11-6.
//  Copyright (c) 2012年 TangQiao. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FMDatabaseQueue;

#define DRINK_PLAN_TABLE @"DRINK_PLAN_TABLE"

#define DRINK_REMIND_TABLE @"DRINK_REMIND_TABLE"

@interface YTKKeyValueItem : NSObject

@property (strong, nonatomic) NSString *itemId;
@property (strong, nonatomic) id itemObject;
@property (strong, nonatomic) NSDate *createdTime;

@end


@interface YTKKeyValueStore : NSObject

@property (strong, nonatomic, readonly) FMDatabaseQueue * dbQueue;

- (id)initDBWithName:(NSString *)dbName;

- (id)initWithDBWithPath:(NSString *)dbPath;

- (void)createTableWithName:(NSString *)tableName;

- (BOOL)isTableExists:(NSString *)tableName;

- (void)clearTable:(NSString *)tableName;

- (void)close;

///************************ Put&Get methods *****************************************

- (BOOL)putObject:(id)object withId:(NSString *)objectId intoTable:(NSString *)tableName;

- (id)getObjectById:(NSString *)objectId fromTable:(NSString *)tableName;

- (YTKKeyValueItem *)getYTKKeyValueItemById:(NSString *)objectId fromTable:(NSString *)tableName;

- (void)putString:(NSString *)string withId:(NSString *)stringId intoTable:(NSString *)tableName;

- (NSString *)getStringById:(NSString *)stringId fromTable:(NSString *)tableName;

- (void)putNumber:(NSNumber *)number withId:(NSString *)numberId intoTable:(NSString *)tableName;

- (NSNumber *)getNumberById:(NSString *)numberId fromTable:(NSString *)tableName;

- (NSArray *)getAllItemsFromTable:(NSString *)tableName;

- (NSArray *)getBatchFromTable:(NSString *)tableName StartIndex:(NSString *)startIndex Num:(NSString *)num;

- (NSUInteger)getCountFromTable:(NSString *)tableName;

-(NSArray *)getDayItemFromTabel:(NSString *)tableName withDay:(NSString *)day;

-(NSArray *)getMonthHasRecordDayFromTable:(NSString*)tableName withMonth:(NSString *)month;

- (BOOL)deleteObjectById:(NSString *)objectId fromTable:(NSString *)tableName;

- (void)deleteObjectsByIdArray:(NSArray *)objectIdArray fromTable:(NSString *)tableName;

- (void)deleteObjectsByIdPrefix:(NSString *)objectIdPrefix fromTable:(NSString *)tableName;

-(id)getLastObjectFromTable:(NSString *)tableName;

- (void)putObjectNative:(id)object withId:(NSString *)objectId intoTable:(NSString *)tableName;

#pragma mark 后增加

-(NSDictionary *)insertDataWithJSON:(NSString *)json;

-(NSDictionary *)queryDataWithJSON:(NSString *)json;

-(NSDictionary *)updateData:(NSString *)json;

-(NSDictionary *)removeData:(NSString *)json;



//获取周月年数据
-(id)getWeekDataWithUUID:(NSString *)tableName WithDate:(NSString *)date1 dateNum:(NSString *)num;

-(id)getMonthDataWithUUID:(NSString *)tableName WithDate:(NSString *)date1 Days:(NSString *)days eachDays:(NSString *)eachdays;

-(id)getYearDataWithUUID:(NSString *)tableName WithDate:(NSString *)date1 MonthNum:(NSString *)num;

@end
