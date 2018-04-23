//
//  SceneDetailsCell.h
//  Product
//
//  Created by zhuqinlu on 2017/6/14.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SceneDetailDeviceTaskModel.h"
#import "RecordStatusModel.h"

@interface SceneDetailsCell : UITableViewCell

/// 设备图标
@property (nonatomic ,strong) UIImageView *deviceIconImg;
/// 设备名称
@property (nonatomic ,strong) UILabel *deviceNameLab;
/// 操作名称
@property (nonatomic ,strong) UILabel *operatingNameLab;
/// 执行状态
@property (nonatomic ,strong) UILabel *recordTypeLab;
/// 状态图标
@property (nonatomic ,strong) UIImageView *typeIcon;

- (void)setSecordDetailCellWithModel:(SceneDetailDeviceTaskModel *)model;

- (void)setStatusWithRecordStatusModel:(RecordStatusModel *)statusModel;

@end
