

//
//  SceneDetailsCell.m
//  Product
//
//  Created by zhuqinlu on 2017/6/14.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "SceneDetailsCell.h"

@implementation SceneDetailsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setSceneDetailsCell];
        self.backgroundColor = [UIColor bgColor_Gray];
    }
    return self;
}
#pragma mark ====== Set UI =======
#pragma mark ====== Set UI =======
- (void)setSceneDetailsCell{
    
    UILabel *len = [[UILabel alloc]initWithFrame:CGRectMake(15 + 12, 0, 2, 232/2 + 20)];
    len.backgroundColor = UIColorHex(0xE3E6E6);
    [self addSubview:len];
    
    _typeIcon = [[UIImageView alloc]initWithFrame:CGRectMake(22, 12 , 12, 12)];
    _typeIcon.image = [UIImage imageNamed:@"RecommendedScene_normal_ic"];
    [self addSubview:_typeIcon];
    
    UIView *showView = [[UIView alloc]initWithFrame:CGRectMake(15 + 24, 0, kScreenWidth - 15 - 24 - 15, 232/2)];
    showView.backgroundColor = [UIColor whiteColor];
    showView.layer.cornerRadius = 5;
    [self addSubview:showView];
    
    _operatingNameLab = InsertLabel(showView, CGRectMake(10 , (35 - 20)/2, 200, 20), NSTextAlignmentLeft, @"", kFontSize(13), UIColorHex(0x959595), NO);
    
    // 线条
    UILabel *topLen = [[UILabel alloc]initWithFrame:CGRectMake(10, 35,showView.width - 20, 0.5)];
    topLen.backgroundColor = UIColorHex(0xEEEEEE);
    [showView addSubview:topLen];
    
    _deviceIconImg = [[UIImageView alloc]initWithFrame:CGRectMake(7.5, topLen.bottom + 8 , 130/2, 130/2)];
    [showView addSubview:_deviceIconImg];
    
    _deviceNameLab = InsertLabel(showView, CGRectMake(_deviceIconImg.right + 15/2,topLen.bottom + (81 - 20)/2, 200, 20), NSTextAlignmentLeft, @"", kFontSize(15), UIColorHex(0x313131), NO);
    
    _recordTypeLab = InsertLabel(showView, CGRectMake(showView.width - 120 , (35 - 20)/2, 100, 20), NSTextAlignmentRight, @"等待执行", kFontSize(14), UIColorHex(0x959595), NO);
}

#pragma mark ======  Set Data =======
- (void)setSecordDetailCellWithModel:(SceneDetailDeviceTaskModel *)model{
    _deviceNameLab.hidden = NO;
    _operatingNameLab.hidden = NO;
    _deviceIconImg.image = [self setIconImageWithDeviceProductId:model.product_id];
    _deviceNameLab.text = model.device_name;
    _operatingNameLab.text =model.name;
}

- (void)setStatusWithRecordStatusModel:(RecordStatusModel *)statusModel{
    _recordTypeLab.text  =[self setScentStepType:statusModel.status];
}
// 设备状态
- (NSString *)setScentStepType:(NSInteger )type{
    switch (type) {
        case 0:
        {
             _recordTypeLab.textColor = UIColorHex(0x959595);
            return @"等待执行";
        }break;
        case 1:
        {
            _recordTypeLab.textColor = UIColorHex(0x3AC97C);
            return @"已执行";
        }break;
        case 2:
        {
            _recordTypeLab.textColor = UIColorHex(0xF75E6B);
            return @"设备离线";
        }break;
        default:
            break;
    }
    return @"等待执行";
}
// 根据设备的产品ID设置图片
- (UIImage *)setIconImageWithDeviceProductId:(NSString *)productId{
    
    if ([productId isEqualToString:ELECTRIC_COOKER_PRODUCT_ID]) {
        ///云智能IH电饭煲
        return [UIImage imageNamed:@"orange_eq03"];
    }else if ([productId isEqualToString:CLOUD_COOKER_PRODUCT_ID]){
        ///云智能电炖锅
        return [UIImage imageNamed:@"orange_eq04"];
    }else if ([productId isEqualToString:WATER_COOKER_PRODUCT_ID]){
        ///云智能隔水炖
        return [UIImage imageNamed:@"orange_eq01"];
    }else if ([productId isEqualToString:CLOUD_KETTLE_PRODUCT_ID]){
        ///云智能私享壶
        return [UIImage imageNamed:@"orange_eq05"];
    }else if ([productId isEqualToString:WATER_COOKER_16AIG_PRODUCT_ID]){
        ///云智能隔水炖16AIG
        return [UIImage imageNamed:@"orange_eq02"];
    }else if ([productId isEqualToString:COOKFOOD_COOKER_PRODUCT_ID]){
        ///云智能健康大厨
        return [UIImage imageNamed:@"orange_eq06"];
    }
    return nil;
}

@end
