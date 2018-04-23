//
//  RecordDetailModel.h
//  Product
//
//  Created by zhuqinlu on 2017/6/19.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecordDetailDevictTaskModel : NSObject
/// 设备任务记录id
@property (nonatomic ,strong) NSNumber *scene_step_id;
/// 设备任务步骤
@property (nonatomic ,strong) NSNumber *step;
/// 产品id
@property (nonatomic, copy) NSString *product_id;
/// 设备id
@property (nonatomic, copy) NSString *device_id;
/// 设备名
@property (nonatomic, copy) NSString *device_name;
/// 命令类型 1云菜谱
@property (nonatomic ,strong) NSNumber *function_type;
/// 菜谱id
@property (nonatomic ,strong) NSNumber *content_id;
/// 任务间隔时间
@property (nonatomic, strong) NSNumber *time_interval;

@end

/*
 {
 "scene_step_id": 36,
 "step": 1,
 "product_id": "1",
 "device_id": "1",
 "device_name": "水壶",
 "function_type": 1,
 "content_id": 8,
 "time_interval": 0
 },
 */