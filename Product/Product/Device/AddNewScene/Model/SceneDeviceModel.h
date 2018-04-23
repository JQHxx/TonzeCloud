//
//  SceneDeviceModel.h
//  Product
//
//  Created by zhuqinlu on 2017/6/16.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SceneDeviceModel : NSObject

/// 设备名称
@property (nonatomic ,copy) NSString *device_name;
/// 产品id
@property (nonatomic ,copy) NSString *product_id;
/// 设备id
@property (nonatomic ,copy) NSString *device_id;

@end

