//
//  LogisticsStatusCell.h
//  Product
//
//  Created by zhuqinlu on 2017/12/22.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoodsInfoModel.h"

@interface LogisticsStatusCell : UITableViewCell

/* DeliveryState == 0 未发货   DeliveryState == 1  已发货  state == 3 就是已经收获了

    type 0  待发货  1  运输中 2  已签收
*/
@property (nonatomic, assign) NSInteger type;

- (void)cellWithGoodsInfoModel:(GoodsInfoModel *)model;

@end
