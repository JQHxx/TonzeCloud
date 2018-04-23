//
//  YTKKeyValueStore.m
//  Ape
//
//  Created by TangQiao on 12-11-6.
//  Copyright (c) 2012年 TangQiao. All rights reserved.
//

#import "YTKKeyValueStore.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "FMDatabaseQueue.h"
#import "NSUserDefaultInfos.h"
#import "Transform.h"

#ifdef DEBUG
#define debugLog(...)    NSLog(__VA_ARGS__)
#define debugMethod()    NSLog(@"%s", __func__)
#define debugError()     NSLog(@"Error at %s Line:%d", __func__, __LINE__)
#else
#define debugLog(...)
#define debugMethod()
#define debugError()
#endif

#define PATH_OF_DOCUMENT    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]

@implementation YTKKeyValueItem

- (NSString *)description {
    return [NSString stringWithFormat:@"id=%@, value=%@, timeStamp=%@", _itemId, _itemObject, _createdTime];
}

@end

@interface YTKKeyValueStore()

@property (strong, nonatomic) FMDatabaseQueue * dbQueue;

@end

@implementation YTKKeyValueStore

static NSString *const DEFAULT_DB_NAME = @"database.sqlite";

static NSString *const CREATE_TABLE_SQL =
@"CREATE TABLE IF NOT EXISTS %@ ( \
id TEXT NOT NULL, \
json TEXT NOT NULL, \
createdTime TEXT NOT NULL, \
PRIMARY KEY(id)) \
";

static NSString *const UPDATE_ITEM_SQL = @"REPLACE INTO %@ (id, json, createdTime) values (?, ?, ?)";

static NSString *const QUERY_ITEM_SQL = @"SELECT json, createdTime from %@ where id = ? Limit 1";

static NSString *const SELECT_ALL_SQL = @"SELECT * from %@";

static NSString *const COUNT_ALL_SQL = @"SELECT count(*) as num from %@";

static NSString *const CLEAR_ALL_SQL = @"DELETE from %@";

static NSString *const DELETE_ITEM_SQL = @"DELETE from %@ where id = ?";

static NSString *const DELETE_ITEMS_SQL = @"DELETE from %@ where id in ( %@ )";

static NSString *const DELETE_ITEMS_WITH_PREFIX_SQL = @"DELETE from %@ where id like ? ";

static NSString *const GET_LAST_OBJECT = @"select * from %@ order by id";

+ (BOOL)checkTableName:(NSString *)tableName {
    if (tableName == nil || tableName.length == 0 || [tableName rangeOfString:@" "].location != NSNotFound) {
        debugLog(@"ERROR, table name: %@ format error.", tableName);
        return NO;
    }
    return YES;
}

- (id)init {
    return [self initDBWithName:DEFAULT_DB_NAME];
}

- (id)initDBWithName:(NSString *)dbName {
    self = [super init];
    
    if (self) {
        NSString * dbPath = [PATH_OF_DOCUMENT stringByAppendingPathComponent:dbName];
        debugLog(@"dbPath = %@", dbPath);
        if (_dbQueue) {
            [self close];
        }
        _dbQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    }
    return self;
}

- (id)initWithDBWithPath:(NSString *)dbPath {
    self = [super init];
    if (self) {
        debugLog(@"dbPath = %@", dbPath);
        if (_dbQueue) {
            [self close];
        }
        _dbQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    }
    return self;
}

- (void)createTableWithName:(NSString *)tableName {
    
    if ([YTKKeyValueStore checkTableName:tableName] == NO) {
        return;
    }
    
    
    NSString * sql = [NSString stringWithFormat:CREATE_TABLE_SQL, tableName];
    __block BOOL result;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql];
    }];
    if (!result) {
        debugLog(@"ERROR, failed to create table: %@", tableName);
    }
    
    
}



- (BOOL)isTableExists:(NSString *)tableName{
    if ([YTKKeyValueStore checkTableName:tableName] == NO) {
        return NO;
    }
    __block BOOL result;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        result = [db tableExists:tableName];
    }];
    if (!result) {
        debugLog(@"ERROR, table: %@ not exists in current DB", tableName);
    }
    return result;
}

- (void)clearTable:(NSString *)tableName {
    if ([YTKKeyValueStore checkTableName:tableName] == NO) {
        return;
    }
    NSString * sql = [NSString stringWithFormat:CLEAR_ALL_SQL, tableName];
    __block BOOL result;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql];
    }];
    if (!result) {
        debugLog(@"ERROR, failed to clear table: %@", tableName);
    }
}

- (BOOL)putObject:(id)object withId:(NSString *)objectId intoTable:(NSString *)tableName {
    
    BOOL PutResult;
    if ([self isTableExists:tableName] == NO) {
//        return;
        
        [self createTableWithName:tableName];
    }
    NSError * error;
//    NSData * data = [NSJSONSerialization dataWithJSONObject:object options:0 error:&error];
    if (error) {
        debugLog(@"ERROR, faild to get json data");
        PutResult=NO;
    }else{
//        NSString * jsonString = [[NSString alloc] initWithData:data encoding:(NSUTF8StringEncoding)];
        NSString * jsonString = object;
        
        NSString *date=[NSUserDefaultInfos getCurrentDate];
        
        NSString * sql = [NSString stringWithFormat:UPDATE_ITEM_SQL, tableName];
        __block BOOL result;
        [_dbQueue inDatabase:^(FMDatabase *db) {
            result = [db executeUpdate:sql, objectId, jsonString, date];
        }];
        if (!result) {
            debugLog(@"ERROR, failed to insert/replace into table: %@", tableName);
             PutResult=NO;
        }else{
         PutResult=YES;
        }
    }
    return PutResult;
}

