//
//  OrderDetailsViewController.h
//  Product
//
//  Created by zhuqinlu on 2017/12/22.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "BaseViewController.h"

typedef enum : NSUInteger {
    OrderDetaiPayment,    // 待付款
    OrderDetaiShip,       // 待发货
    OrderDetaiReceiving,  // 待收货
    OrderDetaiCarryOut,    // 已完成
    OrderDetaiHasBeenCancelled // 已取消
} OrderDetailType;

@interface OrderDetailsViewController : BaseViewController

/// 订单状态
@property (nonatomic, assign) OrderDetailType  orderDetailType;

///
@property (nonatomic, assign)  NSInteger  orderType;
///  订单号
@property (nonatomic, copy) NSString *orderId ;



@end
