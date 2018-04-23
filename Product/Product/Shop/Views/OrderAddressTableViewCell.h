//
//  OrderAddressTableViewCell.h
//  Product
//
//  Created by vision on 18/1/19.
//  Copyright © 2018年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShippingAddressModel.h"

@interface OrderAddressTableViewCell : UITableViewCell

-(void)orderAddressTableViewCellDisplayWithAddress:(ShippingAddressModel *)model;

@end