-(id)getWeekDataWithUUID:(NSString *)tableName WithDate:(NSString *)date1 dateNum:(NSString *)num{
    if ([YTKKeyValueStore checkTableName:tableName] == NO) {
        return nil;
    }
    
    NSDate *date=[Transform dateStrToDate:date1];
    
    __block     NSMutableArray *resultArr=[[NSMutableArray alloc]init];
    
    for (int i=0;i<num.intValue;i++) {
        NSDate *Date=[NSDate dateWithTimeInterval:-3600*24*i sinceDate:date];
        NSString *dateStr=[[Transform dateToDateStr:Date]substringToIndex:10];
        
        NSString * sql = [NSString stringWithFormat:@"SELECT json, createdTime from \'%@\' where createdTime >=\'%@ 00:00:00\'  and createdTime<=\'%@ 23:59:59\'", tableName,dateStr,dateStr];
        
        __block NSString * json = nil;
        __block NSString * createdTime = nil;
        __block float weight=0;
        __block  int dataCount=0;

        [_dbQueue inDatabase:^(FMDatabase *db) {
            FMResultSet * rs = [db executeQuery:sql];
            while ([rs next]) {
                
                json = [rs stringForColumn:@"json"];
                NSDictionary *dataDic=[Transform dictionaryWithJsonString:json];
                createdTime = [rs stringForColumn:@"createdTime"];
                weight=weight+[dataDic[@"weight"] floatValue];
                dataCount++;
                
            }
            
        
            NSDictionary *dic=[[NSDictionary alloc]initWithObjectsAndKeys:[NSString stringWithFormat:@"%.2f",weight/dataCount],@"weight",[dateStr substringToIndex:10],@"date", nil];
            
            [resultArr addObject:dic];
            
            [rs close];
        }];
        
        
    }
    
     return resultArr;

}


-(id)getMonthDataWithUUID:(NSString *)tableName WithDate:(NSString *)date1 Days:(NSString *)days eachDays:(NSString *)eachdays{
    if ([YTKKeyValueStore checkTableName:tableName] == NO) {
        return nil;
    }
    __block     NSMutableArray *resultArr=[[NSMutableArray alloc]init];
    
    NSDate *date=[Transform dateStrToDate:date1];
    
    for (int i=0;i<([days intValue]/[eachdays intValue]);i++) {
        NSDate *startDate=[NSDate dateWithTimeInterval:-3600*24*i*[eachdays intValue] sinceDate:date];
        NSDate *endDate=[NSDate dateWithTimeInterval:-3600*24*[eachdays intValue] sinceDate:startDate];
        
        
        NSString * sql = [NSString stringWithFormat:@"SELECT json, createdTime from \'%@\' where createdTime <=\'%@\'  and createdTime>=\'%@\'", tableName,[Transform dateToDateStr:startDate],[Transform dateToDateStr:endDate]];

        __block NSString * json = nil;
        __block NSString * createdTime = nil;
        __block float weight=0;
        __block  int dataCount=0;
        [_dbQueue inDatabase:^(FMDatabase *db) {
            FMResultSet * rs = [db executeQuery:sql];
            
            
            while ([rs next]) {
                json = [rs stringForColumn:@"json"];
                NSDictionary *dataDic=[Transform dictionaryWithJsonString:json];
                createdTime = [rs stringForColumn:@"createdTime"];
                weight=weight+[dataDic[@"weight"] floatValue];
                dataCount++;
                
            }
            
              NSDictionary *dic=[[NSDictionary alloc]initWithObjectsAndKeys:[NSString stringWithFormat:@"%.2f",weight/dataCount],@"weight",[[Transform dateToDateStr:startDate] substringToIndex:10],@"endDate",[[Transform dateToDateStr:endDate] substringToIndex:10],@"startDate", nil];
            
            [resultArr addObject:dic];
            
            [rs close];
        }];

        
    }
    
    return resultArr;
}

-(id)getYearDataWithUUID:(NSString *)tableName WithDate:(NSString *)date1 MonthNum:(NSString *)num{
    if ([YTKKeyValueStore checkTableName:tableName] == NO) {
        return nil;
    }
    __block     NSMutableArray *resultArr=[[NSMutableArray alloc]init];

//    NSDate *date=[Transform dateStrToDate:date1];
    int year=[[date1 substringToIndex:4]intValue];;
    int month=[[date1 substringWithRange:NSMakeRange(5, 2)]intValue];
    
    for (int i=0;i<11;i++) {
        month=month-i;
        if (month==0) {
            year--;
            month=12;
        }
        
        NSString *monthStr=month>9?[NSString stringWithFormat:@"%i",month]:[NSString stringWithFormat:@"0%i",month];
        
        NSString * sql = [NSString stringWithFormat:@"SELECT json, createdTime from \'%@\' where createdTime >=\'%@\' and createdTime<=\'%@\'", tableName,[NSString stringWithFormat:@"%i-%@-00 00:00:00",year,monthStr],[NSString stringWithFormat:@"%i-%@-31 23:59:59",year,monthStr]];
        
        __block NSString * json = nil;
        __block NSString * createdTime = nil;
        __block float weight=0;
        __block  int dataCount=0;
        [_dbQueue inDatabase:^(FMDatabase *db) {
            FMResultSet * rs = [db executeQuery:sql];
            while ([rs next]) {
                json = [rs stringForColumn:@"json"];
                NSDictionary *dataDic=[Transform dictionaryWithJsonString:json];
                createdTime = [rs stringForColumn:@"createdTime"];
                weight=weight+[dataDic[@"weight"] floatValue];
                dataCount++;
                
            }
            
            NSDictionary *dic=[[NSDictionary alloc]initWithObjectsAndKeys:[NSString stringWithFormat:@"%.2f",weight/dataCount],@"weight",[NSString stringWithFormat:@"%i-%i",year,month],@"date", nil];
            
            [resultArr addObject:dic];
            
            [rs close];
        }];
    }
    
    return resultArr;
}

