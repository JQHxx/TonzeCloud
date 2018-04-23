//
//  ScaleModel.h
//  Product
//
//  Created by vision on 17/4/20.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScaleModel : NSObject


@property (nonatomic, assign) NSInteger visceral_fat_level;

@property (nonatomic, copy) NSString *image_id;

@property (nonatomic, copy) NSString *image_url;

@property (nonatomic, assign) double subcutaneous_fat_rate;

@property (nonatomic, assign) NSInteger constitution_analyzer_id;

@property (nonatomic, assign) double bmi;

@property (nonatomic, assign) double weight;

@property (nonatomic, assign) double bone_mass;

@property (nonatomic, assign) double basal_metabolic_rate;

@property (nonatomic, copy) NSString *edit_time;

@property (nonatomic, assign) double body_water_rate;

@property (nonatomic, assign) NSInteger user_id;

@property (nonatomic, assign) double body_fat_percentage;

@property (nonatomic, copy) NSString *measure_date;

@property (nonatomic, copy) NSString *measure_time;

@property (nonatomic, copy) NSString *way;

@property (nonatomic, assign) double skeletal_muscle_rate;

@property (nonatomic, assign) double score;

@property (nonatomic, copy) NSString *add_time;

@property (nonatomic, copy) NSString *name;

@property (nonatomic,assign)double protein;

@property (nonatomic,assign)NSInteger age;

@property (nonatomic,copy )NSString *height;

@property (nonatomic,assign)NSInteger sex;

@property (nonatomic,copy)NSString *birthday;

@end
