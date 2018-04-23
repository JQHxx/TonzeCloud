//
//  RecordStatusModel.h
//  Product
//
//  Created by zhuqinlu on 2017/6/21.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecordStatusModel : NSObject

/// 产品id
@property (nonatomic , copy ) NSString *product_id;
/// 设备id
@property (nonatomic , copy ) NSString *device_id;
/// 步骤
@property (nonatomic ,assign) NSInteger step;
/// 时间
@property (nonatomic , copy ) NSString *start_time;
/// 执行状态
@property (nonatomic ,assign) NSInteger status;
//场景ID
@property (nonatomic,assign) NSInteger scene_id;
//设备名称
@property (nonatomic, copy ) NSString  *device_name;
//设备执行（云菜谱）
@property (nonatomic, copy ) NSString  *cook_name;

@end
