

//
//  RecordDetailCell.m
//  Product
//
//  Created by zhuqinlu on 2017/6/14.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "RecordDetailCell.h"

@interface RecordDetailCell ()
{
    UILabel *_len;
}
@end

@implementation RecordDetailCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setRecordDetailCell];
    }
    return self;
}
#pragma mark ====== Set UI =======
- (void)setRecordDetailCell{
    
    _timeLab = InsertLabel(self.contentView, CGRectMake( 20, 20, 80, 30), NSTextAlignmentLeft, @"--:--", kFontSize(24), UIColorHex(0x959595), NO);
    // 线条
    _len = [[UILabel alloc]initWithFrame:CGRectMake(_timeLab.right +5, 15 , 0.5, 40)];
    _len.backgroundColor = kLineColor;
    [self.contentView addSubview:_len];
    
    _deviceNameLab = InsertLabel(self.contentView, CGRectMake(_len.right + 15, 10, 200, 30), NSTextAlignmentLeft, @"", kFontSize(15), UIColorHex(0x313131), NO);
    _operatingNameLab = InsertLabel(self.contentView, CGRectMake(_deviceNameLab.left , _deviceNameLab.bottom, 200, 20), NSTextAlignmentLeft, @"", kFontSize(13), UIColorHex(0x959595), NO);
    _recordTypeLab = InsertLabel(self.contentView, CGRectMake(kScreenWidth - 60, 25, 60, 20), NSTextAlignmentLeft, @"未执行", kFontSize(13), UIColorHex(0x959595), NO);
    _recordTypeIcon = [[UIImageView alloc]initWithFrame:CGRectMake(kScreenWidth  - 75,_recordTypeLab.top+4, 12, 12)];
    [self.contentView addSubview:_recordTypeIcon];
    
}
#pragma mark ======  Set Data =======
// 设备状态
- (void)setStatusWithRecordStatusModel:(RecordStatusModel *)statusModel{
    NSString *timeStr = [[TJYHelper sharedTJYHelper] timeWithTimeIntervalString:statusModel.start_time format:@"HH:mm"];
    // 步骤时间
    _timeLab.text = timeStr;
    _timeLab.textColor = UIColorHex(0xff9d38);
    
    _deviceNameLab.text=statusModel.device_name;
    _operatingNameLab.text=statusModel.cook_name;
    _recordTypeLab.text = [self setScentStepType:statusModel.status];
   
}

// 设备状态
- (NSString *)setScentStepType:(NSInteger )type{
    switch (type) {
        case 0:
        {
            _recordTypeLab.textColor = UIColorHex(0x959595);
            _recordTypeIcon.image = [UIImage imageNamed:@"RecommendedScene_NotPerformed_ic"];
            return @"未执行";
        }break;
        case 1:
        {
            _recordTypeLab.textColor = UIColorHex(0x3AC97C);
            _recordTypeIcon.image = [UIImage imageNamed:@"RecommendedScene_normal_ic"];
            return @"已执行";
        }break;
        case 2:
        {
            _recordTypeLab.textColor = UIColorHex(0xF75E6B);
            _recordTypeIcon.image = [UIImage imageNamed:@"RecommendedScene_cut_off"];
            return @"执行失败";
        }break;
        default:
            break;
    }
    return @"未执行";
}

@end
