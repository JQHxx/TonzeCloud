//
//  QLDBController.m
//  YY
//
//  Created by mahailin on 15/9/28.
//  Copyright © 2015年 admin. All rights reserved.
//

#import "QLDBController.h"
#import "QLDBManager.h"

@interface QLDBController ()

/**
 *  数据存储类
 */
@property (nonatomic, strong) ZQBaseKeyValueStore *dataStore;

/**
 *  数据库表名
 */
@property (nonatomic, copy) NSString *tableName;

@end

@implementation QLDBController

#pragma mark -
#pragma mark ==== 系统方法 ====
#pragma mark -

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.dataStore = [QLDBManager sharedDBManager].dataStore;
    }
    
    return self;
}

#pragma mark -
#pragma mark ==== 外部使用方法 ====
#pragma mark -

/**
 *  创建YYDBController实例
 *
 *  @return 返回YYDBController实例
 */
+ (instancetype)dbController
{
    QLDBController *dbController = [[self alloc] init];
    return dbController;
}

#pragma mark -
#pragma mark ==== 数据初始化 ====
#pragma mark -

/**
 *  取出数据库表名
 *
 *  @return 返回数据库表名
 */
- (NSString *)tableName
{
    if (!_tableName)
    {
        _tableName = [NSStringFromClass([self class])stringByReplacingOccurrencesOfString:@"_DBController"
                                                                               withString:@""];
    }
    
    return _tableName;
}

@end
