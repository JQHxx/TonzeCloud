//
//  SceneHelper.h
//  Product
//
//  Created by vision on 17/6/29.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SceneHelper : NSObject

singleton_interface(SceneHelper)

@property (nonatomic,assign)BOOL   isRefreshSceneData;  //是否刷新我的场景列表

/**
 *  获取设备标识  （0全部、1云智能健康大厨、2云智能私享壶、3云智能IH电饭煲、4云智能电炖锅、5云智能隔水炖、6云智能隔水炖16A
 *
 *  @param product_id 产品ID
 *
 *  @return 设备标识
 */

-(NSInteger)getEquipmentWithDeviceProductID:(NSString *)product_id;

/**
 *
 *  设备指令处理及偏好处理
 *
 *  @param  code  设备指令加菜谱名称编码
 *  @param  type  设备类型
 *  @param  cookerTag  用于标识16A降压粥 || 降压汤
 *  @param  isPreference  是否是偏好 用于标识16A 获取设置偏好code
 *
 */
+ (NSString *)ql_getDeviceCodeWithCloudMenu:(NSString *)cloudMenu productID:(NSString *)productID cookerTag:(NSInteger )cookerTag isPreference:(BOOL)isPreference;

@end