- (id)getObjectById:(NSString *)objectId fromTable:(NSString *)tableName {
    YTKKeyValueItem * item = [self getYTKKeyValueItemById:objectId fromTable:tableName];
    if (item) {
        return item.itemObject;
    } else {
        return nil;
    }
}

- (YTKKeyValueItem *)getYTKKeyValueItemById:(NSString *)objectId fromTable:(NSString *)tableName {
    if ([YTKKeyValueStore checkTableName:tableName] == NO) {
        return nil;
    }
    NSString * sql = [NSString stringWithFormat:QUERY_ITEM_SQL, tableName];
    __block NSString * json = nil;
    __block NSDate * createdTime = nil;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet * rs = [db executeQuery:sql, objectId];
        if ([rs next]) {
            json = [rs stringForColumn:@"json"];
            createdTime = [rs dateForColumn:@"createdTime"];
        }
        [rs close];
    }];
    if (json) {
        NSError * error;
        id result = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding]
                                                    options:(NSJSONReadingAllowFragments) error:&error];
        if (error) {
            debugLog(@"ERROR, faild to prase to json");
            return nil;
        }
        YTKKeyValueItem * item = [[YTKKeyValueItem alloc] init];
        item.itemId = objectId;
        item.itemObject = result;
        item.createdTime = createdTime;
        return item;
    } else {
        return nil;
    }
}

- (void)putString:(NSString *)string withId:(NSString *)stringId intoTable:(NSString *)tableName {
    if (string == nil) {
        debugLog(@"error, string is nil");
        return;
    }
    [self putObject:@[string] withId:stringId intoTable:tableName];
}

- (NSString *)getStringById:(NSString *)stringId fromTable:(NSString *)tableName {
    NSArray * array = [self getObjectById:stringId fromTable:tableName];
    if (array && [array isKindOfClass:[NSArray class]]) {
        return array[0];
    }
    return nil;
}

- (void)putNumber:(NSNumber *)number withId:(NSString *)numberId intoTable:(NSString *)tableName {
    if (number == nil) {
        debugLog(@"error, number is nil");
        return;
    }
    [self putObject:@[number] withId:numberId intoTable:tableName];
}

- (NSNumber *)getNumberById:(NSString *)numberId fromTable:(NSString *)tableName {
    NSArray * array = [self getObjectById:numberId fromTable:tableName];
    if (array && [array isKindOfClass:[NSArray class]]) {
        return array[0];
    }
    return nil;
}

-(NSArray *)getDayItemFromTabel:(NSString *)tableName withDay:(NSString *)day{
    if ([YTKKeyValueStore checkTableName:tableName] == NO) {
        return nil;
    }
    NSString * sql = [NSString stringWithFormat:@"SELECT * from %@ where createdTime>=\'%@ 00:00:00\' and createdTime<=\'%@ 23:59:59\' ", tableName,day,day];
    __block NSMutableArray * result = [NSMutableArray array];
    [_dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet * rs = [db executeQuery:sql];
        while ([rs next]) {
            
            NSString *idStr=[rs stringForColumn:@"id"];
            NSString *jsonStr=[rs stringForColumn:@"json"];
            NSString *createdTimeStr=[rs stringForColumn:@"createdTime"];
            
            NSDictionary *dic=[[NSDictionary alloc]initWithObjectsAndKeys:idStr,@"id",jsonStr,@"json",createdTimeStr,@"createdTime", nil];
            [result addObject:dic];
        }
        [rs close];
    }];
    
    return result;
}

-(NSArray *)getMonthHasRecordDayFromTable:(NSString*)tableName withMonth:(NSString *)month{

    if ([YTKKeyValueStore checkTableName:tableName] == NO) {
        return nil;
    }

    NSString * sql = [NSString stringWithFormat:@"SELECT * from %@ where createdTime>=\'%@-01 00:00:00\' and createdTime<=\'%@-31 23:59:59\'", tableName,month,month];
    __block NSMutableArray * result = [NSMutableArray array];
    [_dbQueue inDatabase:^(FMDatabase *db) {
        
        
        FMResultSet * rs = [db executeQuery:sql];
        while ([rs next]) {
//            NSString *idStr=[rs stringForColumn:@"id"];
//            NSString *jsonStr=[rs stringForColumn:@"json"];
            NSString *createdTimeStr=[rs stringForColumn:@"createdTime"];
//            NSDictionary *dic=[[NSDictionary alloc]initWithObjectsAndKeys:idStr,@"id",jsonStr,@"json",createdTimeStr,@"createdTime", nil];
            
            if (result.count==0) {
                  [result addObject:[createdTimeStr substringToIndex:10]];
            }else{
                NSString *lastDay=[result lastObject];
                if (![lastDay isEqualToString:[createdTimeStr substringToIndex:10]]) {
                    [result addObject:[createdTimeStr substringToIndex:10]];
                }
            }
            
          
        }
        [rs close];
    }];
    
    return result;

}

- (NSArray *)getAllItemsFromTable:(NSString *)tableName {
    if ([YTKKeyValueStore checkTableName:tableName] == NO) {
        return nil;
    }
    NSString * sql = [NSString stringWithFormat:SELECT_ALL_SQL, tableName];
    __block NSMutableArray * result = [NSMutableArray array];
    [_dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet * rs = [db executeQuery:sql];
        while ([rs next]) {
 
            NSString *idStr=[rs stringForColumn:@"id"];
            NSString *jsonStr=[rs stringForColumn:@"json"];
            NSString *createdTimeStr=[rs stringForColumn:@"createdTime"];
            
            NSDictionary *dic=[[NSDictionary alloc]initWithObjectsAndKeys:idStr,@"id",jsonStr,@"json",createdTimeStr,@"createdTime", nil];
            [result addObject:dic];
        }
        [rs close];
    }];

    return result;
}


