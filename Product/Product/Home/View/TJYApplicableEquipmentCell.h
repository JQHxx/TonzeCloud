//
//  TJYApplicableEquipmentCell.h
//  Product
//
//  Created by zhuqinlu on 2017/4/21.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TJYCookDetailsEquipmentModel.h"

@interface TJYApplicableEquipmentCell : UITableViewCell
/// 设备图标
@property (nonatomic ,strong) UIImageView *equipmentImg;
/// 设备名称
@property (nonatomic ,strong) UILabel *equipmentNameLab;
/// 烹饪时长
@property (nonatomic ,strong) UILabel *cookingTimeLab;
/// 设备状态
@property (nonatomic ,strong) UILabel *equipmentTypeLab;

- (void)cellWithData:(TJYCookDetailsEquipmentModel *)model;

@end
