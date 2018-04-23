//
//  DeliveryModel.h
//  Product
//
//  Created by zhuqinlu on 2018/1/16.
//  Copyright © 2018年 TianJi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeliveryModel : NSObject

/// 物流单号
@property (nonatomic, copy) NSString *LogisticCode;
/// 物流简称
@property (nonatomic, copy) NSString *ShipperCode;
/// 轨迹
@property (nonatomic ,strong) NSArray *Traces;
/// 物流状态  state == 3 就是已经收货
@property (nonatomic, copy) NSString *State;
/// 订单ID
@property (nonatomic, copy) NSString *OrderCode;
/// 物流商家id
@property (nonatomic, copy) NSString *EBusinessID;
/// 物流请求状态
@property (nonatomic, copy) NSString *Success;
/// 地址
@property (nonatomic, copy) NSString *ConsigneeAddr;
/// 物流名称
@property (nonatomic, copy) NSString *logi_name;
/// 物流电话
@property (nonatomic, copy) NSString *logi_tel;
/// DeliveryState == 0 未发货   DeliveryState == 1  已发货
@property (nonatomic, assign) NSInteger  DeliveryState;

@end
