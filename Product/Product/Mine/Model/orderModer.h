//
//  orderModer.h
//  Product
//
//  Created by zhuqinlu on 2018/1/10.
//  Copyright © 2018年 TianJi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderModer : NSObject

/// 订单号
@property (nonatomic, copy) NSString *order_id;
/// 订单商品数量
@property (nonatomic, copy) NSString *itemnum;
/// 订单总金额
@property (nonatomic, copy) NSString *amount;
/// 订单创建时间
@property (nonatomic, copy) NSString *createtime;
/// 支付状态
@property (nonatomic, copy) NSString *pay_status;
/// 发货状态
@property (nonatomic, copy) NSString *ship_status;
/// 订单状态描述
@property (nonatomic, copy) NSString *status;
/// 订单状态（unpayed：待付款，nodelivery：待发货，noreceived：待收货，finish：已完成，dead：已取消）
@property (nonatomic, copy) NSString *order_status;
/// 订单商品集合
@property (nonatomic, strong) NSArray *item;

@end
