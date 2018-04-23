//
//  AddtimeIntervalViewController.h
//  Product
//
//  Created by zhuqinlu on 2017/6/15.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "BaseViewController.h"

typedef void(^TimeIntervalBlock)(NSInteger time);

@interface AddTimeIntervalViewController : BaseViewController

/// 时间间隔回调
@property (nonatomic, copy) TimeIntervalBlock timeIntervalBlock;

@end
