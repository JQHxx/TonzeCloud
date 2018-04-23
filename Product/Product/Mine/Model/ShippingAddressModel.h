//
//  ShippingAddressModel.h
//  Product
//
//  Created by zhuqinlu on 2018/1/9.
//  Copyright © 2018年 TianJi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShippingAddressModel : NSObject

/// 是否为默认
@property (nonatomic, copy) NSString *is_default;
/// 详细地址
@property (nonatomic, copy) NSString *ship_addr;
/// 省市地区
@property (nonatomic, copy) NSString *ship_area;
/// 地址id
@property (nonatomic, copy) NSString *ship_id;
/// 手机
@property (nonatomic, copy) NSString *ship_mobile;
/// 名字
@property (nonatomic, copy) NSString *ship_name;
///
@property (nonatomic, copy) NSString *ship_tel;
/// 邮编
@property (nonatomic, copy) NSString *ship_zip;

@property (nonatomic,assign)BOOL  isSelected;


@end
