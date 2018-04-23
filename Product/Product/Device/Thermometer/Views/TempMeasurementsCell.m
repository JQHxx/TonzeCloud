//
//  BPMeterTableViewCell.m
//  Product
//
//  Created by 梁家誌 on 16/8/23.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import "TempMeasurementsCell.h"
#import "MeasurementsModel.h"
#import "DeviceHelper.h"
#import "Product-Swift.h"

@implementation TempMeasurementsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setModel:(MeasurementsModel *)model{
    _model = model;
    _nameLabel.text = model.name;
    _TempDescribeLabel.text = model.describe;
    _TempValueLabel.text = [NSString stringWithFormat:@"%.1f℃",model.temp];
    [DeviceHelper setTextOnRange:NSMakeRange(_TempValueLabel.text.length-1, 1) onLabel:_TempValueLabel toFont:[UIFont boldSystemFontOfSize:13] andBaselineOffset:@(0)];
    _TempDescribeLabel.textColor = [ThermometerModel valueColor:model.temp];
    _timeLabel.text = model.date;
    _fromLabel.text = model.fromName;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
