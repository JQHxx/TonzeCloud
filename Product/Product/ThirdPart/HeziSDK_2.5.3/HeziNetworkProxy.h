//
//  HeziNetworkProxy.h
//  ActivityBox
//
//  Created by ljcoder on 2017/4/13.
//  Copyright © 2017年 sunnsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^HeziCallBack)(id _Nullable responseObject, NSError * _Nullable error);

@interface HeziNetworkProxy : NSObject
@property (strong,nonatomic)NSString *active;

/**
 单例

 @return 网络请求代理对象
 */
+ (instancetype)sharedInstance;


/**
 加密参数的POST请求方法

 @param path 请求路由
 @param parameters 请求参数
 @param completeHandler 完成回调
 */
- (void)callWithPath:(NSString * _Nonnull)path parameters:(NSDictionary * _Nullable)parameters completeHandler:(HeziCallBack)completeHandler;


/**
 未加密参数的POST请求方法

 @param path 请求路由
 @param parameters 请求参数
 @param completeHandler 完成回调
 */
- (void)callWithPath:(NSString * _Nonnull)path unencryptedParameters:(NSDictionary * _Nullable)parameters completeHandler:(HeziCallBack)completeHandler;


/**
 加密参数的POST请求方法，可自定义服务器地址

 @param serverDomain 服务器地址
 @param path 请求路由
 @param parameters 请求参数
 @param completeHandler 完成回调
 */
- (void)callWithServerDomain:(NSString *)serverDomain path:(NSString * _Nonnull)path parameters:(NSDictionary * _Nullable)parameters completeHandler:(HeziCallBack)completeHandler;

/**
 不加密参数的POST请求方法，可自定义服务器地址
 
 @param serverDomain 服务器地址
 @param path 请求路由
 @param parameters 请求参数
 @param completeHandler 完成回调
 */
- (void)callWithServerDomain:(NSString *)serverDomain path:(NSString *)path parameters:(NSDictionary *)parameters isEncryption:(BOOL)isEncryption completeHandler:(HeziCallBack)completeHandler;

@end

NS_ASSUME_NONNULL_END

