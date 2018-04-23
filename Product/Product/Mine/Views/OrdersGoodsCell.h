//
//  OrdersGoodsCell.h
//  Product
//
//  Created by zhuqinlu on 2017/12/22.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoodsFavoriteModel.h"
#import "OrderItemsModel.h"

@interface OrdersGoodsCell : UITableViewCell

// 用于订单列表
- (void)cellWithModel:(OrderItemsModel *)model;
// 用于收藏列表
- (void)initWithShopFavoriteModel:(GoodsFavoriteModel *)model;

@end
