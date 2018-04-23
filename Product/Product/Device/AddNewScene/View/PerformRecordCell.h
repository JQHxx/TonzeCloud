//
//  PerformRecordCell.h
//  Product
//
//  Created by zhuqinlu on 2017/6/14.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PerformRecordModel.h"

@interface PerformRecordCell : UITableViewCell
/// 场景名称
@property (nonatomic ,strong) UILabel *performNameLab;
/// 执行时间
@property (nonatomic ,strong) UILabel *timeLab;

- (void)setCellWithModel:(PerformRecordModel *)model;

@end
