
//
//  AddSceneCell.m
//  Product
//
//  Created by zhuqinlu on 2017/6/16.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "AddSceneCell.h"

@implementation AddSceneCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self setAddSceneCell];
    }
    return self;
}
#pragma mark ====== Set UI =======

- (void)setAddSceneCell{
    
    UIImageView *moveIcon = [[UIImageView alloc]initWithFrame:CGRectMake( 20, (75 - 26)/2, 26, 26)];
    moveIcon.image = [UIImage imageNamed:@"Scene_move_icon"];
    [self.contentView addSubview:moveIcon];
    
    _iconImg = [[UIImageView alloc]initWithFrame:CGRectMake( moveIcon.right + 15, (75 - 60)/2, 60, 60)];
    [self.contentView addSubview:_iconImg];
    
    _deviceNameLab = [[UILabel alloc]initWithFrame:CGRectMake(_iconImg.right + 15, 15, kScreenWidth - _iconImg.right - 46, 20)];
    _deviceNameLab.textColor = UIColorHex(0x313131);
    _deviceNameLab.font = kFontSize(13);
    _deviceNameLab.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_deviceNameLab];
    
    _operationNameLab = [[UILabel alloc]initWithFrame:CGRectMake(_deviceNameLab.left, _deviceNameLab.bottom + 5, _deviceNameLab.width, 20)];
    _operationNameLab.textAlignment = NSTextAlignmentLeft;
    _operationNameLab.textColor = UIColorHex(0x959595);
    _operationNameLab.font = kFontSize(13);
    [self.contentView addSubview:_operationNameLab];
    
    _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _deleteBtn.frame = CGRectMake(kScreenWidth - 44,(75-24)/2, 24, 24);
    [_deleteBtn setImage:[UIImage imageNamed:@"Scene_delect_icon"] forState:UIControlStateNormal];
    [_deleteBtn setImage:[UIImage imageNamed:@"Scene_delect_icon"] forState:UIControlStateHighlighted];
    [_deleteBtn addTarget:self action:@selector(deleteClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_deleteBtn];
}

#pragma mark ====== Set Data =======

- (void)setAddSceneCellWithModel:(SceneDetailDeviceTaskModel *)model{
    _iconImg.image = [self setDeviceImgWithName:model.device_name];
    // 当为时间间隔特殊处理
    if ([model.device_name isEqualToString:@"0"]) {
        _operationNameLab.hidden = YES;
        _deviceNameLab.frame = CGRectMake(_iconImg.right + 15, (75-20)/2, kScreenWidth - _iconImg.right - 46, 20);
        _deviceNameLab.text = [NSString ql_getStepTimeWithTime:model.time_interval];
    }else{
        _operationNameLab.text = model.name;
        _deviceNameLab.frame = CGRectMake(_iconImg.right + 15, 15, kScreenWidth - _iconImg.right - 46, 20);
        _operationNameLab.frame = CGRectMake(_deviceNameLab.left, _deviceNameLab.bottom + 5 ,_deviceNameLab.width, 20);
        _deviceNameLab.text = model.device_name;
    }
}
// 通过设备名称来设定图标
- (UIImage *)setDeviceImgWithName:(NSString *)deviceName{
    
    if ([deviceName isEqualToString:@"隔水炖"]) {
        return [UIImage imageNamed:@"gray_eq01"];
    }else if ([deviceName isEqualToString:@"电饭煲"]){
        return [UIImage imageNamed:@"gray_eq03"];
    }else if ([deviceName isEqualToString:@"云炖锅"]){
        return [UIImage imageNamed:@"gray_eq04"];
    }else if ([deviceName isEqualToString:@"炒菜锅"]){
        return [UIImage imageNamed:@"gray_eq06"];
    }else if ([deviceName isEqualToString:@"私享壶"]){
        return [UIImage imageNamed:@"gray_eq05"];
    }else if ([deviceName isEqualToString:@"隔水炖16AIG"]){
        return [UIImage imageNamed:@"gray_eq02"];
    }else{// 时间间隔图标
        return [UIImage imageNamed:@"Scene_TimeInerval_icon"];
    }
    return nil;
}
#pragma mark ====== Event response =======

- (void)deleteClick:(UIButton *)button{
    if (self.buttonClick) {
        self.buttonClick(button);
    }
}
@end
