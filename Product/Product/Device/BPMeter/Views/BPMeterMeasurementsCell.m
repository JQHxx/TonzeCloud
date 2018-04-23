//
//  TempMeasurementsCell.m
//  Product
//
//  Created by 梁家誌 on 16/8/23.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import "BPMeterMeasurementsCell.h"
#import "MeasurementsModel.h"
#import "DeviceHelper.h"
#import "Product-Swift.h"

@implementation BPMeterMeasurementsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setModel:(MeasurementsModel *)model{
    _model = model;
    _nameLabel.text = model.name;
    _BPDescribeLabel.text = model.describe;
    _BPValueLabel.text = [NSString stringWithFormat:@"%ld/%ld(mmHg)",(long)model.SBP,(long)model.DBP];
    _HeartRateValueLabel.text = [NSString stringWithFormat:@"%ld(次/分钟)",(long)model.heartRate];
    [DeviceHelper setTextOnRange:NSMakeRange(_BPValueLabel.text.length-6, 6) onLabel:_BPValueLabel toFont:[UIFont boldSystemFontOfSize:13] andBaselineOffset:@(0)];
    [DeviceHelper setTextOnRange:NSMakeRange(_HeartRateValueLabel.text.length-6, 6) onLabel:_HeartRateValueLabel toFont:[UIFont boldSystemFontOfSize:13] andBaselineOffset:@(0)];
    _BPDescribeLabel.textColor = [BPMeterModelHelper BPvalueColor:model.DBP HPvalue:model.SBP];
    _timeLabel.text = model.date;
    _fromLabel.text = model.fromName;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
