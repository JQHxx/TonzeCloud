//
//  AddressTableViewCell.h
//  Product
//
//  Created by vision on 17/12/26.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShippingAddressModel.h"

@class AddressTableViewCell;
@protocol AddressTableViewCellDelegate <NSObject>

@optional
-(void)addressTableViewCell:(AddressTableViewCell *)cell didEditAddress:(ShippingAddressModel *)model;

@end

@interface AddressTableViewCell : UITableViewCell

@property (nonatomic,strong)UIButton  *editAddressBtn;

@property (nonatomic,weak)id<AddressTableViewCellDelegate>delegate;

-(void)addressTableViewCellDisplayWithAddress:(ShippingAddressModel *)model;

+(CGFloat)getCellHeightWithAddress:(ShippingAddressModel *)model;

@end
