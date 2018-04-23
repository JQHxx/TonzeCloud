//
//  FoodAddModel.h
//  Product
//
//  Created by 肖栋 on 17/4/15.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FoodAddModel : NSObject
@property (nonatomic, assign) NSInteger id;
@property (nonatomic, assign)NSInteger  type;

@property (nonatomic, copy )NSString *image_url;
@property (nonatomic, copy )NSString *name;
@property (nonatomic, assign) NSInteger energykcal;      ///食物能量

@property (nonatomic, assign) NSInteger cook_id;           ///菜谱id
@property (nonatomic, assign) NSInteger calories_pre100;   ///菜谱能量
@property (nonatomic, strong) NSString *image_id_cover;    ///菜谱地址

@property (nonatomic,strong)NSNumber *weight;
@property (nonatomic,strong)NSNumber *calory;
@property (nonatomic,strong)NSNumber *isSelected;
@end
