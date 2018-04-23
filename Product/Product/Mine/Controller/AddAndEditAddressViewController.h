//
//  AddAndEditAddressViewController.h
//  Product
//
//  Created by zhuqinlu on 2017/12/26.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "BaseViewController.h"
#import "ShippingAddressModel.h"

typedef enum: NSInteger{
    AddAddress,  // 添加地址
    EditAddress  // 编辑地址
}AddressType;

@interface AddAndEditAddressViewController : BaseViewController

///
@property (nonatomic, assign) AddressType  addressType;
/// 地址模型
@property (nonatomic ,strong) ShippingAddressModel *addressModel;
/// 判断是否为默认地址
@property (nonatomic, assign) BOOL  isDefaultAdd;

@end
