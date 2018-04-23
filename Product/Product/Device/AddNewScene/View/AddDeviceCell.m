

//
//  AddDeviceCell.m
//  Product
//
//  Created by zhuqinlu on 2017/6/15.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "AddDeviceCell.h"

@implementation AddDeviceCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setAddDeviceCell];
    }
    return self;
}
#pragma mark ====== Set UI =======
- (void)setAddDeviceCell{
    _deviceIconImg = [[UIImageView alloc]initWithFrame:CGRectMake(20,  (75 - 60)/2, 60, 60)];
    _deviceIconImg.image = [UIImage imageNamed:@""];
    
    [self.contentView addSubview:_deviceIconImg];
    
    _deviceNameLab = InsertLabel(self.contentView, CGRectMake(_deviceIconImg.right + 15,(75 - 20)/2 , kScreenWidth - 80 , 20), NSTextAlignmentLeft, @"", kFontSize(15), UIColorHex(0x313131), NO);
    
    InsertImageView(self.contentView, CGRectMake(kScreenWidth - 30, (75 - 15)/2 , 15, 15), [UIImage imageNamed:@"ic_pub_arrow_nor"]);
}
#pragma mark ====== Set Data  =======

- (void)setAddDeviceCellWithModel:(DeviceModel *)model{
    
    _deviceIconImg.image = [self setIconImageWithDeviceType:model.deviceType];
    
    _deviceNameLab.text = model.deviceName;
}
// 根据设备的产品ID设置图片
- (UIImage *)setIconImageWithDeviceType:(NSInteger )deviceType{
    switch (deviceType) {
            ///隔水炖
        case DeviceTypeWaterCooker:
            return [UIImage imageNamed:@"gray_eq01"];
            ///电饭煲
        case DeviceTypeElectricCooker:
            return [UIImage imageNamed:@"gray_eq03"];
            ///云炖锅
        case DeviceTypeCloudCooker:
            return [UIImage imageNamed:@"gray_eq04"];
            ///炒菜锅
        case DeviceCookFood:
            return [UIImage imageNamed:@"gray_eq06"];
            ///私享壶
        case DeviceTypeCloudKettle:
            return [UIImage imageNamed:@"gray_eq05"];
            ///隔水炖16A
        case DeviceTypeWaterCooker16AIG:
            return [UIImage imageNamed:@"gray_eq02"];
        case DeviceTypeCaninets:
            return [UIImage imageNamed:@"ic_storage"];
            ///未知设备
        default:
            return [UIImage imageNamed:@"未知设备"];
    }
    return nil;
}

@end
