//
//  PayOrderViewController.h
//  Product
//
//  Created by vision on 17/12/26.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "BaseViewController.h"

@interface PayOrderViewController : BaseViewController

@property (nonatomic,assign) BOOL       isOrderIn;
@property (nonatomic,assign) BOOL       isFastBuy;
@property (nonatomic, copy ) NSString   *order_id;
@property (nonatomic,assign) double     payAmount; //支付金额
@property (nonatomic, copy ) NSString   *createTimeStr;

@end