- (NSArray *)getBatchFromTable:(NSString *)tableName StartIndex:(NSString *)startIndex Num:(NSString *)num{
    if ([YTKKeyValueStore checkTableName:tableName] == NO) {
        return nil;
    }
    NSString * sql = [NSString stringWithFormat:@"select * from %@ order by \"id\" desc limit %@,%@",tableName,startIndex,num];
    __block NSMutableArray * result = [NSMutableArray array];
    [_dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet * rs = [db executeQuery:sql];
        while ([rs next]) {
            NSString *idStr=[rs stringForColumn:@"id"];
            NSString *jsonStr=[rs stringForColumn:@"json"];
//            NSString *keyStr=[rs stringForColumn:@"key"];
            NSString *createdTimeStr=[rs stringForColumn:@"createdTime"];
            
            NSDictionary *dic=[[NSDictionary alloc]initWithObjectsAndKeys:idStr,@"id",jsonStr,@"json",createdTimeStr,@"createdTime", nil];
            [result addObject:dic];
        }
        [rs close];
    }];
    
    return result;

}


- (NSUInteger)getCountFromTable:(NSString *)tableName
{
    if ([YTKKeyValueStore checkTableName:tableName] == NO) {
        return 0;
    }
    NSString * sql = [NSString stringWithFormat:COUNT_ALL_SQL, tableName];
    __block NSInteger num = 0;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet * rs = [db executeQuery:sql];
        if ([rs next]) {
            num = [rs unsignedLongLongIntForColumn:@"num"];
        }
        [rs close];
    }];
    return num;
}

- (BOOL)deleteObjectById:(NSString *)objectId fromTable:(NSString *)tableName {
    BOOL DeResult;
    
    if ([YTKKeyValueStore checkTableName:tableName] == NO) {
        DeResult=NO;
    }else{
        NSString * sql = [NSString stringWithFormat:DELETE_ITEM_SQL, tableName];
        __block BOOL result;
        [_dbQueue inDatabase:^(FMDatabase *db) {
            result = [db executeUpdate:sql, objectId];
        }];
        if (!result) {
            debugLog(@"ERROR, failed to delete item from table: %@", tableName);
            DeResult=NO;
        }else{
            DeResult=YES;
        }
    }
    return DeResult;
}

- (void)deleteObjectsByIdArray:(NSArray *)objectIdArray fromTable:(NSString *)tableName {
    if ([YTKKeyValueStore checkTableName:tableName] == NO) {
        return;
    }
    NSMutableString *stringBuilder = [NSMutableString string];
    for (id objectId in objectIdArray) {
        NSString *item = [NSString stringWithFormat:@" '%@' ", objectId];
        if (stringBuilder.length == 0) {
            [stringBuilder appendString:item];
        } else {
            [stringBuilder appendString:@","];
            [stringBuilder appendString:item];
        }
    }
    NSString *sql = [NSString stringWithFormat:DELETE_ITEMS_SQL, tableName, stringBuilder];
    __block BOOL result;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql];
    }];
    if (!result) {
        debugLog(@"ERROR, failed to delete items by ids from table: %@", tableName);
    }
}

- (void)deleteObjectsByIdPrefix:(NSString *)objectIdPrefix fromTable:(NSString *)tableName {
    if ([YTKKeyValueStore checkTableName:tableName] == NO) {
        return;
    }
    NSString *sql = [NSString stringWithFormat:DELETE_ITEMS_WITH_PREFIX_SQL, tableName];
    NSString *prefixArgument = [NSString stringWithFormat:@"%@%%", objectIdPrefix];
    __block BOOL result;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql, prefixArgument];
    }];
    if (!result) {
        debugLog(@"ERROR, failed to delete items by id prefix from table: %@", tableName);
    }
}


-(id)getLastObjectFromTable:(NSString *)tableName{
    
    
    if ([YTKKeyValueStore checkTableName:tableName] == NO) {
        return nil;
    }
    NSString * sql = [NSString stringWithFormat:GET_LAST_OBJECT, tableName];
    __block NSMutableDictionary *resultDict = nil;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        
        FMResultSet * rs = [db executeQuery:sql];
        if ([rs next]) {
            resultDict = @{}.mutableCopy;
            resultDict[@"weight"] = [rs objectForColumnName:@"weight"];
            resultDict[@"bmi"] = [rs objectForColumnName:@"bmi"];
            NSTimeInterval interval = [rs doubleForColumn:@"creatTime"];
            interval = interval / 1000;
            resultDict[@"creatTime"] = [NSDate dateWithTimeIntervalSince1970:interval];
        }
        [rs close];
    }];
    if (resultDict) {
        YTKKeyValueItem * item = [[YTKKeyValueItem alloc] init];
        item.itemObject = resultDict;
        item.createdTime = resultDict[@"creatTime"];
        return item;
    } else {
        return nil;
    }
    
}


- (void)close {
    [_dbQueue close];
    _dbQueue = nil;
}

- (void)putObjectNative:(id)object withId:(NSString *)objectId intoTable:(NSString *)tableName {
    if ([YTKKeyValueStore checkTableName:tableName] == NO) {
        return;
    }
    NSError * error;
    NSData * data = [NSJSONSerialization dataWithJSONObject:object options:0 error:&error];
    if (error) {
        debugLog(@"ERROR, faild to get json data");
        return;
    }
    NSString * jsonString = [[NSString alloc] initWithData:data encoding:(NSUTF8StringEncoding)];
    NSDate * createdTime = [NSDate date];
    NSString * sql = [NSString stringWithFormat:UPDATE_ITEM_SQL, tableName];
    __block BOOL result;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql, objectId, jsonString, createdTime];
    }];
    if (!result) {
        debugLog(@"ERROR, failed to insert/replace into table: %@", tableName);
    }
}

