//
//  QLDBManager.h
//  YY
//
//  Created by mahailin on 15/9/28.
//  Copyright © 2015年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZQBaseKeyValueStore.h"

/**
 *  数据库管理类
 */
@interface QLDBManager : NSObject

/**
 *  数据存储类
 */
@property (nonatomic, strong, readonly) ZQBaseKeyValueStore *dataStore;

/**
 *  创建QLDBManager单例
 *
 *  @return 返回QLDBManager实例
 */
+ (instancetype)sharedDBManager;

/**
 *  删除数据库
 */
+ (void)removeDBFile;

@end
