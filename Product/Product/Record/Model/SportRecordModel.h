//
//  SportRecordModel.h
//  Product
//
//  Created by 肖栋 on 17/4/25.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SportRecordModel : NSObject

@property (nonatomic, assign) NSInteger motion_record_id;

@property (nonatomic, assign) NSInteger motion_type;   //运动类型

@property (nonatomic, assign)BOOL  isManual;   //是否手动添加

@property (nonatomic, copy) NSString *image_url; 

@property (nonatomic, copy) NSString *motion_bigin_time;   //运动开始时间

@property (nonatomic, copy) NSString *edit_time;

@property (nonatomic, copy) NSString *user_id;

@property (nonatomic, copy) NSString *motion_bigin_data;

@property (nonatomic, copy) NSString *calorie;          //运动消耗热量

@property (nonatomic, copy) NSString *calorie_type;          //30分钟热量

@property (nonatomic, copy) NSString *remark;           //备注

@property (nonatomic, copy) NSString *image_id;

@property (nonatomic, copy) NSString *motion_time;      //运动时长

@property (nonatomic, copy) NSString *add_time;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *motion_type_name;

@property (nonatomic, copy) NSString *motion_type_image_url;

@end