#pragma mark 后加  插入
-(NSDictionary *)insertDataWithJSON:(NSString *)json{
    //    BOOL result;
    NSString *msg;
    //获取table名
    NSDictionary *dic=[Transform dictionaryWithJsonString:json];
    __block NSDictionary *resultDic;
    if ([dic objectForKey:@"table"]) {
        NSString *tableName=[dic objectForKey:@"table"];
        //判断是否需要建表
        if ([self isTableExists:tableName] == NO) {
            
            NSString *sqlCommand=[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' ( id INTEGER NOT NULL,",tableName];
            
            NSDictionary *dataDic=[dic objectForKey:@"data"];
            //拼取sql
            for (int i=0; i<=[dataDic allKeys].count-1; i++) {
               NSString *key=[[dataDic allKeys]objectAtIndex:i];
                NSString *type=@"";
                //判断类型
                if ([[dataDic objectForKey:key] isKindOfClass:[NSString class]]) {
                    type=@"TEXT";
                }else if ([[dataDic objectForKey:key] isKindOfClass:[NSNumber class]]) {
                    
                    
                    type=@" numeric(20,2) ";
                }
                
//                else if ([[[dataDic allKeys]objectAtIndex:i] isKindOfClass:[NSNumber class]]) {
//                    type=@"Number";
//                }
                
                
                if (i!=[dataDic allKeys].count-1) {

                   sqlCommand=[sqlCommand stringByAppendingString:[NSString stringWithFormat:@" %@ %@ NOT NULL,",key,type]];
  
                }else{
                    //最后处理
                    sqlCommand=[sqlCommand stringByAppendingString:[NSString stringWithFormat:@" %@ %@ NOT NULL,PRIMARY KEY(id))",key,type]];
                }
            }
            
            __block BOOL result;
            [_dbQueue inDatabase:^(FMDatabase *db) {
                result = [db executeUpdate:sqlCommand];
                if (!result) {
                    NSLog(@"ERROR: %@", db.lastError.localizedDescription);
                }
            }];
            if (!result) {
                debugLog(@"ERROR, failed to create table: %@", tableName);
                msg=([NSString stringWithFormat:@"ERROR, failed to create table: %@", tableName]);
                NSDictionary *resultDic=[[NSDictionary alloc]initWithObjectsAndKeys:[NSString stringWithFormat:@"%i",result],@"result",msg,@"msg",nil];
                return resultDic;
                
            }
            
            
        }
        //插入数据
        NSString *sqlCommand=[NSString stringWithFormat:@"insert into  '%@' (",tableName];
        NSString *valueCommand=@" values (";
        NSDictionary *dataDic=[dic objectForKey:@"data"];
        //拼取sql
        for (int i=0; i<=[dataDic allKeys].count-1; i++) {
            
            if (i!=[dataDic allKeys].count-1) {
                NSString *key=[[dataDic allKeys]objectAtIndex:i];
                sqlCommand=[sqlCommand stringByAppendingString:[NSString stringWithFormat:@" %@,",key]];
                
                valueCommand=[valueCommand stringByAppendingString:[NSString stringWithFormat:@"'%@',",[dataDic objectForKey:key]]];
                
            }else{
                //最后处理
                NSString *key=[[dataDic allKeys]objectAtIndex:i];
                sqlCommand=[sqlCommand stringByAppendingString:[NSString stringWithFormat:@" %@)",key]];
                
                valueCommand=[valueCommand stringByAppendingString:[NSString stringWithFormat:@"'%@' )",[dataDic objectForKey:key]]];
            }
            
        }
        sqlCommand =[sqlCommand stringByAppendingString:valueCommand];
        
        __block BOOL result;
        
        [_dbQueue inDatabase:^(FMDatabase *db) {
            result = [db executeUpdate:sqlCommand];
        }];
        
        
        if (!result) {
            debugLog(@"ERROR, failed to insert table: %@", tableName);
            
            msg=([NSString stringWithFormat:@"ERROR, failed to insert table: %@", tableName]);
            NSDictionary *resultDic=[[NSDictionary alloc]initWithObjectsAndKeys:[NSString stringWithFormat:@"%i",result],@"result",msg,@"msg",nil];
            return resultDic;
        }
        
        msg=[NSString stringWithFormat:@"success insert data"];
        resultDic=[[NSDictionary alloc]initWithObjectsAndKeys:[NSString stringWithFormat:@"%i",result],@"result",msg,@"msg",nil];
    }
    
    return resultDic;
    
}

#pragma mark 查询
-(NSDictionary *)queryDataWithJSON:(NSString *)json{
    
    
    NSDictionary *infoDic=[Transform dictionaryWithJsonString:json];
    NSString *table=[infoDic objectForKey:@"table"];
    
    if ([YTKKeyValueStore checkTableName:table] == NO) {
        
        return nil;
    }
    
    //  select * from %@ order by \"id\" desc limit %@,%@
    
    //用于拼sql语句的字段
    NSString *limitCommand=@"";   //偏移量
    NSString *filterCommand=@"";  //查询字段
    NSString *queryCommand=@"";    //查找
    NSString *groupCommand=@"";    //分组
    NSString *orderCommand=@"";// 排序字段
    
    //偏移量
    NSString *offset=[infoDic objectForKey:@"offset"];
    NSString *limit=[infoDic objectForKey:@"limit"];
    if (offset.integerValue==0&&limit.integerValue==0) {
        //查询全部数据
        limitCommand=@"";
    }else{
        limitCommand = [NSString stringWithFormat:@"limit %@,%@ ",offset,limit];
    }
    
    
    //查询字段
    NSArray *filterArr=[infoDic objectForKey:@"filter"];
    if (filterArr.count==0) {
        filterCommand=@"*";
    }else{
        for (int i=0; i<filterArr.count; i++) {
            if (i!=filterArr.count-1) {
                filterCommand=[filterCommand stringByAppendingString:[NSString stringWithFormat:@"%@,",[filterArr objectAtIndex:i]]];
            }else{
                //最后一个不需要加逗号
                filterCommand=[filterCommand stringByAppendingString:[NSString stringWithFormat:@" %@ ",[filterArr objectAtIndex:i]]];
            }
        }
    }
    
    NSArray *groupArr=[infoDic objectForKey:@"group"];
    if (groupArr.count>0) {
       NSString * groupStr=[groupArr objectAtIndex:0];
        
        groupCommand=[NSString stringWithFormat:@" group by %@ ",groupStr];
    }
    

    
    
    //排序字段
    NSDictionary *orderDic=[infoDic objectForKey:@"order"];
    if (orderDic.count>0) {
        NSString *key=[[orderDic allKeys] objectAtIndex:0];
        NSString *order=[orderDic objectForKey:key];
        
        orderCommand=[NSString stringWithFormat:@" order by upper (%@) %@ ",key,order];
    }
    
    //模糊查找
    NSDictionary *queryDic=[infoDic objectForKey:@"query"];
    if (queryDic) {
        for (int i=0; i<[queryDic allKeys].count; i++) {
            
            NSString *queryKey=[[queryDic allKeys]objectAtIndex:i];
            
            NSDictionary *detailDic=[queryDic objectForKey:queryKey];
            
            if (i==0) {
                for (int i=0; i<[detailDic allKeys].count; i++) {
                    NSString *key=[[detailDic allKeys]objectAtIndex:i];
                    //去掉key前面的$
                    if ([key isEqualToString:@"$like"]) {
                        //模糊
                        NSString *value=[detailDic objectForKey:key];
                        key=[key substringFromIndex:1];
                        if (i==0) {
                            if (queryCommand.length==0) {
                                  queryCommand=[NSString stringWithFormat:@" Where %@ %@ '%@'",queryKey,key,value];
                            }else{
                                queryCommand=[queryCommand stringByAppendingString:[NSString stringWithFormat:@" and %@ %@ '%@'",queryKey,key,value]];
                            }
 
                        }
                    }else if ([key isEqualToString:@"$in"]){
                        //包含
                        NSArray *valueArr=[detailDic objectForKey:key];
                        NSString *value=@"(";
                        key=[key substringFromIndex:1];
                        if (i==0) {
                            
                            if (queryCommand.length==0) {
                            queryCommand=[NSString stringWithFormat:@" Where %@ %@ ",queryKey,key];
                            }else{
                            queryCommand=[queryCommand stringByAppendingString:[NSString stringWithFormat:@" and %@ %@ ",queryKey,key]];
                            }
                            
                            
                            for (int i=0; i<valueArr.count; i++) {
                                if (i!=valueArr.count-1) {
                                    value=[value stringByAppendingString:[NSString stringWithFormat:@"\"%@\",",[valueArr objectAtIndex:i]]];
                                }else{
                                    value=[value stringByAppendingString:[NSString stringWithFormat:@"\"%@\")",[valueArr objectAtIndex:i]]];
                                }
                            }
                            
                            queryCommand=[queryCommand stringByAppendingString:value];
                            
                            
                        }
                    }else if ([key isEqualToString:@"$lt"]){
                        //小于
                      NSString  *ltStr=[detailDic objectForKey:key];
                        
                        
                        if (queryCommand.length==0) {
                         queryCommand=[NSString stringWithFormat:@" Where %@ < %@ ",queryKey,ltStr];
                        }else{
                        queryCommand=[queryCommand stringByAppendingString:[NSString stringWithFormat:@" and %@ < %@ ",queryKey,ltStr]];
                        }
                        
                    }else if ([key isEqualToString:@"$lte"]){
                        //小于等于
                        NSString  *ltStr=[detailDic objectForKey:key];
                        if (queryCommand.length==0) {
                            queryCommand=[NSString stringWithFormat:@" Where %@ <= %@ ",queryKey,ltStr];
                        }else{
                            queryCommand=[queryCommand stringByAppendingString:[NSString stringWithFormat:@" and %@ <= %@ ",queryKey,ltStr]];
                        }
                        
                    }else if ([key isEqualToString:@"$gt"]){
                        //大于
                        NSString  *ltStr=[detailDic objectForKey:key];
                        if (queryCommand.length==0) {
                            queryCommand=[NSString stringWithFormat:@" Where %@ > %@ ",queryKey,ltStr];
                        }else{
                            queryCommand=[queryCommand stringByAppendingString:[NSString stringWithFormat:@" and %@ > %@ ",queryKey,ltStr]];
                        }
                        
                    }else if ([key isEqualToString:@"$gte"]){
                        //大于等于
                        NSString  *ltStr=[detailDic objectForKey:key];
                        if (queryCommand.length==0) {
                            queryCommand=[NSString stringWithFormat:@" Where %@ >= %@ ",queryKey,ltStr];
                        }else{
                            queryCommand=[queryCommand stringByAppendingString:[NSString stringWithFormat:@" and %@ >= %@ ",queryKey,ltStr]];
                        }
                        
                    }
                }
            }else{
                {
                    for (int i=0; i<[detailDic allKeys].count; i++) {
                        NSString *key=[[detailDic allKeys]objectAtIndex:i];
                        //去掉key前面的$
                        if ([key isEqualToString:@"$like"]) {
                            NSString *value=[detailDic objectForKey:key];
                            key=[key substringFromIndex:1];
                            if (i==0) {
                                queryCommand=[queryCommand stringByAppendingString:[NSString stringWithFormat:@" and %@ %@ '%@'",queryKey,key,value]];
                            }
                        }else if ([key isEqualToString:@"$in"]){
                            NSArray *valueArr=[detailDic objectForKey:key];
                            NSString *value=@"(";
                            key=[key substringFromIndex:1];
                            if (i==0) {
                                queryCommand=[queryCommand stringByAppendingString:[NSString stringWithFormat:@" and %@ %@ ",queryKey,key]];
                                for (int i=0; i<valueArr.count; i++) {
                                    if (i!=valueArr.count-1) {
                                        value=[value stringByAppendingString:[NSString stringWithFormat:@"\"%@\",",[valueArr objectAtIndex:i]]];
                                    }else{
                                        value=[value stringByAppendingString:[NSString stringWithFormat:@"\"%@\")",[valueArr objectAtIndex:i]]];
                                    }
                                }
                                
                                queryCommand=[queryCommand stringByAppendingString:value];
                            }
                        }else if ([key isEqualToString:@"$lt"]){
                            //小于
                            NSString  *ltStr=[detailDic objectForKey:key];
                            
                            if (queryCommand.length==0) {
                                queryCommand=[NSString stringWithFormat:@" Where %@ < %@ ",queryKey,ltStr];
                            }else{
                                queryCommand=[queryCommand stringByAppendingString:[NSString stringWithFormat:@" and %@ < %@ ",queryKey,ltStr]];
                            }
                            
                        }else if ([key isEqualToString:@"$lte"]){
                            //小于等于
                            NSString  *ltStr=[detailDic objectForKey:key];
                            if (queryCommand.length==0) {
                                queryCommand=[NSString stringWithFormat:@" Where %@ <= %@ ",queryKey,ltStr];
                            }else{
                                queryCommand=[queryCommand stringByAppendingString:[NSString stringWithFormat:@" and %@ <= %@ ",queryKey,ltStr]];
                            }
                            
                        }else if ([key isEqualToString:@"$gt"]){
                            //大于
                            NSString  *ltStr=[detailDic objectForKey:key];
                            if (queryCommand.length==0) {
                                queryCommand=[NSString stringWithFormat:@" Where %@ > %@ ",queryKey,ltStr];
                            }else{
                                queryCommand=[queryCommand stringByAppendingString:[NSString stringWithFormat:@" and %@ > %@ ",queryKey,ltStr]];
                            }
                            
                        }else if ([key isEqualToString:@"$gte"]){
                            //大于等于
                            NSString  *ltStr=[detailDic objectForKey:key];
                            if (queryCommand.length==0) {
                                queryCommand=[NSString stringWithFormat:@" Where %@ >= %@ ",queryKey,ltStr];
                            }else{
                                queryCommand=[queryCommand stringByAppendingString:[NSString stringWithFormat:@" and %@ >= %@ ",queryKey,ltStr]];
                            }
                            
                        }

                    }
                }
            }
        }
    }
    
    //    columnCount
    
    //生成sql语句
    NSString *sql=@"select ";
    sql=[sql stringByAppendingString:filterCommand];
    sql=[sql stringByAppendingString:[NSString stringWithFormat:@" from '%@'",table]];
    sql=[sql stringByAppendingString:queryCommand];
    sql=[sql stringByAppendingString:groupCommand];
    sql = [sql stringByAppendingString:orderCommand];
    sql=[sql stringByAppendingString:limitCommand];
    
//    NSLog([NSString stringWithFormat:@"%@",sql]);
    
    __block  NSMutableArray *resultArr=[[NSMutableArray alloc]init];;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet * rs = [db executeQuery:sql];
        while ([rs next]) {
            NSMutableDictionary *rsDic=[[NSMutableDictionary alloc]init];
            
            
            for (int i=0; i<rs.columnCount; i++) {
                id value=[rs objectForColumnIndex:i];
                NSString *key=[rs columnNameForIndex:i];
                
                [rsDic setObject:value forKey:key];
                
            }
            
            [resultArr addObject:rsDic];
        }
        [rs close];
    }];
    
    NSDictionary *resultDic=[[NSDictionary alloc ]initWithObjectsAndKeys:[NSString stringWithFormat:@"%lu",(unsigned long)resultArr.count],@"count",resultArr,@"list", nil];
    
    return resultDic;
    
}


