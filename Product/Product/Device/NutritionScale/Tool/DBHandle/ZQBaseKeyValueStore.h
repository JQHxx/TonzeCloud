//
//  ZQBaseKeyValueStore.h
//  ZQFramework
//
//  Created by mahailin on 15/8/13.
//  Copyright (c) 2015年 admin. All rights reserved.
//

#import "YTKKeyValueStore.h"


/**
 *  YTKKeyValueStore子类
 */
@interface ZQBaseKeyValueStore : YTKKeyValueStore

/**
 *  删除数据库表
 *
 *  @param tableName 表名称
 */
- (void)dropTableWithName:(NSString *)tableName;

@end
