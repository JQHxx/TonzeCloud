//
//  ZQBaseKeyValueStore.m
//  ZQFramework
//
//  Created by mahailin on 15/8/13.
//  Copyright (c) 2015年 admin. All rights reserved.
//

#import "ZQBaseKeyValueStore.h"
#import "FMDB.h"

static NSString * const DROP_TABLE_SQL = @"DROP TABLE %@";

@interface ZQBaseKeyValueStore ()

@end

@implementation ZQBaseKeyValueStore

/**
 *  创建数据库表
 *
 *  @param tableName 表名称
 */
- (void)createTableWithName:(NSString *)tableName
{
    if (![self isTableExists:tableName])
    {
        [super createTableWithName:tableName];
    }
}

/**
 *  删除数据库表
 *
 *  @param tableName 表名称
 */
- (void)dropTableWithName:(NSString *)tableName
{
    if ([self isTableExists:tableName])
    {
        NSString * sql = [NSString stringWithFormat:DROP_TABLE_SQL, tableName];
        __block BOOL result;
        
        [self.dbQueue inDatabase:^(FMDatabase *db) {
            result = [db executeUpdate:sql, tableName];
        }];
        
        if (!result)
        {
            NSLog(@"ERROR, failed to drop table: %@", tableName);
        }
    }
}

@end