#pragma mark 更新数据
-(NSDictionary *)updateData:(NSString *)json{
    NSDictionary *infoDic=[Transform dictionaryWithJsonString:json];
    NSString *table=[infoDic objectForKey:@"table"];
    
    if ([YTKKeyValueStore checkTableName:table] == NO) {
        NSDictionary * resultDic=[[NSDictionary alloc]initWithObjectsAndKeys:[NSString stringWithFormat:@"%i",NO],@"result",@"table not exists ",@"msg", nil];
        return resultDic;
    }
    
    NSString *tableCommand=[NSString stringWithFormat:@"update '%@' set ",table];
    
    //数据命令
    NSString *valueCommand=@"";
    NSDictionary *dataDic=[infoDic objectForKey:@"data"];
    for (int i=0; i<dataDic.count; i++) {
        NSString *key=[[dataDic allKeys] objectAtIndex:i];
        NSString *value=[NSString stringWithFormat:@"%@",[dataDic objectForKey:key]];
        if (i<dataDic.count-1) {
            valueCommand=[valueCommand stringByAppendingString:[NSString stringWithFormat:@"%@='%@',",key,value]];
        }else{
            //最后处理
            valueCommand=[valueCommand stringByAppendingString:[NSString stringWithFormat:@"%@='%@'",key,value]];
        }
    }
    
    //位置命令
    NSString *queryCommand=@" ";
    NSDictionary *queryDic=[infoDic objectForKey:@"query"];
    for (int i=0; i<queryDic.count; i++) {
        NSString *key=[[queryDic allKeys] objectAtIndex:i];
        NSDictionary *valueDic=[queryDic objectForKey:key];
        if (i==0) {
            queryCommand=@" where ";
            
            NSString *inKey=[[valueDic allKeys]objectAtIndex:0];
            NSArray *inArr=[valueDic objectForKey:inKey];
            inKey=[inKey substringFromIndex:1];
            
            queryCommand=[queryCommand stringByAppendingString:[NSString stringWithFormat:@" %@ %@ (",key,inKey]];
            
            
            for ( int i=0; i<inArr.count; i++) {
                if (i!=inArr.count-1) {
                    queryCommand=[queryCommand stringByAppendingString:[NSString stringWithFormat:@"\"%@\",",inArr[i]]];
                }else{
                    queryCommand=[queryCommand stringByAppendingString:[NSString stringWithFormat:@"\"%@\")",inArr[i]]];
                }
                
            }
        }else{
            
            NSString *inKey=[[valueDic allKeys]objectAtIndex:0];
            NSArray *inArr=[valueDic objectForKey:inKey];
            inKey=[inKey substringFromIndex:1];
            
            queryCommand=[queryCommand stringByAppendingString:[NSString stringWithFormat:@" and %@ %@ (",key,inKey]];
            
            for ( int i=0; i<inArr.count; i++) {
                if (i!=inArr.count-1) {
                    queryCommand=[queryCommand stringByAppendingString:[NSString stringWithFormat:@"\"%@\",",inArr[i]]];
                }else{
                    queryCommand=[queryCommand stringByAppendingString:[NSString stringWithFormat:@"\"%@\")",inArr[i]]];
                }
                
            }
        }
    }
    //拼成命令
    NSString *sql=@"";
    sql=[sql stringByAppendingString:tableCommand];
    sql=[sql stringByAppendingString:valueCommand];
    sql=[sql stringByAppendingString:queryCommand];
    
//    NSLog(sql);
    
    __block BOOL result;
    __block NSDictionary *resultDic;
    
    [_dbQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql];
    }];
    
    if (!result) {
        
        
        resultDic=[[NSDictionary alloc]initWithObjectsAndKeys:[NSString stringWithFormat:@"%i",result],@"result",@"err update data",@"msg", nil];
        return resultDic;
    }
    
    resultDic=[[NSDictionary alloc]initWithObjectsAndKeys:[NSString stringWithFormat:@"%i",result],@"result",@"success",@"msg", nil];
    return resultDic;
}


