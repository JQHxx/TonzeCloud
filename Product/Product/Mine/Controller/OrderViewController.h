//
//  OrderViewController.h
//  Product
//
//  Created by vision on 17/12/20.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "BaseViewController.h"

typedef enum : NSUInteger {
    AllOrder,
    Payment,    // 待付款
    Ship,       // 待发货
    Receiving,  // 待收货
    CarryOut    // 已完成
} OrderType;


@interface OrderViewController : BaseViewController

/// 商品状态
@property (nonatomic, assign) OrderType  orderType;
///
@property (nonatomic, assign) NSInteger  orderStatus;

@property(nonatomic,assign)NSInteger   indexStatu;;

@end
