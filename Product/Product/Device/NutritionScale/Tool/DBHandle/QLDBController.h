//
//  QLDBController.h
//  YY
//
//  Created by mahailin on 15/9/28.
//  Copyright © 2015年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZQBaseKeyValueStore.h"

/**
 *  数据库表控制器
 */
@interface QLDBController : NSObject

/**
 *  数据库表名
 */
@property (nonatomic, copy, readonly) NSString *tableName;

/**
 *  数据存储类
 */
@property (nonatomic, strong, readonly) ZQBaseKeyValueStore *dataStore;

/**
 *  创建YYDBController实例
 *
 *  @return 返回YYDBController实例
 */
+ (instancetype)dbController;

@end