-(NSDictionary *)removeData:(NSString *)json{
    NSDictionary *infoDic=[Transform dictionaryWithJsonString:json];
    NSString *table=[infoDic objectForKey:@"table"];
    
    if ([YTKKeyValueStore checkTableName:table] == NO) {
        NSDictionary * resultDic=[[NSDictionary alloc]initWithObjectsAndKeys:[NSString stringWithFormat:@"%i",NO],@"result",@"table not exists ",@"msg", nil];
        return resultDic;
    }
    
    NSString *tableCommand=[NSString stringWithFormat:@"delete from '%@' ",table];
    
    //位置命令
    NSString *queryCommand=@" where ";
    NSDictionary *queryDic=[infoDic objectForKey:@"query"];
    for (int i=0; i<queryDic.count; i++) {
        NSString *key=[[queryDic allKeys] objectAtIndex:i];
        NSDictionary *valueDic=[queryDic objectForKey:key];
        if (i==0) {
            
            NSString *inKey=[[valueDic allKeys] objectAtIndex:0];
            NSArray *inArr=[valueDic objectForKey:inKey];
            inKey=[inKey substringFromIndex:1];
            
            queryCommand=[queryCommand stringByAppendingString:[NSString stringWithFormat:@" %@ %@ (",key,inKey]];
            
            
            for ( int i=0; i<inArr.count; i++) {
                if (i!=inArr.count-1) {
                    queryCommand=[queryCommand stringByAppendingString:[NSString stringWithFormat:@"\"%@\",",inArr[i]]];
                }else{
                    queryCommand=[queryCommand stringByAppendingString:[NSString stringWithFormat:@"\"%@\")",inArr[i]]];
                }
                
            }
        }else{
            
            NSString *inKey=[[valueDic allKeys]objectAtIndex:0];
            NSArray *inArr=[valueDic objectForKey:inKey];
            inKey=[inKey substringFromIndex:1];
            
            queryCommand=[queryCommand stringByAppendingString:[NSString stringWithFormat:@" and %@ %@ (",key,inKey]];
            
            for ( int i=0; i<inArr.count; i++) {
                if (i!=inArr.count-1) {
                    queryCommand=[queryCommand stringByAppendingString:[NSString stringWithFormat:@"\"%@\",",inArr[i]]];
                }else{
                    queryCommand=[queryCommand stringByAppendingString:[NSString stringWithFormat:@"\"%@\")",inArr[i]]];
                }
                
            }
        }
    }
    //拼成命令
    NSString *sql=@"";
    sql=[sql stringByAppendingString:tableCommand];
    sql=[sql stringByAppendingString:queryCommand];
    
    
    __block BOOL result;
    __block NSDictionary *resultDic;
    
    [_dbQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql];
    }];
    
    if (!result) {
        
        
        resultDic=[[NSDictionary alloc]initWithObjectsAndKeys:[NSString stringWithFormat:@"%i",result],@"result",@"err update data",@"msg", nil];
        return resultDic;
    }
    
    resultDic=[[NSDictionary alloc]initWithObjectsAndKeys:[NSString stringWithFormat:@"%i",result],@"result",@"success",@"msg", nil];
    return resultDic;
    
    
}
@end
