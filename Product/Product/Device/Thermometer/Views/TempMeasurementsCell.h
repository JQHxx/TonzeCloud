//
//  BPMeterTableViewCell.h
//  Product
//
//  Created by 梁家誌 on 16/8/23.
//  Copyright © 2016年 TianJi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MeasurementsModel;

@interface TempMeasurementsCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *line1;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *TempDescribeLabel;
@property (weak, nonatomic) IBOutlet UILabel *line2;
@property (weak, nonatomic) IBOutlet UILabel *TempTipsLabel;
@property (weak, nonatomic) IBOutlet UILabel *TempValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *line3;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *fromLabel;
@property (weak, nonatomic) IBOutlet UILabel *line4;

@property (strong, nonatomic) MeasurementsModel *model;

@end
