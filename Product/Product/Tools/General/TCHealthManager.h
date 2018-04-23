//
//  TCHealthManager.h
//  TonzeCloud
//
//  Created by vision on 17/2/16.
//  Copyright © 2017年 tonze. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HealthKit/HealthKit.h>

@interface TCHealthManager : NSObject

singleton_interface(TCHealthManager);

/*
 *  @brief  检查是否支持获取健康数据
 */
-(void)authorizeHealthKit:(void(^)(BOOL success,NSError *error))completion;

/*
 * @brief  获取步数
 */
- (void)getStepCountWithDays:(NSInteger)days complete:(void(^)(NSMutableArray *valuesArray, NSError *error))completion;

/*
 * @brief 获取公里数
 */
- (void)getDistance:(void(^)(double value, NSError *error))completion;

@end
