//
//  AddDceneModel.h
//  Product
//
//  Created by zhuqinlu on 2017/6/15.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AddSceneModel : NSObject

/// 设备名称
@property (nonatomic, copy) NSString *device_name;
/// 设备id
@property (nonatomic ,assign) NSInteger device_id;
/// 1 云菜谱 2,3 以后扩充
@property (nonatomic ,assign) NSInteger function_type;
/// 产品id
@property (nonatomic ,assign) NSString  *product_id;
/// 时间间隔
@property (nonatomic, assign) NSInteger  time_interval;
/// 菜谱类型id
@property (nonatomic, assign) NSInteger  content_id;
/// 步骤id （场景步骤）
@property (nonatomic, assign) NSInteger  step;
/// 操作名称
@property (nonatomic, copy) NSString *operationName;

@end
