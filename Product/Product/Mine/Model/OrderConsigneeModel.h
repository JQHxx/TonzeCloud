//
//  OrderConsigneeModel.h
//  Product
//
//  Created by zhuqinlu on 2018/1/10.
//  Copyright © 2018年 TianJi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderConsigneeModel : NSObject

/// 收货人
@property (nonatomic, copy) NSString *receiver_name;
/// 收货人地址的国家
@property (nonatomic, copy) NSString *receiver_state;
/// 收货人地址的城市
@property (nonatomic, copy) NSString *receiver_city;
/// 收货人地址的区
@property (nonatomic, copy) NSString *receiver_district;
/// 收货人地址的地址
@property (nonatomic, copy) NSString *receiver_address;
/// 收货人地址的邮件编码
@property (nonatomic, copy) NSString *receiver_zip;
/// 收货人地址的手机号
@property (nonatomic, copy) NSString *receiver_phone;


@end
