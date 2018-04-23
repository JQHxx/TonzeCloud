
//
//  SceneDetailsTimeIntervalsCell.m
//  Product
//
//  Created by zhuqinlu on 2017/6/28.
//  Copyright © 2017年 TianJi. All rights reserved.
//

#import "SceneDetailsTimeIntervalsCell.h"

@implementation SceneDetailsTimeIntervalsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setTimeIntervalsCell];
          self.backgroundColor = [UIColor bgColor_Gray];
    }
    return self;
}
#pragma mark ====== Set UI =======

- (void)setTimeIntervalsCell{

    UILabel *len = [[UILabel alloc]initWithFrame:CGRectMake(15 + 12, 0, 2, 30)];
    len.backgroundColor = UIColorHex(0xE3E6E6);
    [self addSubview:len];
    
    UIImageView *timeIcon = [[UIImageView alloc]initWithFrame:CGRectMake(21.5, 3 , 13, 13)];
    timeIcon.image = [UIImage imageNamed:@"RecommendedScene_time_ic"];
    [self addSubview:timeIcon];
    
    _timeIntervalsLab = [[UILabel alloc]initWithFrame:CGRectMake(timeIcon.right + 15, 0 , kScreenWidth - timeIcon.right - 20, 15)];
    _timeIntervalsLab.textColor = UIColorHex(0x959595);
    _timeIntervalsLab.font = kFontSize(14);
    [self addSubview:_timeIntervalsLab];
}
- (void)setSecordTimeIntervalsCellWithModel:(SceneDetailDeviceTaskModel *)model{
    
    _timeIntervalsLab.text = [NSString ql_getStepTimeWithTime:model.time_interval];
}

@end
