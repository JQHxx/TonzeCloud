//
//  QLDBManager.m
//  YY
//
//  Created by mahailin on 15/9/28.
//  Copyright © 2015年 admin. All rights reserved.
//

#import "QLDBManager.h"

static NSString *const kDBName = @"DeviceData.sqlite";
static NSString *const kDBVersionKey = @"DBVersionKey";

/**
 *  处理arc环境下调用performSelector:的警告
 *
 */
#define SUPPRESS_PERFORM_SELECTOR_LEAK_WARNING(code)                        \
_Pragma("clang diagnostic push")                                            \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"")         \
code;                                                                       \
_Pragma("clang diagnostic pop")                                             \
((void)0)

#define DOCUMENT    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]

/**
 *  版本升级号，必须为整形，用于程序升级时，每次版本变化有缓存什么的需要更新时该值就+1，初始值为1
 *
 */
static const NSUInteger kDBVersion = 1;

@interface QLDBManager ()

/**
 *  数据库的存放路径
 */
@property (strong, nonatomic, readonly) NSString *dbPath;

/**
 *  数据存储类
 */
@property (nonatomic, strong) ZQBaseKeyValueStore *dataStore;

@end

@implementation QLDBManager

#pragma mark -
#pragma mark ==== 系统方法 ====
#pragma mark -

- (id)init
{
    self = [super init];
    
    if (self)
    {
        if (![self isDBExists])
        {
            [self createDataBase];
        }
        else
        {
            if (![self isSameDBVersion])
            {
                [self updateDataBase];
            }
        }
    }
    
    return self;
}

#pragma mark -
#pragma mark ==== 外部使用方法 ====
#pragma mark -

/**
 *  创建QLDBManager单例
 *
 *  @return 返回QLDBManager实例
 */
+ (instancetype)sharedDBManager
{
    static QLDBManager *manager;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    
    return manager;
}

/**
 *  删除数据库
 */
+ (void)removeDBFile
{
    [[NSFileManager defaultManager] removeItemAtPath:
    [DOCUMENT stringByAppendingPathComponent:kDBName] error:nil];
}

#pragma mark -
#pragma mark ==== 内部使用方法 ====
#pragma mark -

/**
 *  判断是否数据库存在
 *
 *  @return 是-yes，否-no
 */
- (BOOL)isDBExists
{
    return [[NSFileManager defaultManager] fileExistsAtPath:self.dbPath];
}

/**
 *  判断是否相同版本
 *
 *  @return 是-yes，否-no
 */
- (BOOL)isSameDBVersion
{
    NSInteger dbVersion = [[NSUserDefaults standardUserDefaults] integerForKey:kDBVersionKey];
    return dbVersion == kDBVersion;
}

/**
 *  保存版本号
 */
- (void)saveDBVersion
{
    [[NSUserDefaults standardUserDefaults] setInteger:kDBVersion forKey:kDBVersionKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/**
 *  更新数据库
 */
- (void)updateDataBase
{
    NSInteger dbVersion = [[NSUserDefaults standardUserDefaults] integerForKey:kDBVersionKey];
    
    if (dbVersion >= kDBVersion)
    {
        return;
    }
    
    [self updateDBFrom:dbVersion To:kDBVersion];
    [self saveDBVersion];
}

/**
 *  更新数据库
 *
 *  @param oldDBVersion    老版本号
 *  @param latestDBVersion 新版本号
 */
- (void)updateDBFrom:(NSInteger)oldDBVersion To:(NSInteger)latestDBVersion
{
    if (oldDBVersion >= latestDBVersion)
    {
        return;
    }
    
    SEL updateSel;
    NSInteger old = oldDBVersion;
    NSString *selectorString = @"updateFrom%ldTo%ld";
    
    while (old < latestDBVersion)
    {
        updateSel = NSSelectorFromString([NSString stringWithFormat:selectorString,
                                          (long)old, (long)(old + 1)]);
        
        if (updateSel != NULL && [self respondsToSelector:updateSel])
        {
            SUPPRESS_PERFORM_SELECTOR_LEAK_WARNING([self performSelector:updateSel]);
        }
        
        old++;
    }
}

/**
 *  首次创建数据库顺道创建需要的数据表并保存数据库版本号
 */
- (void)createDataBase
{
    //保存数据库版本号
    [self saveDBVersion];
}

/**
 *  版本号由1升级为2时的相关处理
 */
- (void)updateFrom1To2
{
    //(@"升级为版本2时要做的处理");
}

/**
 *  版本号由2升级为3时的相关处理
 */
- (void)updateFrom2To3
{
    //(@"升级为版本3时要做的处理");
}

/**
 *  版本号由3升级为4时的相关处理
 */
- (void)updateFrom3To4
{
    //(@"升级为版本4时要做的处理");
}

#pragma mark -
#pragma mark ==== 数据初始化 ====
#pragma mark -

/**
 *  设置数据库存储类
 *
 *  @return 返回YTKKeyValueStore实例
 */
- (ZQBaseKeyValueStore *)dataStore
{
    if (!_dataStore)
    {
        _dataStore = [[ZQBaseKeyValueStore alloc] initWithDBWithPath:self.dbPath];
    }
    
    return _dataStore;
}

/**
 *  数据库的存放路径
 *
 *  @return 返回NSString实例
 */
- (NSString *)dbPath
{
    return [DOCUMENT stringByAppendingPathComponent:kDBName];
}

@end
