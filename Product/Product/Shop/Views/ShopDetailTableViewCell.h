//
//  ShopDetailTableViewCell.h
//  Product
//
//  Created by 肖栋 on 17/12/25.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoodsModel.h"

@interface ShopDetailTableViewCell : UITableViewCell

- (void)cellShopDetailModel:(GoodsModel *)model;

- (void)cellShopParameterModel:(GoodsModel *)model row:(NSInteger)indexPath;

@end
