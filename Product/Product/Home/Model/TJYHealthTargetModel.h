//
//  HealthTargetModel.h
//  Product
//
//  Created by zhuqinlu on 2017/5/2.
//  Copyright © 2017年 TianJi. All rights reserved.
//      健康目标 选项

#import <Foundation/Foundation.h>

@interface TJYHealthTargetModel : NSObject

/// 目标id
@property (nonatomic, assign)  NSInteger target_id;
/// 健康目标
@property (nonatomic, copy) NSString *target_name;


@end
