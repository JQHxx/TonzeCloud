//
//  TempMeasurementsCell.h
//  Product
//
//  Created by 梁家誌 on 16/8/23.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MeasurementsModel;

@interface BPMeterMeasurementsCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *line1;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *BPDescribeLabel;
@property (weak, nonatomic) IBOutlet UILabel *line2;
@property (weak, nonatomic) IBOutlet UILabel *BPTipsLabel;
@property (weak, nonatomic) IBOutlet UILabel *BPValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *HeartRateTipsLabel;
@property (weak, nonatomic) IBOutlet UILabel *HeartRateValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *line3;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *fromLabel;
@property (weak, nonatomic) IBOutlet UILabel *line4;

@property (strong, nonatomic) MeasurementsModel *model;


@end
