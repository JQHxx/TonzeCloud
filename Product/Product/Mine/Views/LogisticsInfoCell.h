//
//  LogisticsInfoCell.h
//  Product
//
//  Created by zhuqinlu on 2017/12/22.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoodsInfoModel.h"
#import "DeliveryModel.h"

@interface LogisticsInfoCell : UITableViewCell

- (void)cellWithGoodsInfoModel:(GoodsInfoModel *)model  deliveryModel:(DeliveryModel *)deliveryModel;

@end
