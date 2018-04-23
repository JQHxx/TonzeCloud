//
//  TJYCookDetailsEquipmentModel.h
//  Product
//
//  Created by zhuqinlu on 2017/5/3.
//  Copyright © 2017年 TianJi. All rights reserved.
//  菜谱详情设备模型

#import <Foundation/Foundation.h>

@interface TJYCookDetailsEquipmentModel : NSObject

/// 设备指令
@property (nonatomic, copy) NSString *code ;
/// 烹饪时间
@property (nonatomic, assign) NSInteger cook_equipment_time ;
/// 设备id
@property (nonatomic, assign) NSInteger  equipment_cat_id ;
/// 设备mac
@property (nonatomic, copy) NSString  *equipment_sn ;
/// 设备名称
@property (nonatomic, copy) NSString *equipment_name ;


@end
