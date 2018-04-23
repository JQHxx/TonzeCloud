//
//  MineSceneModel.h
//  Product
//
//  Created by 肖栋 on 17/5/31.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MineSceneModel : NSObject

// 场景Id
@property (nonatomic,strong) NSNumber *scene_id;
// 场景名称
@property (nonatomic,strong) NSString *scene_name;
// 设备数据
@property (nonatomic,strong) NSArray *device;
/// 设备数量
@property (nonatomic ,strong) NSNumber *device_num;

@end
