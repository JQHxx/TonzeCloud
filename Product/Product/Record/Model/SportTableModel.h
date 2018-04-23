//
//  SportTableModel.h
//  Product
//
//  Created by 肖栋 on 17/5/11.
//  Copyright © 2017年 TianJi. All rights reserved.
//
/*
 "motion_id": 3,
 "name": "秘书长要装逼",
 "calorie": 4199400
 motion_intensity
 */
#import <Foundation/Foundation.h>

@interface SportTableModel : NSObject

@property(nonatomic ,assign)NSInteger motion_id;
@property(nonatomic ,strong)NSString *name;
@property(nonatomic ,strong)NSString *image_url;
@property(nonatomic ,strong)NSString *motion_intensity;
@property(nonatomic ,assign)NSInteger calorie;

@end
