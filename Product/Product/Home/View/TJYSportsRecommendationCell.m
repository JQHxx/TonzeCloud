//
//  TJYSportsRecommendationCell.m
//  Product
//
//  Created by zhuqinlu on 2017/4/15.
//  Copyright © 2017年 TianJi. All rights reserved.
//  首页推荐消耗 和 推荐体疗中共用

#import "TJYSportsRecommendationCell.h"

@implementation TJYSportsRecommendationCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _sportsTypImg =  InsertImageView(self.contentView, CGRectMake(15, (58 - 42)/2, 42, 42), [UIImage imageNamed:@""]);
        
        _sportsTypeNameLab = InsertLabel(self.contentView, CGRectMake(_sportsTypImg.right + 15, 12 , 120, 15), NSTextAlignmentLeft, @"", kFontSize(15), UIColorHex(0x313131), NO);
        
        _sportsTimeLab =  InsertLabel(self.contentView, CGRectMake(_sportsTypeNameLab.left, _sportsTypeNameLab.bottom + 6, 120, 15), NSTextAlignmentLeft, @"", kFontSize(13), UIColorHex(0x626262), NO);
        
        _motionIntensityLab =InsertLabel(self.contentView, CGRectMake(kScreenWidth - 135, _sportsTypeNameLab.top, 120, 15), NSTextAlignmentRight, @"", kFontSize(15), UIColorHex(0x313131), NO);
        
        _sportsEnergyLab =  InsertLabel(self.contentView, CGRectMake(kScreenWidth - 135, _motionIntensityLab.bottom + 6 , 120, 15), NSTextAlignmentRight, @"", kFontSize(13), UIColorHex(0x313131), NO);
        
        InsertView(self.contentView, CGRectMake(_sportsTypImg.right,58 - 0.5, kScreenWidth - _sportsTypImg.right, 0.5), kLineColor);
    }
    return self;
}

- (void)cellInitWithData:(TJYRecommendMotionModel *)model{
    
    [_sportsTypImg sd_setImageWithURL:[NSURL URLWithString:model.image_url] placeholderImage:[UIImage imageNamed:@""]];
    
    _sportsTypeNameLab.text = model.name;
    
    _motionIntensityLab.text = model.motion_intensity;
    
    _sportsTimeLab.text = [NSString stringWithFormat:@"%ld分钟",model.time];
    
    NSString *totalStr = [NSString stringWithFormat:@"%ld千卡",model.motion_calorie];
    NSAttributedString *totalsAttrtext = [NSString ql_changeRangeText:totalStr noRangeInedex:2 changeColor:kSystemColor];
    _sportsEnergyLab.attributedText = totalsAttrtext;
}

@end
