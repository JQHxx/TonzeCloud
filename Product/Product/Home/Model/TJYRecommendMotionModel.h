//
//  TJYRecommendMotionModel.h
//  Product
//
//  Created by zhuqinlu on 2017/5/9.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TJYRecommendMotionModel : NSObject

/// 运动id
@property (nonatomic, assign) NSInteger  motion_id;

/// 运动能量
@property (nonatomic, assign) NSInteger  motion_calorie ;

/// 运动名称
@property (nonatomic, copy) NSString *name ;

/// 热量消耗系数
@property (nonatomic, assign) NSInteger  coefficient ;

/// 运动时间
@property (nonatomic, assign) NSInteger time ;

/// 图片地址
@property (nonatomic, copy) NSString *image_url ;

/// 运动强度
@property (nonatomic, copy) NSString *motion_intensity ;

@end
