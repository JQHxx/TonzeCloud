//
//  PerformRecordModel.h
//  Product
//
//  Created by zhuqinlu on 2017/6/14.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PerformRecordModel : NSObject

/// 场景id
@property (nonatomic ,strong) NSNumber *scene_id;
/// 场景名称
@property (nonatomic, copy) NSString *scene_name;
/// 场景时间
@property (nonatomic, copy) NSString *start_time;
/// 执行记录标识(用于标识该条执行记录)
@property (nonatomic, copy) NSString *record_flag;

@end
