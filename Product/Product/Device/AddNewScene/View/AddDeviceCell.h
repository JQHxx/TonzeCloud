//
//  AddDeviceCell.h
//  Product
//
//  Created by zhuqinlu on 2017/6/15.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceModel.h"

@interface AddDeviceCell : UITableViewCell
/// 设备图标
@property (nonatomic ,strong) UIImageView *deviceIconImg;
/// 设备名称
@property (nonatomic ,strong) UILabel *deviceNameLab;

- (void)setAddDeviceCellWithModel:(DeviceModel *)model;


@end
