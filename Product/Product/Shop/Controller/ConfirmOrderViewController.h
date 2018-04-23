//
//  ConfirmOrderViewController.h
//  Product
//
//  Created by vision on 17/12/25.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "BaseViewController.h"

@interface ConfirmOrderViewController : BaseViewController

@property (nonatomic,assign)BOOL   isFastBuy;
@property (nonatomic,assign)double totalPrice;
@property (nonatomic,strong)NSMutableArray  *goodsArray;


@end
