//
//  CheckLogisticsViewController.h
//  Product
//
//  Created by zhuqinlu on 2017/12/22.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "BaseViewController.h"

@interface CheckLogisticsViewController : BaseViewController

/// 订单号
@property (nonatomic, copy) NSString *orderId;
/// 订单状态
@property (nonatomic, copy) NSString *orderStatus;

@end
