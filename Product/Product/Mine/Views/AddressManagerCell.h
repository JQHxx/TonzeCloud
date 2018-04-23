//
//  AddressManagerCell.h
//  Product
//
//  Created by zhuqinlu on 2017/12/26.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShippingAddressModel.h"

@protocol AddressManagerCellDelegate <NSObject>
// 设为默认
- (void)didSelectDefaultAddressInCell:(UITableViewCell *)cell;
// 编辑
- (void)didSelectEditAddressInCell:(UITableViewCell *)cell;
// 删除
- (void)didSelectDeleteAddressInCell:(UITableViewCell *)cell;

@end

@interface AddressManagerCell : UITableViewCell

/// 
@property (nonatomic, weak) id <AddressManagerCellDelegate>  addressDelegate ;

- (void)cellWithModel:(ShippingAddressModel *)addressModel;

@end
