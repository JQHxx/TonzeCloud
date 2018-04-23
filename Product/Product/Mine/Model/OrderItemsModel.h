//
//  OrderItemsModel.h
//  Product
//
//  Created by zhuqinlu on 2018/1/10.
//  Copyright © 2018年 TianJi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderItemsModel : NSObject

/// 商品id
@property (nonatomic, copy) NSString *goods_id;
/// 货品id
@property (nonatomic, copy) NSString *product_id;
/// 商品名
@property (nonatomic, copy) NSString *goods_name;
/// 规格
@property (nonatomic, copy) NSString *spec_info;
/// 价格
@property (nonatomic, copy) NSString *price;
/// 数量
@property (nonatomic, copy) NSString *quantity;
/// 商品类型
@property (nonatomic, copy) NSString *item_type;
/// 商品图片集合
@property (nonatomic ,strong) NSDictionary *goods_pic;

@end
