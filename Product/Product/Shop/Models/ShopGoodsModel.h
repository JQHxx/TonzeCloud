//
//  ShopGoodsModel.h
//  Product
//
//  Created by 肖栋 on 18/1/5.
//  Copyright © 2018年 TianJi. All rights reserved.
//
/**
 *
 "parent_id": "0",
 "cat_id": "1",
 "cat_name": "健康畅饮",
 "is_leaf": "false",
 "type_id": "1",
 "last_modify": "1515055776"
 */
#import <Foundation/Foundation.h>

@interface ShopGoodsModel : NSObject

@property (nonatomic ,assign)NSInteger parent_id;    

@property (nonatomic ,assign)NSInteger cat_id;

@property (nonatomic ,strong)NSString *cat_name;

@property (nonatomic ,assign)NSInteger is_leaf;

@property (nonatomic ,assign)NSInteger type_id;

@property (nonatomic ,strong)NSString *last_modify;

@end
