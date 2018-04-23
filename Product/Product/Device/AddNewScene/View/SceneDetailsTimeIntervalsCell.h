//
//  SceneDetailsTimeIntervalsCell.h
//  Product
//
//  Created by zhuqinlu on 2017/6/28.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SceneDetailDeviceTaskModel.h"

@interface SceneDetailsTimeIntervalsCell : UITableViewCell

/// 时间间隔
@property (nonatomic ,strong) UILabel *timeIntervalsLab;

- (void)setSecordTimeIntervalsCellWithModel:(SceneDetailDeviceTaskModel *)model;

@end
