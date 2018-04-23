//
//  AutoLoginManager.h
//  Product
//
//  Created by 梁家誌 on 16/9/2.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import <Foundation/Foundation.h>


///设备状态改变，包括离线、在线、炖煮等
#define kOnManagerDeviceStateChange @"kOnDeviceStateChange"

@class DeviceModel;

@interface AutoLoginManager : NSObject

@property (nonatomic,strong) NSMutableArray *deviceModelArr;//设备模型数组


+(instancetype)shareManager;

///自动登录，完成XLinkSDK登录-拉取订阅列表-拉取设备扩展属性=拉取用户信息=拉取用户扩展属性
- (void)startAutoLogin;

///退出登录，停止监听SDK的通知，清空列表数据
- (void)loginOut;

///从云端获取设备列表
-(void)getDeviceList;

///添加设备时使用
- (void)addNoti;

///添加设备完成使用
-(void)removeNoti;

-(DeviceModel *)getModelWithMac:(NSString *)mac;

///更新accessToken
-(void)updateAccessToken;

///用户手动删除设备后删除manager的缓存设备数据
-(void)updateUIAfterDeleteDevice:(DeviceModel *)device;

///列表显示的模型
- (NSMutableArray *)getDeviceModelArr;

///水壶先判断本地再添加默认饮水计划
- (void)checkAndAddReminds:(NSString *)mac;

///水壶直接添加默认饮水计划
- (void)andAddRemindsWithOutCheck:(NSString *)mac;

///初始化三个提醒
-(void)initRemindWithMac:(NSString *)mac;

///返回app使用已经登录过了
-(BOOL)hasLogin;

///清除数据
-(void)clearAllUserData;



@end
