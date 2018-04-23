//
//  RecordDetailCell.h
//  Product
//
//  Created by zhuqinlu on 2017/6/14.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SceneDetailDeviceTaskModel.h"
#import "RecordStatusModel.h"

@interface RecordDetailCell : UITableViewCell

/// 时间
@property (nonatomic ,strong) UILabel *timeLab;
/// 设备名称
@property (nonatomic ,strong) UILabel *deviceNameLab;
/// 操作名称
@property (nonatomic ,strong) UILabel *operatingNameLab;
/// 执行状态
@property (nonatomic ,strong) UILabel *recordTypeLab;
/// 状态icon
@property (nonatomic ,strong) UIImageView *recordTypeIcon;


- (void)setStatusWithRecordStatusModel:(RecordStatusModel *)statusModel;

@end
