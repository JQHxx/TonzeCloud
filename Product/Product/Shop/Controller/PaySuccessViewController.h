//
//  PaySuccessViewController.h
//  Product
//
//  Created by vision on 17/12/27.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "BaseViewController.h"

@interface PaySuccessViewController : BaseViewController

@property (nonatomic, copy )NSString  *orderSn;
@property (nonatomic, copy )NSString  *payWayStr;
@property (nonatomic,assign)double    totalPrice;

@end
