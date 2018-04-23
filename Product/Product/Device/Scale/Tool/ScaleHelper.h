//
//  ScaleHelper.h
//  Product
//
//  Created by vision on 17/4/20.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TJYUserModel.h"

#define  kScaleBlue       [UIColor colorWithHexString:@"#1fb6f0"]
#define  kScaleGreen      [UIColor colorWithHexString:@"#c0e568"]
#define  kScaleGreenMore  [UIColor colorWithHexString:@"#63d162"]
#define  kScaleOrange     [UIColor colorWithHexString:@"#f39800"]
#define  kScaleRed        [UIColor colorWithHexString:@"#fa5453"]


@interface ScaleHelper : NSObject

singleton_interface(ScaleHelper)

@property (nonatomic,strong)TJYUserModel *scaleUser;


/**
 *  获取体指标结果列表
 *
 *  @param key 体指标键
 *
 *  @return 体指标结果数组
 */
-(NSArray *)getBodyIndexResultArrayWithKey:(NSString *)key;

/**
 *  获取体指标准范围
 *
 *  @param key 体指标键
 *
 *  @return 体指标值数组
 */
-(NSArray *)getBodyIndexArrayWithKey:(NSString *)key;

/**
 *  获取体指标至显示刻度位置
 *
 *  @param valueStr 体指标值
 *  @param key      体指标键
 *
 *  @return 刻度位置
 */
-(CGFloat)getBodyIndexValueXWithValue:(NSString *)valueStr width:(CGFloat)width key:(NSString *)key;

/**
 *  结果说明
 */
-(NSString *)getStandardContentWithResult:(NSString *)resultStr key:(NSString *)key;

/**
 *  判断结果文字颜色
 */
-(UIColor *)getResultColorWithResult:(NSString *)resultStr key:(NSString *)key;

/**
 *  体重
 */
-(NSString *)getWeightStandardWithWeight:(double)weight;

/**
 *  BMI
 */
-(NSString *)getBMIStandardWithBmi:(double)bmi;

/**
 *  体脂肪率
 */
-(NSString *)getBodyFatStandardWithBodyfat:(double)bodyfat;

/**
 *  体水分率
 */
-(NSString *)getWaterStandardWithWater:(double)water;

/**
 *  骨量
 */
-(NSString *)getBoneStandardWithBone:(double)bone;

/**
 *  骨骼肌率
 */
-(NSString *)getMuscleStandardWithMuscle:(double)muscle;

/**
 *  蛋白质
 */
-(NSString *)getProteinStandardWithProtein:(double)protein;

/**
 *  内脏脂肪等级
 */
-(NSString *)getVisfatStandardWithVisfat:(NSInteger)visfat;

/**
 *  基础代谢率
 */
-(NSString *)getBmrStandardWithBmr:(double)bmr;

/**
 *  皮下脂肪率标准
 */
-(NSString *)getSubfatStandardWithSubfat:(double)subfat;

@end
