//
//  HeziSDKManager.h
//  FloatIconSDK
//
//  Created by 雷军 on 16/7/2.
//  Copyright © 2016年 ljcoder. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HeziSDKAppLinksModel.h"
#import "HeziShareModel.h"

typedef enum{
    HeziSDK_JPush = 0,
    HeziSDK_GTui = 1,
    HeziSDK_LeanCloud =2
}HzSDKPushTypes;


#define HEZI_PUSH_MSG_ID "hezi_push_msg_id"

@interface HeziSDKManager : NSObject
/**单例*/
+ (instancetype)sharedInstance;

/**
 *  设置key
 *
 *  @param key 必须，由用户在活动盒子后台申请
 */
- (void)configureKey:(NSString *)key;
@property (strong, nonatomic, readonly) NSString *key;

/**
 *
 * 新增渠道 id
 */
- (void)configureChannelId:(NSString *)channelId;
@property (strong, nonatomic, readonly) NSString *channelId;

// 配置服务器地址
- (void)configureServerDomain:(NSString *)serverDomain;
@property (strong, nonatomic, readonly) NSString *serverDomain;

- (void)openDebug:(BOOL)open;
@property (assign, nonatomic, readonly) BOOL isDebug;

//设置导航栏
- (void)setNavigationBarBackgroundImage:(UIImage  *)backgroundImage;
@property (strong, nonatomic, readonly) UIImage *navigationImage;

- (void)setNavigationBarBackgroundColor:(UIColor  *)backgroundColor;
@property (strong, nonatomic, readonly) UIColor *navigationColor;

- (void)setNavigationBarBackgroundColorFromRGB:(NSString  *)backgroundColorRBG;
@property (strong, nonatomic, readonly) NSString *navigationColorRBG;

@property (strong, nonatomic) UIImage *shareImg,*backImg,*reflushImg;
-(void)setNavagitionItemWithBack:(UIImage *)backImg share:(UIImage *)shareImg reflush:(UIImage *)reflushImg;

/**
 设置导航图标和标题颜色

 @param tinterColor 图标和标题颜色值
 */
- (void)setNavigationTinterColor:(UIColor *)tinterColor;
@property (strong, nonatomic, readonly) UIColor *tinterColor;

//程序回到前台
-(void)applicationForeground;

//程序回到
-(void)applicationBackground;

//统计分享成功 并且给分享成功的用户添加抽奖次数
-(void)statisticsShareCallBack:(NSString *)shareCallBack linkUrl:(NSString *)linkUrl;

//设置推送的id 跟平台
-(void)configPushRegisterId:(NSString *)registerId platform:(NSInteger)platform;
@property (assign, nonatomic) NSInteger platform;

//处理推送消息
-(BOOL)dealWithPushMessage:(NSDictionary *)msg properties:(NSDictionary *)properties share:(void(^)(HeziShareModel *shareContent))shareBlock;

//先定义一个有参数,参数类型为NSString * 类型,无返回值的block类型
typedef void(^HeziSDKAppLinksBlock)(HeziSDKAppLinksModel *);

@property(nonatomic,copy) HeziSDKAppLinksBlock linksBlock;

//生成深度链接
-(NSString *)buildDeepLinkWithUrl:(NSString *)urlStr  scheme:(NSString *)scheme customeParams:(NSDictionary *)customeParams;

//处理 url 数据
-(void)dealWithUrl:(NSURL *)url;

-(void)openHeziSDKActivityWithToken:(NSString *)token invivationType:(NSString *)invivation user:(NSDictionary *)userInfo share:(void(^)(HeziShareModel *shareContent))shareBlock;

//初始化
-(void)initializeWithTest:(BOOL)test;

//统计推送消息的接收数
-(void)statisticsPushMsgWithUserInfo:(NSDictionary *)userInfo;

//使用统计功能
-(void)initializeAnalysis;
//使用 deepLinsk 功能
-(void)initializaDeepLinks:(void(^)(HeziSDKAppLinksModel *hzLinksModel))applinksBlock;

@end
