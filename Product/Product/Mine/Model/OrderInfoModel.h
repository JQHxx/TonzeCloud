//
//  OrderInfoModel.h
//  Product
//
//  Created by zhuqinlu on 2018/1/10.
//  Copyright © 2018年 TianJi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderInfoModel : NSObject

/// 订单状态
@property (nonatomic, copy) NSString *order_status;
/// 订单号
@property (nonatomic, copy) NSString *order_id;
/// 订单创建时间
@property (nonatomic, copy) NSString *created;
/// 订单最后修改时间
@property (nonatomic, copy) NSString *lastmodify;
/// 商品总价
@property (nonatomic, copy) NSString *total_goods_fee;
/// 应支付总计
@property (nonatomic, copy) NSString *total_trade_fee;
/// 快递方式
@property (nonatomic, copy) NSString *shipping_type;
/// 快递费用
@property (nonatomic, copy) NSString *shipping_fee;
/// 支付方式
@property (nonatomic, copy) NSString *payment_type;
/// 买家留言
@property (nonatomic, copy) NSString *buyer_memo;
/// 交易信息
@property (nonatomic, copy) NSString *trade_memo;


@end
