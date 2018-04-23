//
//  SelectAdressViewController.h
//  Product
//
//  Created by vision on 17/12/26.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "BaseViewController.h"
#import "ShippingAddressModel.h"

typedef void(^DidSelectAddressBlock)(ShippingAddressModel *selConsignee);

@interface SelectAdressViewController : BaseViewController

@property (nonatomic, copy )NSString *selectedConsigneeId; //已选收货地址ID
@property (nonatomic, copy )DidSelectAddressBlock selectAddressBlock;

@end
