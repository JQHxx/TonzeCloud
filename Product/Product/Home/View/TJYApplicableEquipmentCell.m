
//
//  TJYApplicableEquipmentCell.m
//  Product
//
//  Created by zhuqinlu on 2017/4/21.
//  Copyright © 2017年 TianJi. All rights reserved.
//   菜谱详情 -- 适配设备

#import "TJYApplicableEquipmentCell.h"
#import "DeviceHelper.h"

@implementation TJYApplicableEquipmentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _equipmentImg = InsertImageView(self.contentView, CGRectMake(15, 15, 50, 50), [UIImage imageNamed:@""]);
        _equipmentNameLab = InsertLabel(self.contentView, CGRectMake(_equipmentImg.right + 10, _equipmentImg.top, kScreenWidth-_equipmentImg.right, 20), NSTextAlignmentLeft, @"", kFontSize(18), UIColorHex(0x333333), NO);
        _cookingTimeLab=  InsertLabel(self.contentView, CGRectMake(_equipmentNameLab.left,_equipmentNameLab.bottom + 12 , 200, 15), NSTextAlignmentLeft, @"", kFontSize(13), UIColorHex(0x999999), NO);
        
        InsertView(self.contentView, CGRectMake(15,80 - 0.5, kScreenWidth - 15, 0.5), kLineColor);
    }
    return self;
}

- (void)cellWithData:(TJYCookDetailsEquipmentModel *)model{

    _equipmentImg.image =[UIImage imageNamed:[DeviceHelper productHelpDefaultName:model.equipment_sn]];
    _equipmentNameLab.text = model.equipment_name;
    _cookingTimeLab.text = [NSString stringWithFormat:@"烹饪时长：%ld分钟",model.cook_equipment_time];
    
}

@end
