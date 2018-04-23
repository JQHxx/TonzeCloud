//
//  NetworkTool.h
//  Product
//
//  Created by vision on 17/4/26.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^HttpSuccess)(id json);//请求成功后的回调
typedef void (^HttpFailure)(NSString *errorStr);//请求失败后的回调

@interface NetworkTool : NSObject

singleton_interface(NetworkTool)

-(BOOL)isConnectedToNet;

-(void)getMethodWithURL:(NSString *)urlStr isLoading:(BOOL)isLoading success:(HttpSuccess)success failure:(HttpFailure)failure;

-(void)postMethodWithURL:(NSString *)urlStr body:(NSString *)bodyStr success:(HttpSuccess)success failure:(HttpFailure)failure;

-(void)postMethodWithoutLoadingForURL:(NSString *)urlStr body:(NSString *)bodyStr success:(HttpSuccess)success failure:(HttpFailure)failure;

-(void)postShopMethodWithURL:(NSString *)urlStr body:(NSString *)bodyStr success:(HttpSuccess)success failure:(HttpFailure)failure;

-(void)postShopMethodWithoutLoadingURL:(NSString *)urlStr body:(NSString *)bodyStr success:(HttpSuccess)success failure:(HttpFailure)failure;

- (void)getShopMethodWithURL:(NSString *)urlStr body:(NSString *)body isLoading:(BOOL)isLoading success:(HttpSuccess)success failure:(HttpFailure)failure;

/*
 *数据转json
 */
-(NSString *)getValueWithParams:(id)params;

/*
 *刷新用户凭证
 */
-(void)refreshUserTokenSuccess:(HttpSuccess)success;

/*
 *获取用户信息
 */
-(void)requestUserInfo;

/*
 *用户点击事件
 */
-(void)clickOnEventWithTargetId:(NSString *)target_id;

/*
 *用户分享事件
 */
-(void)shareEventWithTargetID:(NSInteger)target_id way:(NSInteger)share_way type:(NSInteger)target_type name:(NSString *)target_name;

/*
 *页面统计事件
 */
-(void)pageCountEventWithTargetID:(NSString *)target_id type:(NSInteger)type;


@end
