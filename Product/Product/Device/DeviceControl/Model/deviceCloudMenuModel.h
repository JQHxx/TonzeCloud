//
//  deviceCloudMenuModel.h
//  Product
//
//  Created by 肖栋 on 17/5/10.
//  Copyright © 2017年 TianJi. All rights reserved.
//
/*
 "cook_id": 86,
 "name": "一碗香",
 "abstract": "测试菜谱摘要",
 "image_id_cover": "http://360tjy-health.oss-cn-shanghai.aliyuncs.com/image/201705/cd9f9968e2e2c6f75b5855529e388e78.jpg",
 "reading_number": 75,
 "like_number": 0,
 "is_yun": 1
 */
#import <Foundation/Foundation.h>

@interface deviceCloudMenuModel : NSObject

@property(nonatomic ,assign)NSInteger cook_id;
@property(nonatomic ,copy)NSString *name;
@property(nonatomic ,copy)NSString *abstract;
@property(nonatomic ,copy)NSString *image_id_cover;
@property(nonatomic ,assign)NSInteger reading_number;
@property(nonatomic ,assign)NSInteger like_number;
@property(nonatomic ,assign)NSInteger is_yun;

@end
